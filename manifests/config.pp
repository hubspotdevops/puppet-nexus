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
  $nexus_java_initmemory = $::nexus::nexus_java_initmemory,
  $nexus_java_maxmemory  = $::nexus::nexus_java_maxmemory,
  $nexus_java_add_number = $::nexus::nexus_java_add_number,
  $version = $::nexus::version,
) {

  if $version !~ /\d.*/ or versioncmp($version, '3.1.0') >= 0 {
    # Per the Sonatype documentation the custom nexus properties file is
    # {karaf.data}/etc/nexus.properties where {karaf.data} is the work dir
    $conf_path = 'etc/nexus.properties'
    $nexus_properties_file = "${nexus_work_dir}/${conf_path}"
    $java_config_file = "${nexus_root}/${nexus_home_dir}/bin/nexus.vmoptions"
  }
  elsif versioncmp($version, '3.0.0') >= 0 {
    $conf_path = 'etc/org.sonatype.nexus.cfg'
    $nexus_properties_file = "${nexus_root}/${nexus_home_dir}/${conf_path}"
    $java_config_file = "${nexus_root}/${nexus_home_dir}/bin/nexus.vmoptions"
  } else {
    $java_config_file = "${nexus_root}/${nexus_home_dir}/bin/jsw/conf/wrapper.conf"
    $conf_path = 'conf/nexus.properties'
    $nexus_properties_file = "${nexus_root}/${nexus_home_dir}/${conf_path}"
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

  if $nexus_java_initmemory {
    if (versioncmp($version, '3.0.0') < 0) {
      file_line {'comment_nexus_java_initmemory':
        path  => $java_config_file,
        line  => '#wrapper.java.initmemory=',
        match => '^wrapper.java.initmemory=',
      }
      file_line {'set_nexus_java_xms':
        path  => $java_config_file,
        line  => "wrapper.java.additional.${nexus_java_add_number}=-Xms${nexus_java_initmemory}",
        match => "^wrapper.java.additional.${nexus_java_add_number}=-Xms",
      }
    } else {
      file_line {'set_nexus_java_xms':
        path  => $java_config_file,
        line  => "-Xms${nexus_java_initmemory}",
        match => '^-Xms',
      }
    }
  }

  if $nexus_java_maxmemory {
    if (versioncmp($version, '3.0.0') < 0) {
      file_line {'comment_nexus_java_maxmemory':
        path  => $java_config_file,
        line  => '#wrapper.java.maxmemory=',
        match => '^wrapper.java.maxmemory=',
      }

      if $nexus_java_initmemory {
        $_num = $nexus_java_add_number + 1
      } else {
        $_num = $nexus_java_add_number
      }

      file_line {'set_nexus_java_xmx':
        path  => $java_config_file,
        line  => "wrapper.java.additional.${_num}=-Xmx${nexus_java_maxmemory}",
        match => "^wrapper.java.additional.${_num}=-Xmx",
      }
    } else {
      file_line {'set_nexus_java_xmx':
        path  => $java_config_file,
        line  => "-Xmx${nexus_java_maxmemory}",
        match => '^-Xmx',
      }
    }
  }
}
