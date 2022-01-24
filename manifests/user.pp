# @summary Manages the operation system user account which is used to start up the service
class nexus::user {
  if($nexus::manage_user){
    group { $nexus::group :
      ensure  => present
    }

    user { $nexus::user:
      ensure  => present,
      comment => 'Nexus User',
      gid     => $nexus::group,
      home    => $nexus::install_root,
      shell   => '/bin/sh', # required to start application via script.
      system  => true,
      require => Group[$nexus::group]
    }
  }
}
