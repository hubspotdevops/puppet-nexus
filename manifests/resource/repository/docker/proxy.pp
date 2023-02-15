# @summary Resource to manage docker proxy repository
#
# @param proxy_remote_url
#   Docker repository url like https://registry-1.docker.io.
# @param ensure
#   Define if the resource should be created/present or deleted/absent.
# @param http_client_auto_block
#   Auto-block outbound connections on the repository if remote peer is detected as unreachable/unresponsive.
# @param http_client_blocked
#   Block outbound connections on the repository.
# @param negative_cache_enabled
#   Cache responses for content not present in the proxied repository.
# @param negative_cache_time_to_live
#   How long to cache the fact that a file was not found in the repository (in minutes).
# @param online
#   Enable this repository in nexus repository manager that it can be used.
# @param proxy_content_max_age
#   Max age of content (packages).
# @param proxy_metadata_max_age
#   Max age of the repository metadata.
# @param storage_blob_store_name
#   The name of the blobstore inside of nexus repository manager to be used. We suggest to use a own blobstore for each
#   defined repository.
# @param storage_strict_content_type_validation
#   Validate that all content uploaded to this repository is of a MIME type appropriate for the repository format.
# @param storage_write_policy
#   Controls if deployments of and updates to artifacts are allowed.
# @param docker_v1_enabled
#   Allow clients to use the V1 API to interact with this repository.
# @param docker_force_basic_auth
#   Allow anonymous docker pull ( Docker Bearer Token Realm required ).
# @param docker_http_port
#   Create an HTTP connector at specified port. Normally used if the server is behind a secure proxy.
# @param docker_https_port
#   Create an HTTPS connector at specified port. Normally used if the server is configured for https.
# @param docker_subdomain
#   Use the following subdomain to make push and pull requests for this repository.
# @param docker_proxy_index_type
#   Docker index type. See https://help.sonatype.com/repomanager3/nexus-repository-administration/formats/docker-registry/proxy-repository-for-docker#ProxyRepositoryforDocker-ConfiguringaCorrectRemoteStorageandDockerIndexURLPair
# @param docker_proxy_index_url
#   If docker_proxy_index_type is CUSTOM you have to set the uri of the index api.
# @param docker_proxy_cache_foreign_layers
#   Allow Nexus Repository Manager to download and cache foreign layers.
# @param docker_proxy_foreign_layer_url_whitelist
#   Regular expressions used to identify URLs that are allowed for foreign layer requests.
#
# @example
#   nexus::repository::docker::proxy { 'docker-docker.io':
#      proxy_remote_url => 'https://registry-1.docker.io',
#   }
#
define nexus::resource::repository::docker::proxy (
  Stdlib::HTTPSUrl $proxy_remote_url,
  Enum['present', 'absent'] $ensure = 'present',
  Boolean $npm_remove_non_cataloged = false,
  Boolean $npm_remove_quarantined = false,
  Boolean $http_client_blocked = false,
  Boolean $http_client_auto_block = true,
  Boolean $negative_cache_enabled = true,
  Integer $negative_cache_time_to_live = 1440,
  Boolean $online = true,
  Integer $proxy_content_max_age = 1440,
  Integer $proxy_metadata_max_age = 1440,
  String[1] $storage_blob_store_name = $title,
  Boolean $storage_strict_content_type_validation = true,
  Enum['ALLOW','ALLOW_ONCE','DENY'] $storage_write_policy = 'ALLOW',
  Boolean $docker_v1_enabled = false,
  Boolean $docker_force_basic_auth = true,
  Optional[Stdlib::Port] $docker_http_port = undef,
  Optional[Stdlib::Port] $docker_https_port = undef,
  Optional[Stdlib::Fqdn] $docker_subdomain = undef,
  Enum['REGISTRY','HUB','CUSTOM'] $docker_proxy_index_type = 'HUB',
  Optional[Stdlib::HTTPSUrl] $docker_proxy_index_url = undef,
  Boolean $docker_proxy_cache_foreign_layers = false,
  Array[String[1]] $docker_proxy_foreign_layer_url_whitelist = [],
) {
  nexus_repository { $title:
    ensure     => $ensure,
    format     => 'docker',
    type       => 'proxy',
    attributes => {
      'online'          => $online,
      'storage'         => {
        'blobStoreName'               => $storage_blob_store_name,
        'strictContentTypeValidation' => $storage_strict_content_type_validation,
        'writePolicy'                 => $storage_write_policy
      },
      'cleanup'         => undef,
      'proxy'           => {
        'remoteUrl'      => $proxy_remote_url,
        'contentMaxAge'  => $proxy_content_max_age,
        'metadataMaxAge' => $proxy_metadata_max_age,
      },
      'negativeCache'   => {
        'enabled'    => $negative_cache_enabled,
        'timeToLive' => $negative_cache_time_to_live
      },
      'httpClient'      => {
        'blocked'        => $http_client_blocked,
        'autoBlock'      => $http_client_auto_block,
        'connection'     => {
          'retries'                 => undef,
          'userAgentSuffix'         => undef,
          'timeout'                 => undef,
          'enableCircularRedirects' => false,
          'enableCookies'           => false,
          'useTrustStore'           => false
        },
        'authentication' => undef
      },
      'routingRuleName' => undef,
      'docker'          => {
        'v1Enabled'      => $docker_v1_enabled,
        'forceBasicAuth' => $docker_force_basic_auth,
        'httpPort'       => $docker_http_port,
        'httpsPort'      => $docker_https_port,
        'subdomain'      => $docker_subdomain,
      },
      'dockerProxy'     => {
        'indexType'                => $docker_proxy_index_type,
        'indexUrl'                 => $docker_proxy_index_url,
        'cacheForeignLayers'       => $docker_proxy_cache_foreign_layers,
        'foreignLayerUrlWhitelist' => $docker_proxy_foreign_layer_url_whitelist,
      },
    }
  }
}
