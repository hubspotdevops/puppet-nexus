# === Class: nexus::config
#
# Configure nexus.
#
# === Parameters
#
# NONE
#
# === Examples
#
# class{ 'nexus::config': }
#
# === Authors
#
# Tom McLaughlin <tmclaughlin@hubspot.com>
#
# === Copyright
#
# Copyright 2013 Hubspot
#
class nexus::config(
  $nexus_root = $::nexus::nexus_root,
  $nexus_home_dir = $::nexus::nexus_home_dir,
  $nexus_host = $::nexus::nexus_host,
  $nexus_port = $::nexus::nexus_port,
  $nexus_context = $::nexus::nexus_context,
  $nexus_work_dir = $::nexus::nexus_work_dir,
  $nexus_data_folder = $::nexus::nexus_data_folder,
  $version = $::nexus::version,
) {

  if $version !~ /\d.*/ or versioncmp($version, '3.0.0') >= 0 {
    $conf_path = 'etc/org.sonatype.nexus.cfg'
  } else {
    $conf_path = 'conf/nexus.properties'
  }
  $nexus_properties_file = "${nexus_root}/${nexus_home_dir}/${conf_path}"
  $nexus_data_dir = "${nexus_root}/${nexus_home_dir}/data"

  file_line{ 'nexus-application-host':
    path  => $nexus_properties_file,
    match => '^application-host',
    line  => "application-host=${nexus_host}"
  }

  file_line{ 'nexus-application-port':
    path  => $nexus_properties_file,
    match => '^application-port',
    line  => "application-port=${nexus_port}"
  }

  file_line{ 'nexus-webapp-context-path':
    path  => $nexus_properties_file,
    match => '^nexus-webapp-context-path',
    line  => "nexus-webapp-context-path=${nexus_context}"
  }

  file_line{ 'nexus-work':
    path  => $nexus_properties_file,
    match => '^nexus-work',
    line  => "nexus-work=${nexus_work_dir}"
  }

  if $nexus_data_folder {
    file{ $nexus_data_dir :
      ensure => 'link',
      target => $nexus_data_folder,
      force  => true,
      notify => Service['nexus']
    }
  }
}
