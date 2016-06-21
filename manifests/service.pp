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
  $nexus_home = $::nexus::nexus_home,
  $nexus_user = $::nexus::nexus_user,
  $nexus_group = $::nexus::nexus_group,
  $version = $::nexus::version,
) {
  $nexus_script = "${nexus_home}/bin/nexus"

  if $::operatingsystem == 'Debian' {
    if versioncmp($::operatingsystemrelease, '8.0') > 0 {
      file { '/lib/systemd/system/nexus.service':
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template('nexus/nexus.systemd.erb'),
      } ->
      service { 'nexus':
        ensure => running,
        name   => 'nexus',
        enable => true,
      }
    } else {

      file_line{ 'nexus_NEXUS_HOME':
        path  => $nexus_script,
        match => '^#?NEXUS_HOME=',
        line  => "NEXUS_HOME=${nexus_home}",
      }

      file_line{ 'nexus_RUN_AS_USER':
        path  => $nexus_script,
        match => '^#?RUN_AS_USER=',
        line  => "RUN_AS_USER=\${run_as_user:-${nexus_user}}",
      }

      file{ '/etc/init.d/nexus':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        source  => "file://${nexus_script}",
        require => [File_line['nexus_NEXUS_HOME'],
          File_line['nexus_RUN_AS_USER']],
        notify  => Service['nexus']
      }

      if $version !~ /\d.*/ or versioncmp($version, '2.8.0') >= 0 {
        $status_line = "env run_as_user=${nexus_user} /etc/init.d/nexus status"
      } else {
        $status_line = 'env run_as_user=root /etc/init.d/nexus status'
      }

      service{ 'nexus':
        ensure  => running,
        enable  => true,
        status  => $status_line,
        require => [File['/etc/init.d/nexus'],
          File_line['nexus_NEXUS_HOME'],
          File_line['nexus_RUN_AS_USER'],]
      }
    }
  }
}
