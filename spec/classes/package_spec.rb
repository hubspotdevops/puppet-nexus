require 'spec_helper'

describe 'nexus::package', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) do
        {
          'deploy_pro'                    => false,
          'download_site'                 => 'http://download.sonatype.com/nexus/oss',
          'nexus_root'                    => '/srv',
          'nexus_home_dir'                => 'nexus',
          'nexus_user'                    => 'nexus',
          'nexus_group'                   => 'nexus',
          'nexus_work_dir'                => '/srv/sonatype-work/nexus',
          'nexus_work_dir_manage'         => true,
          'nexus_work_recurse'            => true,
          'nexus_type'                    => 'bundle',
          'nexus_selinux_ignore_defaults' => true,
          # Assume a good revision as init.pp screens for us
          'revision'                      => '01',
          'version'                       => '2.11.2',
          'download_folder'               => '/srv',
          'md5sum'                        => '',
        }
      end

      context 'with default values' do
        it { is_expected.to contain_class('nexus::package') }

        it {
          is_expected.to contain_archive('/srv/nexus-2.11.2-01-bundle.tar.gz').with(
            'creates'      => '/srv/nexus-2.11.2-01',
            'extract'      => true,
            'extract_path' => '/srv',
            'source'       => 'http://download.sonatype.com/nexus/oss/nexus-2.11.2-01-bundle.tar.gz',
          )
        }

        it {
          is_expected.to contain_file('/srv/nexus-2.11.2-01').with(
            'ensure'  => 'directory',
            'owner'   => 'nexus',
            'group'   => 'nexus',
            'recurse' => true,
            'require' => 'Archive[/srv/nexus-2.11.2-01-bundle.tar.gz]',
          )
        }

        it {
          is_expected.to contain_file('/srv/sonatype-work/nexus').with(
            'ensure'  => 'directory',
            'owner'   => 'nexus',
            'group'   => 'nexus',
            'recurse' => true,
            'require' => 'Archive[/srv/nexus-2.11.2-01-bundle.tar.gz]',
          )
        }

        it {
          is_expected.to contain_file('/srv/nexus').with(
            'ensure'  => 'link',
            'target'  => '/srv/nexus-2.11.2-01',
            'require' => 'Archive[/srv/nexus-2.11.2-01-bundle.tar.gz]',
          )
        }

        it 'handles deploy_pro' do
          params.merge!(
            'deploy_pro' => true,
            'download_site' => 'http://download.sonatype.com/nexus/professional-bundle',
          )

          is_expected.to contain_archive('/srv/nexus-professional-2.11.2-01-bundle.tar.gz').with(
            'creates'      => '/srv/nexus-professional-2.11.2-01',
            'extract'      => true,
            'extract_path' => '/srv',
            'source'       => 'http://download.sonatype.com/nexus/professional-bundle/nexus-professional-2.11.2-01-bundle.tar.gz',
          )

          is_expected.to contain_file('/srv/nexus-professional-2.11.2-01')

          is_expected.to contain_file('/srv/nexus').with(
            'target' => '/srv/nexus-professional-2.11.2-01',
          )
        end
      end
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :
