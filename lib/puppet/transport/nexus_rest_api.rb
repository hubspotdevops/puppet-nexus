# frozen_string_literal: true

# Core part of puppet used to connect to external services
module Puppet::Transport
  # The main connection class to a NexusRestApi endpoint
  class NexusRestApi
    # Initialise this transport with a set of credentials
    def initialize(context, connection_info)
      @connection_info = connection_info
      verify(context)
    end

    # Build the complete rest api uri
    def build_uri(endpoint)
      URI("http://#{@connection_info[:address]}:#{@connection_info[:port]}/service/rest/v1/#{endpoint}")
    end

    # Return the options hash with basic auth credentials used by the http client
    def build_options
      if File.exist?(@connection_info[:tmp_pw_file])
        username = 'admin'
        password = File.read(@connection_info[:tmp_pw_file])
      else
        username = @connection_info[:username]
        password = @connection_info[:password].unwrap
      end

      {
        basic_auth: {
          user: username,
          password: password
        }
      }
    end

    # JSON get request against the given api endpoint
    def get_request(_context, endpoint)
      Puppet.runtime[:http].get(
        build_uri(endpoint),
        headers: {
          'Content-Type' => 'application/json'
        },
        options: build_options,
      )
    end

    # Plaintext put request against the given api endpoint
    def put_request_text(_context, endpoint, data)
      Puppet.runtime[:http].put(
        build_uri(endpoint),
        data,
        headers: {
          'Content-Type' => 'text/plain'
        },
        options: build_options,
      )
    end

    # JSON put request against the given api endpoint
    def put_request(_context, endpoint, data)
      Puppet.runtime[:http].put(
        build_uri(endpoint),
        Puppet::Util::Json.dump(data),
        headers: {
          'Content-Type' => 'application/json'
        },
        options: build_options,
      )
    end

    # JSON post request against the given api endpoint
    def post_request(_context, endpoint, data)
      Puppet.runtime[:http].post(
        build_uri(endpoint),
        Puppet::Util::Json.dump(data),
        headers: {
          'Content-Type' => 'application/json'
        },
        options: build_options,
      )
    end

    # JSON delete request against the given api endpoint
    def delete_request(_context, endpoint)
      Puppet.runtime[:http].delete(
        build_uri(endpoint),
        headers: {
          'Content-Type' => 'application/json'
        },
        options: build_options,
      )
    end

    # Verifies that the stored credentials are valid, and that we can talk to the target
    def verify(context)
      context.debug("Checking connection to #{@connection_info[:address]}:#{@connection_info[:port]}")

      raise 'authentication error' unless get_request(context, 'status').success?
    end

    # Retrieve facts from the target and return in a hash
    def facts(_context)
      {}
    end

    # Close the connection and release all resources
    def close(_context)
      @client = nil
    end
  end
end
