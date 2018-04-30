require 'spec_helper'

describe 'nexus::config', :type => :class do
  let(:defautl_params) {
    {
      'nexus_root'            => '/foo',
      'nexus_home_dir'        => '/bar',
      'nexus_host'            => '1.1.1.1',
      'nexus_port'            => '8888',
      'nexus_context'         => '/baz',
      'nexus_work_dir'        => '/foom',
      'version'               => '2.11.2',
      'nexus_java_initmemory' => '256M',
      'nexus_java_maxmemory'  => '768M',
      'nexus_java_add_number' => 5,
      'nexus_data_folder'     => '',
    }
  }

  context 'with nexus version 2.x test values' do
    let (:params) do
      defautl_params
    end
    it { should contain_class('nexus::config') }

    it { should contain_file_line('nexus-application-host').with(
      'path'  => '/foo//bar/conf/nexus.properties',
      'match' => '^application-host',
      'line'  => 'application-host=1.1.1.1',
    ) }

    it { should contain_file_line('nexus-application-port').with(
      'path'  => '/foo//bar/conf/nexus.properties',
      'match' => '^application-port',
      'line'  => 'application-port=8888',
    ) }

    it { should contain_file_line('nexus-webapp-context-path').with(
      'path'  => '/foo//bar/conf/nexus.properties',
      'match' => '^nexus-webapp-context-path',
      'line'  => 'nexus-webapp-context-path=/baz',
    ) }

    it { should contain_file_line('nexus-work').with(
      'path'  => '/foo//bar/conf/nexus.properties',
      'match' => '^nexus-work',
      'line'  => 'nexus-work=/foom',
    ) }
    it { should contain_file_line('comment_nexus_java_maxmemory').with(
      'path'  => '/foo//bar/bin/jsw/conf/wrapper.conf',
      'match' => '^wrapper.java.maxmemory=',
      'line'  => '#wrapper.java.maxmemory=',
    ) }
    it { should contain_file_line('comment_nexus_java_initmemory').with(
      'path'  => '/foo//bar/bin/jsw/conf/wrapper.conf',
      'match' => '^wrapper.java.initmemory=',
      'line'  => '#wrapper.java.initmemory=',
    ) }
    it { should contain_file_line('set_nexus_java_xms').with(
      'path'  => '/foo//bar/bin/jsw/conf/wrapper.conf',
      'match' => '^wrapper.java.additional.5=-Xms',
      'line'  => 'wrapper.java.additional.5=-Xms256M',
    ) }
    it { should contain_file_line('set_nexus_java_xmx').with(
      'path'  => '/foo//bar/bin/jsw/conf/wrapper.conf',
      'match' => '^wrapper.java.additional.6=-Xmx',
      'line'  => 'wrapper.java.additional.6=-Xmx768M',
    ) }
  end
  context 'with nexus version 3.x test values' do
    let (:params) do
      defautl_params.merge({
        'version' => '3.0.0',
      })
    end
    it { should contain_file_line('set_nexus_java_xms').with(
      'path'  => '/foo//bar/bin/nexus.vmoptions',
      'match' => '^-Xms',
      'line'  => '-Xms256M',
    ) }
    it { should contain_file_line('set_nexus_java_xmx').with(
      'path'  => '/foo//bar/bin/nexus.vmoptions',
      'match' => '^-Xmx',
      'line'  => '-Xmx768M',
    ) }
  end
end

# vim: sw=2 ts=2 sts=2 et :
