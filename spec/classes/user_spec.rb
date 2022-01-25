# frozen_string_literal: true

require 'spec_helper'

describe 'nexus::user' do
  on_supported_os.each do |os, _os_facts|
    context "on #{os}" do
      it { is_expected.to raise_error Puppet::ParseError, %r{Class nexus::user is private} }
    end
  end
end
