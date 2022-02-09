# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'nexus_blobstore',
  docs: <<~EOS,
        Raw provider to configure blobstore over the nexus repository manager rest api.

        Please use the defined types instead of this one directly.
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
      desc: 'The name of the resource you want to manage.',
      behaviour: :namevar
    },
    type: {
      type: 'Enum[azure, file, s3]',
      desc: 'Blobstore type.',
      behaviour: :init_only
    },
    attributes: {
      type: 'Hash',
      desc: 'The config settings of this blobstore definition.'
    }
  },
)
