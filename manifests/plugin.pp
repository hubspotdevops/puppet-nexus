# @summary Base class used by plugin classes
#
# @api private
#
class nexus::plugin {
  assert_private()

  $plugin_dir = "${nexus::package::install_dir}/deploy"

  file { $plugin_dir:
    ensure  => 'directory',
    backup  => false,
    force   => true,
    group   => 'root',
    owner   => 'root',
    purge   => true,
    recurse => true,
    require => Class['nexus::package']
  }
}
