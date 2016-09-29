require 'spec_helper_acceptance'

describe 'apt class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class{ '::java': }

      class{ '::nexus':
        version    => '2.8.0',
        revision   => '05',
        nexus_root => '/srv',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_failures => true)
    end

    describe user('nexus') do
      it { should belong_to_group 'nexus' }
    end

    describe service('nexus') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    context 'Nexus should be running on the default port' do
      describe port(8081) do
        it {
          sleep(90) # Waiting start up
          should be_listening
        }
      end

      describe command('curl 0.0.0.0:8081/nexus/') do
        its(:stdout) { should match /Sonatype Nexus&trade; 2.8.0-05/ }
      end
    end

  end
end
