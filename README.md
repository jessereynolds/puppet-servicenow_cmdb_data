
# servicenow_cmdb_data

This module installs a ruby script, config file, data directory, and cron job that retrieves selected fields from a ServiceNow CMDB instances' cmdb_ci_server table. It writes out the data in a json format consumable by Hiera. 


#### Table of Contents

2. [Setup](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with servicenow_cmdb_data](#beginning-with-servicenow_cmdb_data)
3. [Usage](#usage)
4. [Reference](#reference)

## Setup

### Setup Requirements

Required Ruby Gems (as tested with)

* rest-client (1.8.0)
** http-cookie (>= 1.0.2, < 2.0)
** mime-types (>= 1.16, < 3.0)
** netrc (~> 0.7)

### Beginning with servicenow_cmdb_data

Include the class on the Puppet Master (or Master of Masters)

```
include servicenow_cmdb_data
```

## Usage

## Reference
