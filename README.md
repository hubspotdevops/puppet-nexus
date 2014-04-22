# Sonatype Nexus Puppet module
Install and configure Sonatype Nexus.

## Requires
* maestrodev/wget
* puppetlabs/stdlib

## Usage
The following is a basic role class for building a nexus host.  Adjust
accordingly as needed.

NOTE: you must pass version to Class['nexus'].  This is needed for the
download link and determining the name of the nexus directory.

```puppet
class role_nexus_server {

  # puppetlabs-java
  # NOTE: Nexus requires
  class { '::java': }

  group { 'nexus':
    ensure => present,
    system => true
  }

  user { 'nexus':
    ensure  => present,
    comment => 'Nexus user',
    gid     => 'nexus',
    home    => '/srv/nexus',
    shell   => '/bin/bash', # unfortunately required to start application via script.
    system  => true,
    require => Group['nexus']
  }

  class { '::nexus':
    version        => '2.8.0',
    revision       => '05'
  }

  Class['::java'] -> Group[nexus] -> User[nexus] -> Class['::nexus']

}
```

### Nginx proxy
The following is setup for using the
[jfryman/puppet-nginx](https://github.com/jfryman/puppet-nginx) module. Nexus
does not adequately support HTTP and HTTPS simultaneously.  Below forces
all connections to HTTPS.  Be sure to login after the app is up and head
to Administration -> Server.  Change the base URL to "https" and check
"Force Base URL".  The application will be available at:

https://${::fqdn}/nexus/

```puppet
  class{ '::nginx': }

  file { '/etc/nginx/conf.d/default.conf':
    ensure => absent,
    require => Class['::nginx::package'],
    notify => Class['::nginx::service']
  }

  nginx::resource::vhost { 'nexus':
    ensure            => present,
    www_root          => '/usr/share/nginx/html',
    rewrite_to_https  => true,
    ssl               => true,
    ssl_cert          => '/etc/pki/tls/certs/server.crt',
    ssl_key           => '/etc/pki/tls/private/server.key',
  }

  nginx::resource::location { 'nexus':
    ensure    => present,
    location  => '/nexus',
    vhost     => 'nexus',
    proxy     => "http://${nexus_host}:${nexus_port}/nexus",
    ssl       => true,
  }
```

## TODO
* Find a way to not require a version to be passed to Class['nexus']

## Authors
* Tom McLaughlin <tmclaughlin@hubspot.com>

## Copyright
Hubspot, Inc.

