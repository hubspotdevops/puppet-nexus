# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'nexus_setting',
  docs: <<~EOS,
        Raw provider to set settings over the nexus repository manager rest api.

        Please use nexus::config::* classes instead of this one directly.
  EOS
  features: ['simple_get_filter'],
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Whether this resource should be present or absent on the target system.',
      default: 'present'
    },
    name: {
      type: 'String',
      desc: 'The api endpoint of simple nexus config settings.',
      behaviour: :namevar
    },
    attributes: {
      type: 'Hash',
      desc: 'The config settings returned from the given api endpoint.'
    }
  },
)
