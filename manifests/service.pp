# === Class: nexus::service
#
# Maintains the Nexus service
#
class nexus::service {
  file { '/lib/systemd/system/nexus.service':
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('nexus/nexus.systemd.erb'),
  }
  -> service { 'nexus':
    ensure => running,
    name   => 'nexus',
    enable => true,
  }
}
