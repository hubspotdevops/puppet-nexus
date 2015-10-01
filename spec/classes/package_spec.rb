require 'spec_helper'

describe 'nexus::package', :type => :class do
  let(:params) {
    {
      'deploy_pro'            => false,
      'download_site'         => 'http://download.sonatype.com/nexus/oss',
      'nexus_root'            => '/srv',
      'nexus_home_dir'        => 'nexus',
      'nexus_user'            => 'nexus',
      'nexus_group'           => 'nexus',
      'nexus_work_dir'        => '/srv/sonatype-work/nexus',
      'nexus_work_dir_manage' => true,
      'nexus_work_recurse'    => true,
      # Assume a good revision as init.pp screens for us
      'revision'              => '01',
      'version'               => '2.11.2',
    }
  }

  context 'no params set' do
    let(:params) {{}}

    it 'should fail' do
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /Must pass /)
    end
  end

  context 'with default values' do
    it { should contain_class('nexus::package') }

    it { should contain_wget__fetch('nexus-2.11.2-01-bundle.tar.gz').with(
      'source'      => 'http://download.sonatype.com/nexus/oss/nexus-2.11.2-01-bundle.tar.gz',
      'destination' => '/srv/nexus-2.11.2-01-bundle.tar.gz',
      'before'      => 'Exec[nexus-untar]',
    ) }

    it { should contain_exec('nexus-untar').with(
      'command' => 'tar zxf /srv/nexus-2.11.2-01-bundle.tar.gz',
      'cwd'     => '/srv',
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
          'download_site' => 'http://download.sonatype.com/nexus/professional-bundle',
        }
      )

      should contain_wget__fetch('nexus-professional-2.11.2-01-bundle.tar.gz').with(
        'source' => 'http://download.sonatype.com/nexus/professional-bundle/nexus-professional-2.11.2-01-bundle.tar.gz',
        'destination' => '/srv/nexus-professional-2.11.2-01-bundle.tar.gz',
      )

      should contain_exec('nexus-untar').with(
        'command' => 'tar zxf /srv/nexus-professional-2.11.2-01-bundle.tar.gz',
        'creates' => '/srv/nexus-professional-2.11.2-01',
      )

      should contain_file('/srv/nexus-professional-2.11.2-01')

      should contain_file('/srv/nexus').with(
        'target' => '/srv/nexus-professional-2.11.2-01',
      )
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :
