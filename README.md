
# servicenow_cmdb_data

This module installs a ruby script, config file, data directory, and cron job that retrieves selected fields from a ServiceNow CMDB instances' cmdb_ci_server table. It writes out the data in a json format consumable by Hiera.


#### Table of Contents

2. [Setup](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with servicenow_cmdb_data](#beginning-with-servicenow_cmdb_data)

## Setup

### Setup Requirements

Required Ruby Gems (as tested with)

* rest-client (1.8.0)
* http-cookie (1.0.3)
* domain_name (0.5.20180417)
* unf 0.1.4
* unf_ext 0.0.7.5
* mime-types (2.99.3)
* netrc (0.11.0)

Note that some of the above gems require development tools to be installed for the `gem install` step to succeed as they require native code to be compiled (eg unf, unf_ext).

### Beginning with servicenow_cmdb_data

Include the class on the Puppet Master (or Master of Masters)

```
include servicenow_cmdb_data
```

