# @summary
#   Configure nexus repository manager
#
# @api private
#
class nexus::config {
  assert_private()
  # Per the Sonatype documentation the custom nexus properties file is
  # {karaf.data}/etc/nexus.properties where {karaf.data} is the work dir
  $nexus_properties_file = "${nexus::work_dir}/etc/nexus.properties"

  # Nexus >=3.x do no necesarily have a properties file in place to
  # modify. Make sure that there is at least a minmal file there
  file { $nexus_properties_file:
    ensure => present,
  }

  file_line { 'nexus-application-host':
    path  => $nexus_properties_file,
    match => '^application-host=',
    line  => "application-host=${nexus::host}"
  }

  file_line { 'nexus-application-port':
    path  => $nexus_properties_file,
    match => '^application-port=',
    line  => "application-port=${nexus::port}"
  }

  file_line { 'nexus-work':
    path  => $nexus_properties_file,
    match => '^nexus-work=',
    line  => "nexus-work=${nexus::work_dir}"
  }
}
