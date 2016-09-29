# Sonatype Nexus Puppet module [![Build Status](https://travis-ci.org/hubspotdevops/puppet-nexus.svg?branch=master)](https://travis-ci.org/hubspotdevops/puppet-nexus)
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
  class{ '::java': }

  class{ '::nexus':
    version    => '2.8.0',
    revision   => '05',
    nexus_root => '/srv', # All directories and files will be relative to this
  }

  Class['::java'] ->
  Class['::nexus']
}
```

NOTE: If you wish to deploy a Nexus Pro server instead of Nexus OSS set
`deploy_pro => true`

### Usage(draft): Nexus 3 support

```puppet
class role_nexus_server {

  class{ '::nexus':
    version               => '3.0.0',
    revision              => '03',
    download_site         => 'http://download.sonatype.com/nexus/3',
    nexus_type            => 'unix',
    nexus_work_dir_manage => false
  }

}
```

NOTE: If you wish to use Nexus **3**, `nexus_work_dir_manage`
need to be set to `false` because this module support **only** Nexus **3** installation

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
