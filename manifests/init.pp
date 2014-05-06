# === Class: nexus
#
# Install and configure Sonatype Nexus
#
# === Parameters
#
# [*version*]
#   The version to download.
#
# [*revision*]
#   The revision of the archive. This is needed for the name of the
#   directory the archive is extracted to.  The default should suffice.
#
# [*nexus_root*]
#   The root directory where the nexus application will live and tarballs
#   will be downloaded to.
#
# === Examples
#
# class{ 'nexus':
#   var => 'foobar'
# }
#
# === Authors
#
# Tom McLaughlin <tmclaughlin@hubspot.com>
#
# === Copyright
#
# Copyright 2013 Hubspot
#
class nexus (
  $version            = $nexus::params::version,
  $revision           = $nexus::params::revision,
  $download_site      = $nexus::params::download_site,
  $nexus_root         = $nexus::params::nexus_root,
  $nexus_home_dir     = $nexus::params::nexus_home_dir,
  $nexus_user         = $nexus::params::nexus_user,
  $nexus_group        = $nexus::params::nexus_group,
  $nexus_host         = $nexus::params::nexus_host,
  $nexus_port         = $nexus::params::nexus_port,
  $nexus_work_recurse = $nexus::params::nexus_work_dir_recurse,
  $nexus_context      = $nexus::params::nexus_context,
  $manage_nexus_user  = $nexus::params::manage_nexus_user,
) inherits nexus::params {
  include stdlib

  # Bail if $version is not set.  Hopefully we can one day use 'latest'.
  if ($version == 'latest') or ($version == undef) {
    fail('Cannot set version nexus version to "latest" or leave undefined.')
  }



  anchor{ 'nexus::begin':}

  if($manage_nexus_user){
    group { $nexus_group :
        ensure  => present
    }

    user { $nexus_user:
      ensure     => present,
      name       => $nexus_user,
      comment    => 'Nexus User',
      home       => $nexus_root,
      managehome => true,
      groups     => [$nexus_group]
    }
  }

  class{ 'nexus::package':
    version        => $version,
    revision       => $revision,
    download_site  => $download_site,
    nexus_root     => $nexus_root,
    nexus_home_dir => $nexus_home_dir,
    nexus_user     => $nexus_user,
    nexus_group    => $nexus_group,
    require        => Anchor['nexus::begin'],
    notify         => Class['nexus::service']
  }

  class{ 'nexus::config':
    nexus_root     => $nexus_root,
    nexus_home_dir => $nexus_home_dir,
    nexus_host     => $nexus_host,
    nexus_port     => $nexus_port,
    nexus_context  => $nexus_context,
    require        => Class['nexus::package'],
    notify         => Class['nexus::service']
  }

  class{ 'nexus::service':
    nexus_home => "${nexus_root}/${nexus_home_dir}",
    nexus_user => $nexus_user,
    require    => Class['nexus::config']
  }

  anchor{ 'nexus::end':
    require => Class['nexus::service']
  }
}
