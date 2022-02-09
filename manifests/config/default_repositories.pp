# @summary Removes the default repositories for maven and nuget
#
# @example
#   include nexus::config::default_repositories
#
class nexus::config::default_repositories {
  nexus_repository { [
    'maven-central',
    'maven-releases',
    'maven-public',
    'maven-snapshots',
    'nuget-group',
    'nuget-hosted',
    'nuget.org-proxy'
  ]:
    ensure => 'absent',
  }
}
