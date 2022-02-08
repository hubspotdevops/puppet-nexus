# @summary Resource to manage (local) file blobstore
#
# @param ensure
#   Define if the resource should be created/present or deleted/absent
# @param path
#   The (local) path of the disk where the content of the blobstore should be stored. Non absolute paths will use the
#   working directory as base path. The nexus (service) user needs write access to this path.
#
# @example
#   nexus::blobstore::file { 'apt-hosted': }
#
define nexus::resource::blobstore::file (
  Enum['present', 'absent'] $ensure = 'present',
  Variant[Stdlib::Absolutepath, String[1]] $path = $title,
) {
  nexus_blobstore { $title:
    ensure     => $ensure,
    type       => 'file',
    attributes => {
      softQuota => undef,
      path      => $path,
    },
    require    => [
      Class['nexus::service'],
    ],
  }
}
