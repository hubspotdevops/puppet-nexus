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
  $revision,
  $download_site,
  $nexus_root,
  $nexus_home_dir,
  $nexus_user,
  $nexus_group,
) inherits nexus::params {

  $nexus_home      = "${nexus_root}/${nexus_home_dir}"
  $nexus_work      = "${nexus_root}/${nexus::params::nexus_work_dir}"

  $full_version    = "${version}-${revision}"

  $nexus_archive   = "nexus-${full_version}-bundle.tar.gz"
  $download_url    = "${download_site}/${nexus_archive}"
  $dl_file         = "${nexus_root}/${nexus_archive}"
  $nexus_home_real = "${nexus_root}/nexus-${full_version}"

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
  }

  file{ $nexus_home_real:
    ensure  => directory,
    owner   => $nexus_user,
    group   => $nexus_group,
    recurse => true,
    require => Exec[ 'nexus-untar']
  }

  file{ $nexus_work:
    ensure  => directory,
    owner   => $nexus_user,
    group   => $nexus_group,
    recurse => true,
    require => Exec[ 'nexus-untar']
  }

  file{ $nexus_home:
    ensure  => link,
    target  => $nexus_home_real,
    require => Exec['nexus-untar']
  }
}
