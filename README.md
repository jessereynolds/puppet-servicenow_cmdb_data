
# servicenow_cmdb_data

[![build status](https://travis-ci.org/jessereynolds/puppet-servicenow_cmdb_data.svg?branch=master)](https://travis-ci.org/jessereynolds/puppet-servicenow_cmdb_data)

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

```puppet
include servicenow_cmdb_data
```

and supply at a minimum the following keys in Hiera:

```yaml
servicenow_cmdb_data::servicenow_endpoint: https://exampleorg.service-now.com/api/now/table/cmdb_ci_server
servicenow_cmdb_data::servicenow_username: aaaaaaaa
servicenow_cmdb_data::servicenow_password: bbbbbbbb
```

Alternatively, use the resource syntax to include these parameters in your Puppet code:

```puppet
class { 'servicenow_cmdb_data':
  servicenow_endpoint => 'https://exampleorg.service-now.com/api/now/table/cmdb_ci_server',
  servicenow_username => 'aaaaaaaa',
  servicenow_password => 'bbbbbbbb',
}
```

## Reference

The `servicenow_cmdb_data` class has the following parameters:

- `servicenow_endpoint` - required - the URL of the ServiceNow cmdb_ci_server table API, eg `https://exampleorg.service-now.com/api/now/table/cmdb_ci_server`
- `servicenow_username` - required - ServiceNow API User
- `servicenow_password` - required - ServiceNow API Password
- `appdir` - default: `/opt/servicenow_cmdb_data` - directory to use - has sub-directories `exe`, `config`, `data`, `log`
- `user` - the system user to own the files and run the retrieval script as
- `proxy` - optional proxy URL to use
- `servicenow_query_list` - list of queries to include in the request to ServiceNow CMDB. Consult `data/default.yaml` for the defaut set of queries
- `servicenow_field_list` - list of fields to request ServiceNow CMDB to return for each object
- `servicenow_extra_args` - list of additional arguments to include in the ServiceNow CMDB URL, eg `sysparm_display_value=true`; default: undef
- `key_prefix` - string to prepend each key in the output JSON data file with, default: `cmdb_by_fqdn`. Can also be set to `false` to disable prefix
- `primary_key` - The attribute from the returned object that should serve as the primary and be the key for all results. e.g. a `primary_key` of `fqdn` would result in the data structure being a hash where the keys were the FQDNs of each server (Assuming we a querying server CIs). If this field is set to `false` the data is saved as it was returned from the API, in an array. Default: `fqdn`
- `manage_user` - whether to manage the system user specified in `user`, default: true
- `cron_hour` - value of the hour field for the cron job, default: `*` (no restriction on hour-of-day)
- `cron_minute` - value of the minute field for the cron job, default: `*/5` (run the job every 5 minutes)

## To Do

* Add a class that automatically creates external facts corresponding to each of the retrieved fields, prefacing them with something configurable eg "cmdb_" 
* Consider what kind of validation could be done before overwriting the JSON file, eg a large percentage difference in the number of servers (or requiring existence of at least x servers in the dump for it to be valid).
