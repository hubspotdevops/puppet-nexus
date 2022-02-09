# frozen_string_literal: true

require 'spec_helper'

describe 'nexus::config::default_repositories' do
  context 'with defaults' do
    it { is_expected.to compile }

    it { is_expected.to contain_nexus_repository('maven-central', 'maven-releases', 'maven-public', 'maven-snapshots', 'nuget-group', 'nuget-hosted', 'nuget.org-proxy').with('ensure' => 'absent') }
  end
end
