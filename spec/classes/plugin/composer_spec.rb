# frozen_string_literal: true

require 'spec_helper'

describe 'nexus::plugin::composer' do
  let(:pre_condition) { "class { 'nexus': version => '3.37.3-02'}" }

  context 'no params set' do
    let(:params) { {} }

    it 'fails if no version configured' do
      expect { is_expected.to compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                                                       %r{expects a value for parameter 'version'})
    end
  end

  context 'version set' do
    let(:params) do
      {
        'version' => '0.0.18',
      }
    end

    it {
      is_expected.to contain_archive('/opt/sonatype/nexus-3.37.3-02/deploy/nexus-repository-composer-bundle.kar').with(
        'creates'      => '/opt/sonatype/nexus-3.37.3-02/deploy/nexus-repository-composer-bundle.kar',
        'source'       => 'https://repo1.maven.org/maven2/org/sonatype/nexus/plugins/nexus-repository-composer/0.0.18/nexus-repository-composer-0.0.18-bundle.kar',
      ).that_requires('Class[nexus::plugin]')
      is_expected.to contain_file('/opt/sonatype/nexus-3.37.3-02/deploy/nexus-repository-composer-bundle.kar').with(
        'owner' => 'root',
        'group' => 'root',
        'mode' => '0644',
      ).that_requires('Archive[/opt/sonatype/nexus-3.37.3-02/deploy/nexus-repository-composer-bundle.kar]').that_notifies('Class[nexus::service]')
    }
  end
end
