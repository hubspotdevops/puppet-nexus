# frozen_string_literal: true

require 'spec_helper'

describe 'nexus::config::anonymous' do
  context 'with defaults' do
    it { is_expected.to compile }

    attributes = {
      'enabled'   => false,
      'userId'    => 'anonymous',
      'realmName' => 'NexusAuthorizingRealm',
    }

    it {
      is_expected.to contain_nexus_setting('security/anonymous').with('attributes' => attributes)
    }
  end
end
