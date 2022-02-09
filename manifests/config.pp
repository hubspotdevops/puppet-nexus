# @summary
#   Configure nexus repository manager
#
# @api private
#
class nexus::config {
  assert_private()

  contain nexus::config::properties

  if $nexus::manage_api_resources {
    contain nexus::config::admin
    contain nexus::config::device
    contain nexus::config::anonymous
    contain nexus::config::email

    if $nexus::purge_default_repositories {
      contain nexus::config::default_repositories
    }

    Class['nexus::config::device']
    -> Class['nexus::config::admin']
    -> Class['nexus::config::anonymous']
    -> Class['nexus::config::email']
  }
}
