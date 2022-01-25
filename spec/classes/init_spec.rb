require 'spec_helper'

describe 'nexus', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) do
        {
          'version' => '3.37.3-02',
        }
      end

      context 'no params set' do
        let(:params) { {} }

        it 'fails if no version configured' do
          expect { is_expected.to compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                                                           %r{expects a value for parameter 'version'})
        end
      end

      context 'with invalid version set' do
        let(:params) do
          {
            'version' => '2.11.2',
          }
        end

        it 'fails if no version configured' do
          expect { is_expected.to compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                                                           %r{parameter 'version' expects a match for Pattern})
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
            'home'    => '/opt/sonatype',
            'shell'   => '/bin/sh',
            'system'  => true,
            'require' => 'Group[nexus]',
          )
        }

        it {
          is_expected.to contain_class('nexus::package').that_requires(
            'Class[nexus::user]',
          )
        }

        it 'manages the nexus config' do
          is_expected.to contain_class('nexus::config').that_requires(
            'Class[nexus::package]',
          ).that_notifies('Class[nexus::service]')

          is_expected.to contain_file_line('nexus-application-host').with(
            'path'  => '/opt/sonatype/sonatype-work/nexus3/etc/nexus.properties',
            'match' => '^application-host=',
            'line'  => 'application-host=127.0.0.1',
          )

          is_expected.to contain_file_line('nexus-application-port').with(
            'path'  => '/opt/sonatype/sonatype-work/nexus3/etc/nexus.properties',
            'match' => '^application-port=',
            'line'  => 'application-port=8081',
          )
        end

        it {
          is_expected.to contain_class('nexus::service').that_subscribes_to(
            'Class[nexus::config]',
          )
        }

        it {
          is_expected.to contain_archive('/opt/sonatype/nexus-3.37.3-02-unix.tar.gz').with(
            'creates'      => '/opt/sonatype/nexus-3.37.3-02',
            'extract'      => true,
            'extract_path' => '/opt/sonatype',
            'source'       => 'https://download.sonatype.com/nexus/3/nexus-3.37.3-02-unix.tar.gz',
          )
          is_expected.to contain_file('/opt/sonatype').with(
            'ensure'  => 'directory',
            'backup'  => false,
            'force'   => true,
            'purge'   => true,
            'recurse' => true,
            'ignore'  => [
              'nexus-3.37.3-02',
              'sonatype-work',
            ],
          )
        }

        it 'manages the service' do
          is_expected.to contain_file('/lib/systemd/system/nexus.service')
          is_expected.to contain_service('nexus').with(
            'ensure' => 'running',
            'enable' => true,
          )
        end

        it 'manages the working directory' do
          permission = {
            'ensure'  => 'directory',
            'owner'   => 'nexus',
            'group'   => 'nexus',
            'require' => 'Archive[/opt/sonatype/nexus-3.37.3-02-unix.tar.gz]',
          }

          is_expected.to contain_file('/opt/sonatype/sonatype-work/nexus3').with(permission)
          is_expected.to contain_file('/opt/sonatype/sonatype-work/nexus3/etc').with(permission)
          is_expected.to contain_file('/opt/sonatype/sonatype-work/nexus3/log').with(permission)
          is_expected.to contain_file('/opt/sonatype/sonatype-work/nexus3/orient').with(permission)
          is_expected.to contain_file('/opt/sonatype/sonatype-work/nexus3/tmp').with(permission)
        end

        it 'does not have a user or group if nexus_manage_user is false' do
          params['manage_user'] = false

          is_expected.not_to contain_group('nexus')
          is_expected.not_to contain_user('nexus')
        end
      end
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :
