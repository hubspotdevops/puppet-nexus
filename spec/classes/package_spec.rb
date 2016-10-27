require 'spec_helper'

describe 'nexus::package', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) {
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
      }

      context 'with default values' do
        it { should contain_class('nexus::package') }

        it { should contain_wget__fetch('nexus-2.11.2-01-bundle.tar.gz').with(
          'source'      => 'http://download.sonatype.com/nexus/oss/nexus-2.11.2-01-bundle.tar.gz',
          'destination' => '/srv/nexus-2.11.2-01-bundle.tar.gz',
          'before'      => 'Exec[nexus-untar]',
          'source_hash' => '',
        ) }

        it { should contain_exec('nexus-untar').with(
          'command' => 'tar zxf /srv/nexus-2.11.2-01-bundle.tar.gz --directory /srv',
          'creates' => '/srv/nexus-2.11.2-01',
          'path'    => [ '/bin', '/usr/bin' ],
        ) }

        it { should contain_file('/srv/nexus-2.11.2-01').with(
          'ensure'  => 'directory',
          'owner'   => 'nexus',
          'group'   => 'nexus',
          'recurse' => true,
          'require' => 'Exec[nexus-untar]',
        ) }

        it { should contain_file('/srv/sonatype-work/nexus').with(
          'ensure'  => 'directory',
          'owner'   => 'nexus',
          'group'   => 'nexus',
          'recurse' => true,
          'require' => 'Exec[nexus-untar]',
        ) }

        it { should contain_file('/srv/nexus').with(
          'ensure'  => 'link',
          'target'  => '/srv/nexus-2.11.2-01',
          'require' => 'Exec[nexus-untar]',
        ) }

        it 'should handle deploy_pro' do
          params.merge!(
            {
              'deploy_pro'    => true,
              'download_site' => 'http://download.sonatype.com/nexus/professional-bundle'
            }
          )

          should contain_wget__fetch('nexus-professional-2.11.2-01-bundle.tar.gz').with(
            'source' => 'http://download.sonatype.com/nexus/professional-bundle/nexus-professional-2.11.2-01-bundle.tar.gz',
            'destination' => '/srv/nexus-professional-2.11.2-01-bundle.tar.gz',
          )

          should contain_exec('nexus-untar').with(
            'command' => 'tar zxf /srv/nexus-professional-2.11.2-01-bundle.tar.gz --directory /srv',
            'creates' => '/srv/nexus-professional-2.11.2-01',
          )

          should contain_file('/srv/nexus-professional-2.11.2-01')

          should contain_file('/srv/nexus').with(
            'target' => '/srv/nexus-professional-2.11.2-01',
          )
        end

        it 'should working with md5sum' do
          params.merge!(
            {
              'md5sum'        => '1234567890'
            }
          )
          should contain_wget__fetch('nexus-2.11.2-01-bundle.tar.gz').with(
            'source'      => 'http://download.sonatype.com/nexus/oss/nexus-2.11.2-01-bundle.tar.gz',
            'destination' => '/srv/nexus-2.11.2-01-bundle.tar.gz',
            'before'      => 'Exec[nexus-untar]',
            'source_hash' => '1234567890',
          )
          should contain_exec('nexus-untar').with(
            'command' => 'tar zxf /srv/nexus-2.11.2-01-bundle.tar.gz --directory /srv',
            'creates' => '/srv/nexus-2.11.2-01',
            'path'    => [ '/bin', '/usr/bin' ],
          )
        end

      end

    end
  end
end

# vim: sw=2 ts=2 sts=2 et :
