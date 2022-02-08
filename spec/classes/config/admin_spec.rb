# frozen_string_literal: true

require 'spec_helper'

describe 'nexus::config::admin' do
  context 'with defaults' do
    it { is_expected.to compile }

    it {
      is_expected.to contain_nexus_user('admin').with('ensure' => 'present', 'first_name' => 'Administrator', 'last_name' => 'User', 'email_address' => 'admin@example.org', 'roles' => ['nx-admin'])
    }
  end
end
