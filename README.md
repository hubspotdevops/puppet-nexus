# Sonatype Nexus Repository Manager Puppet module
Install and configure Sonatype Nexus.

This module was forked from [hubspot/nexus](https://forge.puppet.com/hubspot/nexus).

## Requirements of this module
* puppet/archive
* puppetlabs/stdlib

## Usage
The following is a basic role class for building a nexus host. Adjust
accordingly as needed.

NOTE: you must pass version to `Class['nexus']`. This is needed for the
download link and determining the name of the nexus directory.

```puppet
class role_nexus_server {
  
  # puppetlabs-java
  # NOTE: Nexus requires
  class{ 'java': }
  
  class{ 'nexus':
    version               => '3.37.3',
    revision              => '02',
    nexus_type            => 'unix',
  }
  
  Class['java'] ->
  Class['nexus']

}
```

Valid versions and revisions can be picked from the [official page](https://help.sonatype.com/repomanager3/download/download-archives---repository-manager-3)

### Nginx proxy
The following is setup for using the
[puppet/puppet-nginx](https://github.com/voxpupuli/puppet-nginx) module. Nexus
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
