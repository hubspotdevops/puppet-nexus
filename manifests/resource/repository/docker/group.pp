# @summary Resource to manage docker group repository
#
# @param ensure
#   Define if the resource should be created/present or deleted/absent.
# @param online
#   Allow incoming requests to this repository.
# @param storage_blob_store_name
#   The name of the blobstore inside of nexus repository manager to be used. We suggest to use a own blobstore for each
#   defined repository.
# @param storage_strict_content_type_validation
#   Validate that all content uploaded to this repository is of a MIME type appropriate for the repository format.
# @param group_member_names
#   Ordered array of the (docker) member to be grouped into this repository.
# @param docker_v1_enabled
#   Allow clients to use the V1 API to interact with this repository.
# @param docker_force_basic_auth
#   Allow anonymous docker pull ( Docker Bearer Token Realm required ).
# @param docker_http_port
#   Create an HTTP connector at specified port. Normally used if the server is behind a secure proxy.
# @param docker_https_port
#   Create an HTTPS connector at specified port. Normally used if the server is configured for https.
#
# @example
#   nexus::repository::docker::group { 'docker-group':
#      group_member_names => [
#         'docker-hosted',
#         'docker-docker.io',
#      ],
#   }
#
define nexus::resource::repository::docker::group (
  Enum['present', 'absent'] $ensure = 'present',
  Boolean $online = true,
  String[1] $storage_blob_store_name = $title,
  Boolean $storage_strict_content_type_validation = true,
  Array[String[1]] $group_member_names = [],
  Boolean $docker_v1_enabled = false,
  Boolean $docker_force_basic_auth = true,
  Optional[Stdlib::Port] $docker_http_port = undef,
  Optional[Stdlib::Port] $docker_https_port = undef,
) {
  case $ensure {
    'present': {
      Nexus_repository[$group_member_names] -> Nexus_repository[$title]
    }
    default: {
      Nexus_repository[$title] -> Nexus_repository[$group_member_names]
    }
  }

  nexus_repository { $title:
    ensure     => $ensure,
    format     => 'docker',
    type       => 'group',
    attributes => {
      'online'  => $online,
      'storage' => {
        'blobStoreName'               => $storage_blob_store_name,
        'strictContentTypeValidation' => $storage_strict_content_type_validation,
      },
      'group'   => {
        'memberNames' => $group_member_names,
      },
      'docker'  => {
        'v1Enabled'      => $docker_v1_enabled,
        'forceBasicAuth' => $docker_force_basic_auth,
        'httpPort'       => $docker_http_port,
        'httpsPort'      => $docker_https_port,
      },
    },
  }
}
