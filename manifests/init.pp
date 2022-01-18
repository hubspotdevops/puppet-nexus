# === Class: nexus
#
# Install and configure Sonatype Nexus
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
# class{ 'nexus':
#   var => 'foobar'
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
class nexus (
  Pattern[/\d+.\d+.\d+/] $version,
  String[1] $revision,
  Boolean $deploy_pro,
  Stdlib::HTTPUrl $download_site,
  Stdlib::HTTPUrl $pro_download_site,
  Optional[Stdlib::HTTPUrl] $download_proxy,
  Enum['unix', 'win64', 'mac', 'bundle'] $nexus_type,
  Stdlib::Absolutepath $nexus_root,
  String[1] $nexus_home_dir,
  Optional[Stdlib::Absolutepath] $nexus_work_dir,
  Boolean $nexus_work_dir_manage,
  String[1] $nexus_user,
  String[1] $nexus_group,
  Stdlib::Host $nexus_host,
  Stdlib::Port $nexus_port,
  Boolean $nexus_work_recurse,
  String[1] $nexus_context,
  Boolean $nexus_manage_user,
  Boolean $nexus_selinux_ignore_defaults,
  Optional[Stdlib::Absolutepath] $nexus_data_folder,
  Stdlib::Absolutepath $download_folder,
  Boolean $manage_config,
) {
  include stdlib

  if $nexus_work_dir != undef {
    $real_nexus_work_dir = $nexus_work_dir
  } else {
    if versioncmp($version, '3.1.0') >= 0 {
      $real_nexus_work_dir = "${nexus_root}/sonatype-work/nexus3"
    } else {
      $real_nexus_work_dir = "${nexus_root}/sonatype-work/nexus"
    }
  }

  # Determine if Nexus Pro should be deployed instead of OSS
  if ($deploy_pro) {
    $real_download_site = $pro_download_site
  } else {
    # Deploy OSS version. The default download_site, or whatever is
    # passed in is the correct location to download from
    $real_download_site = $download_site
  }

  if($nexus_manage_user){
    group { $nexus_group :
      ensure  => present
    }

    user { $nexus_user:
      ensure  => present,
      comment => 'Nexus User',
      gid     => $nexus_group,
      home    => $nexus_root,
      shell   => '/bin/sh', # required to start application via script.
      system  => true,
      require => Group[$nexus_group]
    }
  }

  class{ 'nexus::package':
    version               => $version,
    revision              => $revision,
    deploy_pro            => $deploy_pro,
    download_site         => $real_download_site,
    nexus_root            => $nexus_root,
    nexus_home_dir        => $nexus_home_dir,
    nexus_user            => $nexus_user,
    nexus_group           => $nexus_group,
    nexus_work_dir        => $real_nexus_work_dir,
    nexus_work_dir_manage => $nexus_work_dir_manage,
    nexus_work_recurse    => $nexus_work_recurse,
    notify                => Class['nexus::service']
  }

  if $manage_config {
    class{ 'nexus::config':
      nexus_root        => $nexus_root,
      nexus_home_dir    => $nexus_home_dir,
      nexus_host        => $nexus_host,
      nexus_port        => $nexus_port,
      nexus_context     => $nexus_context,
      nexus_work_dir    => $real_nexus_work_dir,
      nexus_data_folder => $nexus_data_folder,
      notify            => Class['nexus::service'],
      require           => Anchor['nexus::setup']
    }
  }

  class { 'nexus::service':
    nexus_home => "${nexus_root}/${nexus_home_dir}",
    nexus_user => $nexus_user,
  }

  anchor{ 'nexus::setup': } -> Class['nexus::package'] -> Class['nexus::config'] -> Class['nexus::Service'] -> anchor { 'nexus::done': }
}
