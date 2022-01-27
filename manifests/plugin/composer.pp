# @summary Install the composer repository format plugin
#
# @param version
#   The composer repository format plugin version.
#
# @example
#   class { 'nexus':
#      version => '3.34.3-02',
#   }
#   class { 'nexus::plugin::composer':
#      version => '0.0.18',
#   }
#
class nexus::plugin::composer (
  Pattern[/\d+.\d+.\d+/] $version,
) {
  include nexus::plugin

  $composer_kar = "${nexus::plugin::plugin_dir}/nexus-repository-composer-bundle.kar"
  $download_url = "https://repo1.maven.org/maven2/org/sonatype/nexus/plugins/nexus-repository-composer/${version}/nexus-repository-composer-${version}-bundle.kar"

  archive { $composer_kar:
    cleanup       => false, # if this is true the downloaded file will be deleted
    checksum_type => 'sha1',
    checksum_url  => "${download_url}.sha1",
    creates       => $composer_kar,
    proxy_server  => $nexus::download_proxy,
    source        => $download_url,
    require       => Class['nexus::plugin'],
  }

  file { $composer_kar:
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Archive[$composer_kar],
    notify  => Class['nexus::service'],
  }
}
