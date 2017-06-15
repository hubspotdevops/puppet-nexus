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

  if $version !~ /\d.*/ or versioncmp($version, '3.1.0') >= 0 {
    # Per the Sonatype documentation the custom nexus properties file is
    # {karaf.data}/etc/nexus.properties where {karaf.data} is the work dir
    $conf_path = 'etc/nexus.properties'
    $nexus_properties_file = "${nexus_work_dir}/${conf_path}"

    # https://books.sonatype.com/nexus-book/3.1/reference/install.html#config-context-path
    $context_path_setting = 'nexus-context-path'
  }
  elsif versioncmp($version, '3.0.0') >= 0 {
    $conf_path = 'etc/org.sonatype.nexus.cfg'
    $nexus_properties_file = "${nexus_root}/${nexus_home_dir}/${conf_path}"
    # https://books.sonatype.com/nexus-book/3.0/reference/install.html#config-context-path
    $context_path_setting = 'nexus-context-path'
  } else {
    $conf_path = 'conf/nexus.properties'
    $nexus_properties_file = "${nexus_root}/${nexus_home_dir}/${conf_path}"
    # https://books.sonatype.com/nexus-book/reference/install-sect-proxy.html#nexus_webapp_context_path
    $context_path_setting = 'nexus-webapp-context-path'
  }
  $nexus_data_dir = "${nexus_root}/${nexus_home_dir}/data"

  # Nexus >=3.x do no necesarily have a properties file in place to
  # modify. Make sure that there is at least a minmal file there
  file { $nexus_properties_file:
    ensure =>  present,
  }

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

  file_line{ $context_path_setting:
    path  => $nexus_properties_file,
    match => "^${context_path_setting}",
    line  => "${context_path_setting}=${nexus_context}",
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
