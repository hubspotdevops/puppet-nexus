require 'spec_helper'

describe 'nexus::params', :type => :class do

  context 'with default params' do
    it { should contain_class('nexus::params') }
  end
end

# vim: sw=2 ts=2 sts=2 et :
