# === Class: nexus::service
#
# Maintains the Nexus service
#
# === Parameters
#
# NONE
#
# === Variables
#
# [*nexus_home*]
#   The home location for the service
#
# [*nexus_user*]
#   The user to run the service as
#
# [*version*]
#   The version of nexus
#
# === Examples
#
# class{ 'nexus::service':
#   nexus_home => '/srv/nexus',
#   nexus_user => 'nexus',
#   version    => '2.8.0',
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
class nexus::service (
  Stdlib::Absolutepath $nexus_home,
  String[1] $nexus_user = $::nexus::nexus_user,
  String[1] $nexus_group = $::nexus::nexus_group,
) {
  $nexus_script = "${nexus_home}/bin/nexus"

  file { '/lib/systemd/system/nexus.service':
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('nexus/nexus.systemd.erb'),
  }
  -> service { 'nexus':
    ensure => running,
    name   => 'nexus',
    enable => true,
  }
}
