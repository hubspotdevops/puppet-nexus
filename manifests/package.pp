# === Class: nexus::package
#
# Install the Nexus package
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
# class{ 'nexus::package': }
#
# === Authors
#
# Tom McLaughlin <tmclaughlin@hubspot.com>
#
# === Copyright
#
# Copyright 2013 Hubspot
#
class nexus::package (
  $version,
  $download_site,
  $nexus_root,
  $nexus_home_dir,
  $nexus_user,
  $nexus_group,
  $nexus_work_dir,
) inherits nexus::params {

  $nexus_home      = "${nexus_root}/${nexus_home_dir}"
  $nexus_work      = "${nexus_work_dir}"


  $nexus_archive   = "nexus-${version}-bundle.tar.gz"
  $download_url    = "${download_site}/${nexus_archive}"
  $dl_file         = "${nexus_root}/${nexus_archive}"
  $nexus_home_real = "${nexus_root}/nexus-${version}"

  # NOTE: When setting version to 'latest' the site redirects to the latest
  # release. But, nexus-latest-bundle.tar.gz will already exist and
  # therefore the exec will never be triggered.  In reality 'latest' will
  # lock you to a version.
  #
  # NOTE:  I *think* this won't repeatedly download the file because it's
  # linked to an exec resource which won't be realized if a directory
  # already exists.
  wget::fetch{ $nexus_archive:
    source      => $download_url,
    destination => $dl_file,
    before      => Exec['nexus-untar'],
  }

  exec{ 'nexus-untar':
    command => "tar zxf ${dl_file}",
    cwd     => $nexus_root,
    creates => $nexus_home_real,
    path    => ['/bin','/usr/bin'],
    notify  => [
      Exec["${nexus_home_real}-ownership"],
      Exec["${nexus_work}-ownership"],
    ],
  }

  exec { "${nexus_home_real}-ownership" :
    command     => "/bin/chown -R ${nexus_user}:${nexus_group} ${nexus_home_real}",
    path        => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin',],
    refreshonly => true,
    logoutput   => true,
  }

  exec { "${nexus_work}-ownership" :
    command     => "/bin/chown -R ${nexus_user}:${nexus_group} ${nexus_work}",
    path        => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin',],
    refreshonly => true,
    logoutput   => true,
  }

  file{ $nexus_home:
    ensure  => link,
    target  => $nexus_home_real,
    require => Exec['nexus-untar']
  }
}
