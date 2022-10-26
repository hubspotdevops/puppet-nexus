# @summary Resource to manage yum hosted repository
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
# @param storage_write_policy
#   Controls if deployments of and updates to artifacts are allowed.
# @param component_proprietary_components
#   Components in this repository count as proprietary for namespace conflict attacks (requires Sonatype Nexus Firewall).
# @param repodata_depth
#   Set the depth of the directory in which the repodata/repomd.xml will be generated.
# @param deploy_policy
#   Set the deploy policy, whether or not a redeploy of rpm's is allowed.
#
# @example
#   nexus::resource::repository::yum::hosted { 'yum-hosted':
#     repodata_depth => 5,
#   }
#
define nexus::resource::repository::yum::hosted (
  Enum['present', 'absent'] $ensure = 'present',
  Boolean $online = true,
  String[1] $storage_blob_store_name = $title,
  Boolean $storage_strict_content_type_validation = true,
  Enum['ALLOW','ALLOW_ONCE','DENY'] $storage_write_policy = 'ALLOW_ONCE',
  Boolean $component_proprietary_components = true,
  Integer $repodata_depth = 0,
  Enum['STRICT','PERMISSIVE'] $deploy_policy = 'STRICT',
) {
  nexus_repository { $title:
    ensure     => $ensure,
    format     => 'yum',
    type       => 'hosted',
    attributes => {
      'online'    => $online,
      'storage'   => {
        'blobStoreName'               => $storage_blob_store_name,
        'strictContentTypeValidation' => $storage_strict_content_type_validation,
        'writePolicy'                 => $storage_write_policy,
      },
      'cleanup'   => undef,
      'component' => {
        'proprietaryComponents' => $component_proprietary_components,
      },
      'yum'       => {
        'repodataDepth' => $repodata_depth,
        'deployPolicy'  => $deploy_policy,
      },
    }
  }
}
