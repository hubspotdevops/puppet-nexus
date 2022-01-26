# @summary
#   Install the Nexus Repository Manager package
#
# @api private
#
class nexus::package {
  assert_private()

  $nexus_archive   = "nexus-${nexus::version}-unix.tar.gz"
  $download_url    = "${nexus::download_site}/${nexus_archive}"
  $dl_file         = "${nexus::download_folder}/${nexus_archive}"
  $install_dir     = "${nexus::install_root}/nexus-${nexus::version}"

  extlib::mkdir_p($nexus::install_root)

  archive { $dl_file:
    source        => $download_url,
    extract       => true,
    extract_path  => $nexus::install_root,
    checksum_url  => "${download_url}.sha1",
    checksum_type => 'sha1',
    proxy_server  => $nexus::download_proxy,
    creates       => $install_dir,
    user          => 'root',
    group         => 'root',
  }

  # Prevent "Couldn't flush user prefs" error - https://issues.sonatype.org/browse/NEXUS-3671
  file { ["${nexus::install_root}/.java", "${nexus::install_root}/.java/.userPrefs"]:
    ensure => directory,
    owner  => $nexus::user,
    group  => $nexus::group,
    mode   => '0700',
  }

  if $nexus::purge_installations {
    File <| title == $nexus::install_root |> {
      ensure  => 'directory',
      backup  => false,
      force   => true,
      purge   => true,
      recurse => true,
      ignore  => [
        "nexus-${nexus::version}",
        'sonatype-work',
      ],
      require => [
        Archive[$dl_file],
      ],
      before  => [
        Class['nexus::service'],
      ],
    }
  }

  if $nexus::manage_work_dir {
    $directories = [
      $nexus::work_dir,
      "${nexus::work_dir}/etc",
      "${nexus::work_dir}/log",
      "${nexus::work_dir}/orient",
      "${nexus::work_dir}/tmp",
    ]

    file{ $directories:
      ensure  => directory,
      owner   => $nexus::user,
      group   => $nexus::group,
      require => Archive[ $dl_file ]
    }
  }
}
