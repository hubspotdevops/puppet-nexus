# === Class: nexus::service
#
# Maintains the Nexus service
#
# === Parameters
#
# NONE
#
# === Examples
#
# class{ 'nexus::service': }
#
# === Authors
#
# Tom McLaughlin <tmclaughlin@hubspot.com>
#
# === Copyright
#
# Copyright 2013 Hubspot
#
class nexus::service(
  $nexus_home,
  $nexus_user
) inherits nexus::params {

  $nexus_init = '/etc/init.d/nexus'

  file{ $nexus_init:
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "file:///${nexus_root}/bin/nexus"
  }

  file_line{ 'nexus_NEXUS_HOME':
    file    => $nexus_init,
    match   => '#?NEXUS_HOME=',
    line    => "NEXUS_HOME=${nexus_home}",
    require => File[$nexus_init]
  }

  file_line{ 'nexus_RUN_AS_USER':
    file    => $nexus_init,
    match   => '#?RUN_AS_USER=',
    line    => "RUN_AS_USER=${nexus_user}",
    require => File[$nexus_init]
  }

  service{ 'nexus':
    ensure  => running,
    enable  => true,
    require => [File['/etc/init.d/nexus'],
                File_line['nexus_NEXUS_HOME'],
                File_line['nexus_RUN_AS_USER'],]
  }
}
