# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include servicenow_cmdb_data
class servicenow_cmdb_data (
  String[1]           $servicenow_endpoint,
  String[1]           $servicenow_username,
  String[1]           $servicenow_password,
  String[1]           $appdir,
  String[1]           $user,
  Optional[String[1]] $proxy,
  Array[String[1]]    $servicenow_query_list,
  Array[String[1]]    $servicenow_field_list,
  Optional[String]    $key_prefix,
  Boolean             $manage_user,
) {
  $exedir  = "${appdir}/exe"
  $confdir = "${appdir}/config"
  $datadir = "${appdir}/data"
  $logdir  = "${appdir}/log"

  $script_path      = "${exedir}/get_servicenow_cmdb_data.rb"
  $script_config    = "${confdir}/get_servicenow_cmdb_data.yaml"
  $outfile_path     = "${logdir}/get_servicenow_cmdb_data.out"
  $json_output_file = "${datadir}/servicenow_cmdb_data.json"

  $ruby = '/opt/puppetlabs/puppet/bin/ruby'

  File {
    owner => $user,
    group => 'root',
    mode  => '0644',
  }

  if $manage_user {
    user { $user:
      ensure     => present,
      managehome => true,
    }
  }

  file { [$appdir, $exedir, $confdir, $datadir, $logdir]:
    ensure => directory,
  }

  # script
  file { 'get_servicenow_cmdb_data_script':
    path   => $script_path,
    source => 'puppet:///modules/servicenow_cmdb_data/get_servicenow_cmdb_data.rb',
  }

  file { 'get_servicenow_cmdb_data_config':
    path    => $script_config,
    content => epp('servicenow_cmdb_data/get_servicenow_cmdb_data.yaml.epp', {
      'servicenow_endpoint'   => $servicenow_endpoint,
      'servicenow_username'   => $servicenow_username,
      'servicenow_password'   => $servicenow_password,
      'servicenow_query_list' => $servicenow_query_list,
      'servicenow_field_list' => $servicenow_field_list,
      'key_prefix'            => $key_prefix,
      'json_output_file'      => $json_output_file,
      'proxy'                 => $proxy,
    }),
  }

  cron { 'get_servicenow_cmdb_data':
    command => "su - ${user} -c '${ruby} ${script_path} ${script_config}' > ${outfile_path} 2>&1",
    user    => 'root',
    hour    => '*',
    minute  => '*/5',
  }

}
