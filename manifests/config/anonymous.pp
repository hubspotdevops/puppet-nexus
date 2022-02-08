# @summary Manage if anonymous user have access to nexus repository manager
#
# @param enabled
#   Enable if anonymous/not logged in user have access to nexus repository manager.
# @param user_id
#   The nexus repository manager user id/name used to determine access.
# @param realm_name
#   Realm name used for anonymous user.
#
# @example
#   include nexus::config::anonymous
#
class nexus::config::anonymous (
  Boolean $enabled = false,
  String[1] $user_id = 'anonymous',
  String[1] $realm_name = 'NexusAuthorizingRealm',
) {
  nexus_setting { 'security/anonymous':
    attributes => {
      'enabled'   => $enabled,
      'userId'    => $user_id,
      'realmName' => $realm_name,
    },
  }
}
