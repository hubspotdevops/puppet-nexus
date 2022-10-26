# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'nexus_user',
  docs: <<~EOS,
        @summary Manage nexus repository users
        ```puppet
        nexus_user { 'user.name':
          ensure        => 'present',
          user_id       => 'user.name',
          password      => 'hunter2',
          first_name    => 'Foo',
          last_name     => 'Bar',
          email_address => 'foo.bar@example.org',
          status        => 'active',
          roles         => ['nx-admin'],
        }
        ```
  EOS
  features: ['custom_insync'],
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Whether this resource should be present or absent on the target system.',
      default: 'present'
    },
    user_id: {
      type: 'String',
      desc: 'The login name of the user.',
      behaviour: :namevar
    },
    password: {
      type: 'Variant[String[1], Sensitive[String[1]]]',
      desc: 'The password of the user.'
    },
    first_name: {
      type: 'String',
      desc: 'The first name of the user.'
    },
    last_name: {
      type: 'String',
      desc: 'The last name of the user.'
    },
    email_address: {
      type: 'String',
      desc: 'The email address of the user.'
    },
    source: {
      type: 'String',
      desc: 'The datasource of the user. e.g. local or ldap source name.',
      default: 'default'
    },
    status: {
      type: 'Enum[active,disabled,changepassword]',
      desc: 'The user status.',
      default: 'active'
    },
    read_only: {
      type: 'Boolean',
      desc: 'The status of the user if it is read only.',
      behaviour: :read_only
    },
    roles: {
      type: 'Array[String]',
      desc: 'The roles assigned to the user.',
      default: ['nx-anonymous']
    },
    external_roles: {
      type: 'Optional[Array[String]]',
      desc: 'The external assigned roles to the user.'
    }
  },
)
