# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/config'

# Implementation for the nexus_anonymous type using the Resource API.
class Puppet::Provider::NexusSetting::NexusSetting < Puppet::ResourceApi::SimpleProvider
  # Init connection to the rest api
  def initialize
    super
    local_device = Puppet::Util::NetworkDevice::Config.devices['localhost_nexus_rest_api']
    config_file = local_device['url'] unless local_device.nil?
    Puppet::ResourceApi::Transport.inject_device('nexus_rest_api', config_file) unless File.exist?(config_file)
  end

  # Return requested setting as resources
  def get(context, names = nil)
    names.map do |name|
      res = context.transport.get_request(context, name)

      context.err(res.body) unless res.success?

      settings = Puppet::Util::Json.load(res.body)
      {
        ensure: 'present',
        name: name,
        attributes: settings
      }
    end
  end

  # Creation - not supported
  def create(context, _name, _should)
    context.debug('Creation not supported.')
  end

  # Update the settings
  def update(context, name, should)
    res = context.transport.put_request(context, name, should[:attributes])

    context.err(res.body) unless res.success?
  end

  # Deletion - not supported
  def delete(context, _name)
    context.debug('Delete not supported.')
  end
end
