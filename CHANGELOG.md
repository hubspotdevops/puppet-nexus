# Changelog

All notable changes to this project will be documented in this file.

## 1.8.0

* Replaced obsolete `puppet/wget` module by [puppet/archive](https://github.com/voxpupuli/puppet-archive)
* Nexus artifact downloads get always validated against published md5 sum - md5sum parameter is currently getting ignored

## 1.7.5

* Extended test suite to puppet 5 and puppet 6
* Fix test suite
* Updated README.md and metadata.json
* Added .sync.yml for `pdk update`

## 1.7.4

* Replaced obsolete `maestrodev/wget` module by [puppet/wget](https://github.com/voxpupuli/puppet-wget)
* Initial `pdk convert` changes
* Adjust module requirements in [metadata.json](metadata.json)

## 1.7.1

* Support for validating the md5 checksum of the Nexus package file. https://github.com/hubspotdevops/puppet-nexus/pull/80

## 1.7.0

* Support for CentOS and RedHat versions using systemd: https://github.com/hubspotdevops/puppet-nexus/pull/76

## 1.6.1

* Support for older versions of Ubuntu: https://github.com/hubspotdevops/puppet-nexus/pull/70

## 1.6.0

* Support for Ubuntu https://github.com/hubspotdevops/puppet-nexus/pull/67

## 1.5.0

* Support for Puppet 4.5.2 https://github.com/hubspotdevops/puppet-nexus/pull/65

## 1.4.0

* Support for Nexus 3
* Support for Debian 8

## 1.3.1

* Fix the location of the Nexus work directory if $nexus_work_dir is not is not passed in.

## 1.3.0

* Updated download location of package.
* Make $nexus_work_dir configurable instead of using "${nexus_root}/${nexus::params::nexus_work_dir}" (/srv/sonatype-work)
* Make managing owner and perms of $nexus_work_dir configurable.
  * installations with large repos can turn this off to prevent overconsumption of resources.
  * This has been requested for ages.
* Set 'run_as_user' for service status to $nexus_user.  A bug from 2.7 days appears to be gone.
* Add rudimentary spec tests