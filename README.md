# Sonatype Nexus Repository Manager 3 Puppet module
Install and configure Sonatype Nexus Repository Manager 3.

This module was forked from [hubspot/nexus](https://forge.puppet.com/hubspot/nexus).

## Requirements of this module
* puppet/archive
* puppet/extlib
* puppetlabs/stdlib

## Migration from pre 3.x versions of this module
With version 3.0.0 we changed the default installation path from `/srv` to `/opt/sonatype`.

To migrate your current installation you will have to put something like the following into your `role_nexus_server.pp`:

```puppet
  # shutdown the currently running service as we have to modify the operation system user
  exec { 'shutdown-running-service':
    command => '/usr/bin/systemctl stop nexus.service',
    onlyif  => [
      '/usr/bin/test -d /srv/sonatype-work',
      '/usr/bin/test ! -d /opt/sonatype/sonatype-work'
    ],
    before  => [
      Class['nexus::package'],
      Class['nexus::user']
    ],
  }

  # nexus::package will extract the archive which contains an empty work directory
  exec { 'remove-empty-work-directory':
    command => '/usr/bin/rm -rf /opt/sonatype/sonatype-work',
    onlyif  => [
      '/usr/bin/test -d /srv/sonatype-work',
      '/usr/bin/test -d /opt/sonatype/sonatype-work'
    ],
    before  => [
      Exec['move-work-directory-to-new-location']
    ],
    require => [
      Class['nexus::package'],
    ]
  }

  # move the old working directory to the new location
  exec { 'move-work-directory-to-new-location':
    command => '/usr/bin/mv /srv/sonatype-work /opt/sonatype/',
    onlyif  => [
      '/usr/bin/test -d /srv/sonatype-work',
      '/usr/bin/test ! -d /opt/sonatype/sonatype-work'
    ],
    require => [
      Class['nexus::package'],
      Exec['remove-empty-work-directory'],
    ],
    before  => Class['nexus::service'],
  }
```

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

https://${::fqdn}/

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
    location  => '/',
    vhost     => 'nexus',
    proxy     => "http://${nexus::host}:${nexus::port}",
    ssl       => true,
  }
```

## Docker
To use nexus repository for docker you need to read the documentation for some additional config settings.
[Docker Repository Reverse Proxy Strategies](https://help.sonatype.com/repomanager3/nexus-repository-administration/formats/docker-registry/docker-repository-reverse-proxy-strategies)

```puppet
  nginx::resource::location { 'nexus':
    ensure    => present,
    location  => '/',
    locations => {
      'docker-v2' => {
        location => '/v2/',
        proxy    => "http://${nexus::host}:${nexus::port}/repository/docker-hosted/v2/",
      }
    },
    vhost     => 'nexus',
    proxy     => "http://${nexus::host}:${nexus::port}",
    ssl       => true,
  }
```
Keep in mind that pushing to docker group repository is a pro feature of nexus repository manager.

## TODO
* Find a way to not require a version to be passed to Class['nexus']

## Authors
* Tom McLaughlin <tmclaughlin@hubspot.com>

## Copyright
Hubspot, Inc.
