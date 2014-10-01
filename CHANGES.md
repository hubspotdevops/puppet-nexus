puppet-nexus
===
1.3.1
---
* Fix the location of the Nexus work directory if $nexus_work_dir is not is not passed in.

1.3.0
---
* Updated download location of package.
* Make $nexus_work_dir configurable instead of using "${nexus_root}/${nexus::params::nexus_work_dir}" (/srv/sonatype-work)
* Make managing owner and perms of $nexus_work_dir configurable.
    * installations with large repos can turn this off to prevent overconsumption of resources.
    * This has been requested for ages.
* Set 'run_as_user' for service status to $nexus_user.  A bug from 2.7 days appears to be gone.
* Add rudimentary spec tests