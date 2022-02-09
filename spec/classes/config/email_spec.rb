# frozen_string_literal: true

require 'spec_helper'

describe 'nexus::config::email' do
  context 'with defaults' do
    it { is_expected.to compile }

    attributes = {
      'enabled' => false,
      'host' => 'localhost',
      'port' => 25,
      'username' => '',
      'password' => nil,
      'fromAddress' => 'nexus@example.org',
      'subjectPrefix' => '',
      'startTlsEnabled' => false,
      'startTlsRequired' => false,
      'sslOnConnectEnabled' => false,
      'sslServerIdentityCheckEnabled' => false,
      'nexusTrustStoreEnabled' => false,
    }

    it {
      is_expected.to contain_nexus_setting('email').with('attributes' => attributes)
    }
  end
end
