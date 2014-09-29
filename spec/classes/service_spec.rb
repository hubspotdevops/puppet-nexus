require 'spec_helper'

describe 'nexus::service' do
  it { should contain_service('nexus') }
end