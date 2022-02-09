# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_transport(
  name: 'nexus_rest_api',
  desc: <<-EOS,
      This transport provides Puppet with the capability to connect to nexus repository manager rest api targets.
  EOS
  features: [],
  connection_info: {
    address: {
      type: 'String',
      desc: 'The hostname or IP address to connect to for this target.'
    },
    port: {
      type: 'Optional[Integer]',
      desc: 'The port to connect to. Defaults to 8081',
      default: 8081
    },
    protocol: {
      type: 'Optional[Enum[http,https]]',
      desc: 'The protocol used to connect to the rest api. Defaults to http',
      default: 'http'
    },
    uri: {
      type: 'Optional[String]',
      desc: 'The base uri of the rest api. Defaults to "/service/rest/v1/"',
      default: '/service/rest/v1/'
    },
    username: {
      type: 'String',
      desc: 'The name of the user to authenticate as.'
    },
    password: {
      type: 'String',
      desc: 'The password for the user.',
      sensitive: true
    },
    tmp_pw_file: {
      type: 'Optional[String]',
      desc: 'Path of the file which will contain the initial admin password.',
      behaviour: :parameter
    }
  },
)
