require 'spec_helper'

describe 'nexus', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) do
        {
          'version' => '2.11.2',
        }
      end

      context 'no params set' do
        let(:params) { {} }

        it 'fails if no version configured' do
          expect { is_expected.to compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                                                           %r{match for Pattern})
        end
      end

      context 'with a version set' do
        it { is_expected.to contain_class('nexus') }

        it {
          is_expected.to contain_group('nexus').with(
            'ensure' => 'present',
          )
        }

        it {
          is_expected.to contain_user('nexus').with(
            'ensure'  => 'present',
            'comment' => 'Nexus User',
            'gid'     => 'nexus',
            'home'    => '/srv',
            'shell'   => '/bin/sh',
            'system'  => true,
            'require' => 'Group[nexus]',
          )
        }

        it { is_expected.to contain_anchor('nexus::setup') }
        it {
          is_expected.to contain_class('nexus::package').that_requires(
            'Anchor[nexus::setup]',
          )
        }
        it {
          is_expected.to contain_class('nexus::config').that_requires(
            'Class[nexus::package]',
          ).that_notifies('Class[nexus::service]')
        }
        it {
          is_expected.to contain_class('nexus::service').that_subscribes_to(
            'Class[nexus::config]',
          )
        }
        it {
          is_expected.to contain_anchor('nexus::done').that_requires(
            'Class[nexus::service]',
          )
        }

        it 'handles deploy_pro' do
          params['deploy_pro'] = true

          is_expected.to create_class('nexus::package').with(
            'deploy_pro'    => true,
            'download_site' => 'https://download.sonatype.com/nexus/professional-bundle',
          )
        end

        it 'does not have a user or group if nexus_manage_user is false' do
          params['nexus_manage_user'] = false

          is_expected.not_to contain_group('nexus')
          is_expected.not_to contain_user('nexus')
        end
      end
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :
