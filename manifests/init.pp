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
  $version               = $nexus::params::version,
  $revision              = $nexus::params::revision,
  $download_site         = $nexus::params::download_site,
  $nexus_root            = $nexus::params::nexus_root,
  $nexus_home_dir        = $nexus::params::nexus_home_dir,
  $nexus_work_dir        = undef,
  $nexus_work_dir_manage = $nexus::params::nexus_work_dir_manage,
  $nexus_user            = $nexus::params::nexus_user,
  $nexus_group           = $nexus::params::nexus_group,
  $nexus_host            = $nexus::params::nexus_host,
  $nexus_port            = $nexus::params::nexus_port,
  $nexus_work_recurse    = $nexus::params::nexus_work_recurse,
  $nexus_context         = $nexus::params::nexus_context,
  $nexus_manage_user     = $nexus::params::nexus_manage_user,
) inherits nexus::params {
  include stdlib

  # Bail if $version is not set.  Hopefully we can one day use 'latest'.
  if ($version == 'latest') or ($version == undef) {
    fail('Cannot set version nexus version to "latest" or leave undefined.')
  }

  if $nexus_work_dir != undef {
    $real_nexus_work_dirc = $nexus_work_dir
  } else {
    $real_nexus_work_dir = "${nexus_root}/sonatype-work/nexus"
  }

  anchor{ 'nexus::begin':}

  if($nexus_manage_user){
    group { $nexus_group :
      ensure  => present
    }

    user { $nexus_user:
      ensure     => present,
      comment    => 'Nexus User',
      gid        => $nexus_group,
      home       => $nexus_root,
      shell      => '/bin/sh', # required to start application via script.
      system     => true,
      require    => Group['nexus']
    }
  }

  class{ 'nexus::package':
    version               => $version,
    revision              => $revision,
    download_site         => $download_site,
    nexus_root            => $nexus_root,
    nexus_home_dir        => $nexus_home_dir,
    nexus_user            => $nexus_user,
    nexus_group           => $nexus_group,
    nexus_work_dir        => $real_nexus_work_dir,
    nexus_work_dir_manage => $nexus_work_dir_manage,
    nexus_work_recurse    => $nexus_work_recurse,
    require               => Anchor['nexus::begin'],
    notify                => Class['nexus::service']
  }

  class{ 'nexus::config':
    nexus_root     => $nexus_root,
    nexus_home_dir => $nexus_home_dir,
    nexus_host     => $nexus_host,
    nexus_port     => $nexus_port,
    nexus_context  => $nexus_context,
    nexus_work_dir => $real_nexus_work_dir,
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
