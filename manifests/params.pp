# === Class: nexus::params
#
# module parameters.
#
# === Parameters
#
# NONE
#
# === Examples
#
# class nexus inherits nexus::params {
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
class nexus::params {
  # See nexus::package on why this won't increment the package version.
  $version        = 'latest'
  $revision       = '01'
  $download_site  = 'http://www.sonatype.org/downloads'
  $nexus_root     = '/srv'
  $nexus_home_dir = 'nexus'
  $nexus_work_dir = 'sonatype-work'
  $nexus_user     = 'nexus'
  $nexus_group    = 'nexus'
}
