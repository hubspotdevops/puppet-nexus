require 'spec_helper'

describe 'nexus' do
  it { should create_class('nexus::package') }
  it { should create_class('nexus::config') }
  it { should create_class('nexus::service') }
end