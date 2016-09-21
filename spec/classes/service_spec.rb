require 'spec_helper'

shared_examples "systemd" do
  context 'with default values ' do
    it { should contain_file('/lib/systemd/system/nexus.service') }
    it { should contain_service('nexus').with(
      'ensure' => 'running',
      'enable' => true,
    ) }
  end
end
shared_examples "initd" do
  it { should contain_file_line('nexus_NEXUS_HOME').with(
    'path'  => '/srv/nexus/bin/nexus',
    'match' => '^#?NEXUS_HOME=',
    'line'  => 'NEXUS_HOME=/srv/nexus',
  ) }

  it { should contain_file('/etc/init.d/nexus').with(
    'ensure'  => 'link',
    'require' => ['File_line[nexus_NEXUS_HOME]', 'File_line[nexus_RUN_AS_USER]'],
    'notify'  => 'Service[nexus]',
  ) }

  it 'should have the correct status line when version >= 3.0.0' do
    params.merge!({'version' => '3.0.0'})

    should contain_service('nexus').with(
      'status' => 'env run_as_user=nexus /etc/init.d/nexus status',
    )
  end

  it { should contain_file_line('nexus_RUN_AS_USER').with(
    'path'  => '/srv/nexus/bin/nexus',
    'match' => '^#?RUN_AS_USER=',
    'line'  => 'RUN_AS_USER=${run_as_user:-nexus}',
  ) }



  it { should contain_service('nexus').with(
    'ensure' => 'running',
    'enable' => true,
    'status' => 'env run_as_user=root /etc/init.d/nexus status',
  ) }

end

describe 'nexus::service', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:params) {
        {
          'nexus_home'  => '/srv/nexus',
          'nexus_user'  => 'nexus',
          'nexus_group' => 'nexus',
          'version'     => '01',
        }
      }

      case facts[:operatingsystem]
      when 'RedHat', 'CentOS'
        if facts[:operatingsystemrelease] >= "7"
          it_behaves_like "systemd"
        else
          it_behaves_like "initd"
        end
      when 'Debian'
        if facts[:operatingsystemrelease] > "8.0"
          it_behaves_like "systemd"
        else
          it_behaves_like "initd"
        end
      when 'Ubuntu'
        if facts[:operatingsystemrelease] > "15.04"
          it_behaves_like "systemd"
        else
          it_behaves_like "initd"
        end
      else
        context 'other OS' do
          it { should contain_class('nexus::service') }
          it_behaves_like "initd"
        end
      end
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :
