require 'spec_helper'

describe 'nexus::service', :type => :class do
  let(:params) {
    {
      'nexus_home' => '/srv/nexus',
      'nexus_user' => 'nexus',
      'version'    => '01',
    }
  }

  context 'no params set' do
    let(:params) {{}}

    it 'should fail' do
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /Must pass nexus_home/)
    end
  end

  it { should contain_service('nexus') }
end

# vim: sw=2 ts=2 sts=2 et :
