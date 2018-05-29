require 'spec_helper'

describe 'servicenow_cmdb_data' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'servicenow_endpoint' => 'https://foo.example/api/now/table/cmdb_ci_server',
          'servicenow_username' => 'a',
          'servicenow_password' => 'a',
        }
      end

      it {
        is_expected.to contain_file('/opt/servicenow_cmdb_data').with(
          'ensure' => 'directory',
        )
      }

      it {
        is_expected.to contain_file('/opt/servicenow_cmdb_data/exe').with(
          'ensure' => 'directory',
        )
      }

      it {
        is_expected.to contain_file('/opt/servicenow_cmdb_data/config').with(
          'ensure' => 'directory',
        )
      }

      it {
        is_expected.to contain_file('get_servicenow_cmdb_data_script').with(
          'ensure' => 'file',
          'path'   => '/opt/servicenow_cmdb_data/exe/get_servicenow_cmdb_data.rb',
          'source' => 'puppet:///modules/servicenow_cmdb_data/get_servicenow_cmdb_data.rb',
        )
      }

      it {
        is_expected.to contain_file('get_servicenow_cmdb_data_config').with(
          'ensure' => 'file',
          'path'   => '/opt/servicenow_cmdb_data/config/get_servicenow_cmdb_data.yaml',
        ).with_content(%r{servicenow_username: a})
      }

      it {
        is_expected.to contain_file('/opt/servicenow_cmdb_data/data').with(
          'ensure' => 'directory',
        )
      }
    end
  end
end
