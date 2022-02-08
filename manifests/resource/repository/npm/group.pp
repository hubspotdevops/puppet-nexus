# @summary Resource to manage npm group repository
#
# @param ensure
#   Define if the resource should be created/present or deleted/absent.
# @param online
#   Enable this repository in nexus repository manager that it can be used.
# @param storage_blob_store_name
#   The name of the blobstore inside of nexus repository manager to be used. We suggest to use a own blobstore for each
#   defined repository.
# @param storage_strict_content_type_validation
#   Validate that all content uploaded to this repository is of a MIME type appropriate for the repository format.
# @param group_member_names
#   Ordered array of the (npm) member to be grouped into this repository.
#
# @example
#   nexus::repository::npm::group { 'npm-group':
#      group_member_names => [
#         'npm-hosted',
#         'npm-npmjs.org',
#      ],
#   }
#
define nexus::resource::repository::npm::group (
  Enum['present', 'absent'] $ensure = 'present',
  Boolean $online = true,
  String[1] $storage_blob_store_name = $title,
  Boolean $storage_strict_content_type_validation = true,
  Array[String[1]] $group_member_names = [],
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
    format     => 'npm',
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
    },
  }
}
