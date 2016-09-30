source 'http://rubygems.org'

group :test do
  if puppetversion = ENV['PUPPET_GEM_VERSION']
    gem 'puppet', puppetversion, :require => false
  else
    gem 'puppet', ENV['PUPPET_VERSION'] || '~> 3.8.0'
  end

  # rspec must be v2 for ruby 1.8.7
  if RUBY_VERSION >= '1.8.7' and RUBY_VERSION < '1.9'
    gem 'rspec', '~> 2.0'
  end
  gem 'safe_yaml', '~> 1.0.4'
  gem 'rake'
  gem 'puppet-lint'
  gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem 'puppet-syntax'
  gem 'puppetlabs_spec_helper'
  gem 'simplecov'
  gem 'metadata-json-lint'
  gem 'rspec-puppet-facts', :require => false
end

group :development do
  gem 'travis'
  gem 'travis-lint'
  gem 'puppet-blacksmith'
  gem 'guard-rake'
end

group :system_tests do
  gem 'beaker'
  gem 'beaker-rspec', '~> 5.6.0'
  gem 'vagrant-wrapper'
  gem "beaker-puppet_install_helper"
end
