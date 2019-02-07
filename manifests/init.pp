# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include servicenow_cmdb_data
class servicenow_cmdb_data (
  String[1]                  $servicenow_endpoint,
  String[1]                  $servicenow_username,
  String[1]                  $servicenow_password,
  String[1]                  $appdir,
  String[1]                  $user,
  String[1]                  $group,
  Optional[String[1]]        $proxy,
  Array[String[1]]           $servicenow_query_list,
  Array[String[1]]           $servicenow_field_list,
  Optional[Array[String[1]]] $servicenow_extra_args,
  Optional[String]           $key_prefix,
  Optional[String]           $primary_key,
  Boolean                    $manage_user,
  String[1]                  $cron_hour,
  String[1]                  $cron_minute,
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
    group => $group,
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
    ensure => file,
    path   => $script_path,
    source => 'puppet:///modules/servicenow_cmdb_data/get_servicenow_cmdb_data.rb',
  }

  file { 'get_servicenow_cmdb_data_config':
    ensure  => file,
    path    => $script_config,
    group   => $group,
    mode    => '0640',
    content => epp('servicenow_cmdb_data/get_servicenow_cmdb_data.yaml.epp', {
      'servicenow_endpoint'   => $servicenow_endpoint,
      'servicenow_username'   => $servicenow_username,
      'servicenow_password'   => $servicenow_password,
      'servicenow_query_list' => $servicenow_query_list,
      'servicenow_field_list' => $servicenow_field_list,
      'servicenow_extra_args' => $servicenow_extra_args,
      'key_prefix'            => $key_prefix,
      'primary_key'           => $primary_key,
      'json_output_file'      => $json_output_file,
      'proxy'                 => $proxy,
    }),
  }

  cron { 'get_servicenow_cmdb_data':
    command => "su - ${user} -c '${ruby} ${script_path} ${script_config}' > ${outfile_path} 2>&1",
    user    => 'root',
    hour    => $cron_hour,
    minute  => $cron_minute,
  }

}
