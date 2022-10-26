# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/config'

# Implementation for the nexus_user type using the Resource API.
class Puppet::Provider::NexusUser::NexusUser < Puppet::ResourceApi::SimpleProvider
  # Init connection to the rest api
  def initialize
    super
    local_device = Puppet::Util::NetworkDevice::Config.devices['localhost_nexus_rest_api']
    config_file = local_device['url'] unless local_device.nil?
    Puppet::ResourceApi::Transport.inject_device('nexus_rest_api', config_file) unless File.exist?(config_file)
  end

  # Check function if user password is correct
  def insync?(context, name, property_name, _is_hash, should_hash)
    context.debug("Checking whether #{property_name} is out of sync")
    case property_name
    when :password
      if should_hash[property_name].respond_to?(:unwrap)
        context.debug("Unwrapping #{property_name}")
        password_unwrapped = should_hash[property_name].unwrap
      else
        password_unwrapped = should_hash[property_name]
      end

      res = Puppet.runtime[:http].get(
        context.transport.build_uri('status'),
        options: {
          basic_auth: {
            user: name,
            password: password_unwrapped
          }
        },
      )

      unless res.success?
        res = context.transport.put_request_text(context, "security/users/#{name}/change-password", password_unwrapped)
      end

      res.success?
    end
  end

  # convert keys of the given hash to snake_case
  def keys_to_snake_case(hash)
    hash.transform_keys do |key|
      key.gsub(%r{([A-Z]+)([A-Z][a-z])}, '\1_\2')
         .gsub(%r{([a-z\d])([A-Z])}, '\1_\2')
         .downcase
         .to_sym
    end
  end

  # convert keys of the given hash to camelCase
  def keys_to_camelcase(hash)
    hash.transform_keys do |key|
      key.to_s
         .gsub(%r{(?:_+)([a-z])}) { Regexp.last_match(1).upcase }
         .gsub(%r{(\A|\s)([A-Z])}) { Regexp.last_match(1) + Regexp.last_match(2).downcase }
         .to_sym
    end
  end

  # Return all existing users as resources
  def get(context)
    res = context.transport.get_request(context, 'security/users')

    context.err(res.body) unless res.success?

    Puppet::Util::Json.load(res.body).map do |user|
      keys_to_snake_case(user.merge({ 'ensure' => 'present' }))
    end
  end

  # Creates new user if they not exist yet
  def create(context, name, should)
    res = context.transport.post_request(context, 'security/users', keys_to_camelcase(should))

    context.err(name, res.body) unless res.success?
  end

  # Update already existing user
  def update(context, name, should)
    res = context.transport.put_request(context, "security/users/#{name}", keys_to_camelcase(should))

    context.err(name, res.body) unless res.success?
  end

  # Delete existing user if they set to absent
  def delete(context, name)
    res = context.transport.delete_request(context, "security/users/#{name}")

    context.err(name, res.body) unless res.success?
  end
end
