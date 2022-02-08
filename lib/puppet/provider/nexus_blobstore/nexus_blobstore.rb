# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/config'

# Implementation for the nexus_blobstore type using the Resource API.
class Puppet::Provider::NexusBlobstore::NexusBlobstore < Puppet::ResourceApi::SimpleProvider
  # Init connection to the rest api
  def initialize
    super
    local_device = Puppet::Util::NetworkDevice::Config.devices['localhost_nexus_rest_api']
    config_file = local_device['url'] unless local_device.nil?
    Puppet::ResourceApi::Transport.inject_device('nexus_rest_api', config_file) unless File.exist?(config_file)
  end

  # Return requested blobstores as resources
  def get(context, names = nil)
    res = context.transport.get_request(context, 'blobstores')

    context.err(res.body) unless res.success?

    Puppet::Util::Json.load(res.body).map { |blobstore|
      next unless names.include?(blobstore['name'])

      type = blobstore['type'].downcase # API returns 'File' instead of 'file'
      res = context.transport.get_request(context, "blobstores/#{type}/#{blobstore['name']}")

      next unless res.success? # skip unsupported blobstore types

      attributes = Puppet::Util::Json.load(res.body)
      {
        name: blobstore['name'],
        ensure: 'present',
        type: type,
        attributes: attributes
      }
    }.compact
  end

  # Create blobstores not yet existing in nexus repository manager
  def create(context, name, should)
    attributes = should[:attributes]
    attributes[:name] = name
    res = context.transport.post_request(context, "blobstores/#{should[:type]}", attributes)

    context.err(res.body) unless res.success?
  end

  # Update blobstore settings on existing blobstore
  def update(context, name, should)
    res = context.transport.put_request(context, "blobstores/#{should[:type]}/#{name}", should[:attributes])

    context.err(res.body) unless res.success?
  end

  # Delete blobstore which is set to absent
  def delete(context, name)
    res = context.transport.delete_request(context, "blobstores/#{name}")

    context.err(res.body) unless res.success?
  end
end
