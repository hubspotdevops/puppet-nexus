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
  $version    = $nexus::params::version,
  $revision   = $nexus::params::revision,
  $nexus_root = $nexus::params::nexus_root
) inherits nexus::params {
  include stdlib

  anchor{'nexus::begin':}

  class{'nexus::package':
    version    => $version,
    revision   => $revision,
    nexus_root => $nexus_root,
    require    => Anchor['nexus::begin']
  }

  class{'nexus::service':}

  anchor{'nexus::end':
    require => Service['nexus::service']
  }
}
