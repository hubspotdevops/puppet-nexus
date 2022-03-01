# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet/util/network_device/config'

# Implementation for the nexus_repository type using the Resource API.
class Puppet::Provider::NexusRepository::NexusRepository < Puppet::ResourceApi::SimpleProvider
  # Init connection to the rest api
  def initialize
    super
    local_device = Puppet::Util::NetworkDevice::Config.devices['localhost_nexus_rest_api']
    config_file = local_device['url'] unless local_device.nil?
    Puppet::ResourceApi::Transport.inject_device('nexus_rest_api', config_file) unless File.exist?(config_file)
  end

  # Return requested repositories as resources
  def get(context, names = nil)
    res = context.transport.get_request(context, 'repositories')

    context.err(res.body) unless res.success?

    Puppet::Util::Json.load(res.body).map { |repo|
      next unless names.include?(repo['name']) # only query asked repository

      real_format = case repo['format']
                    when 'maven2'
                      'maven'
                    else
                      repo['format']
                    end

      res = context.transport.get_request(context, "repositories/#{real_format}/#{repo['type']}/#{repo['name']}")

      next unless res.success? # skip unsupported repository types

      attributes = Puppet::Util::Json.load(res.body)

      # Remove static elements as we can't change them without recreation of the resource
      attributes.delete('format')
      attributes.delete('name')
      attributes.delete('type')
      attributes.delete('url')

      {
        name: repo['name'],
        ensure: 'present',
        format: real_format,
        type: repo['type'],
        attributes: attributes
      }
    }.compact
  end

  # Create repositories not yet existing in nexus repository manager
  def create(context, name, should)
    attributes = should[:attributes]
    attributes[:name] = name
    res = context.transport.post_request(context, "repositories/#{should[:format]}/#{should[:type]}", attributes)

    context.err(res.body) unless res.success?
  end

  # Update repository settings on existing repository
  def update(context, name, should)
    attributes = should[:attributes]
    attributes[:name] = name
    res = context.transport.put_request(context, "repositories/#{should[:format]}/#{should[:type]}/#{name}", attributes)

    case should[:type]
    when 'group'
      context.transport.post_request(context, "repositories/#{name}/invalidate-cache", '')
    when 'hosted'
      context.transport.post_request(context, "repositories/#{name}/rebuild-index", '')
    when 'proxy'
      context.transport.post_request(context, "repositories/#{name}/invalidate-cache", '')
      context.transport.post_request(context, "repositories/#{name}/rebuild-index", '')
    end

    context.err(res.body) unless res.success?
  end

  # Delete repository which is set to absent
  def delete(context, name)
    res = context.transport.delete_request(context, "repositories/#{name}")

    context.err(res.body) unless res.success?
  end
end
