# @summary Create puppet device config used to connect to the rest api
#
class nexus::config::device {
  assert_private()

  if extlib::has_module('puppetlabs/device_manager') {
    $password_unsensitive = if $nexus::config::admin::real_password =~ Sensitive[String] {
      $nexus::config::admin::real_password.unwrap
    } else {
      $nexus::config::admin::real_password
    }

    device_manager { 'localhost_nexus_rest_api':
      type        => 'nexus_rest_api',
      credentials => {
        address     => $nexus::host,
        port        => $nexus::port,
        username    => $nexus::config::admin::username,
        password    => $password_unsensitive,
        tmp_pw_file => "${nexus::work_dir}/admin.password",
      },
    }
  } else {
    fail('The nexus module requires puppetlabs/device_manager module for all rest api based operations.')
  }
}
