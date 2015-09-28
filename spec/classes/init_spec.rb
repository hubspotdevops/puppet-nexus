require 'spec_helper'

describe 'nexus', :type => :class do
  let(:params) {
    {
      'version' => '2.11.2'
    }
  }

  context 'no params set' do
    let(:params) {{}}

    it 'should fail if no version configured' do
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
             /Cannot set version nexus version to "latest" or leave undefined./)
    end
  end

  context 'with a version set' do
    it { should create_class('nexus::package') }
    it { should create_class('nexus::config') }
    it { should create_class('nexus::service') }

    it 'should handle deploy_pro' do
      params.merge!(
        {
          'deploy_pro' => true,
        }
      )

      should create_class('nexus::package').with(
        'deploy_pro'    => true,
        'download_site' => 'http://download.sonatype.com/nexus/professional-bundle',
      )
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :
