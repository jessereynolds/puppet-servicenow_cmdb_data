# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include servicenow_cmdb_data
class servicenow_cmdb_data (
  String[1] $servicenow_cmdb_endpoint,
  String[1] $appdir = '/opt/servicenow_cmdb_data',
  String[1] $user   = 'snowdata',
) {
  $exedir  = "${appdir}/exe"
  $confdir = "${appdir}/config"
  $datadir = "${appdir}/data"

  $script_path   = "${exedir}/get_servicenow_cmdb_data.rb"
  $script_config = "${confdir}/get_servicenow_cmdb_data.yaml"

  File {
    owner => $user,
    group => 'root',
    mode  => '0644',
  }

  file { [$appdir, $exedir, $confdir, $datadir]:
    ensure => directory,
  }

  # script
  file { 'get_servicenow_cmdb_data_script':
    path   => $script_path,
    source => 'puppet:///modules/servicenow_cmdb_data/get_servicenow_cmdb_data.rb',
  }

  # config
  file { 'get_servicenow_cmdb_data_config':
    path    => $script_config,
    content => epp('servicenow_cmdb_data/get_servicenow_cmdb_data.yaml.epp'),
  }

  # cron
  cron { 'get_servicenow_cmdb_data':
    command => "${script_path} ${script_config}",
    user    => $user,
    hour    => '*',
    minute  => '*/10',
  }

}
