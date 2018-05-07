require 'spec_helper'

describe 'servicenow_cmdb_data' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      appdir = (os_facts[:kernel] == 'windows') ? 'c:\servicenow_cmdb_data' : '/opt/servicenow_cmdb_data'

      let(:facts) { os_facts }
      let(:params) do
        {
          'servicenow_cmdb_endpoint' => 'https://foo.example/api/now/table/cmdb_ci_server',
          'appdir' => appdir,
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
        is_expected.to contain_file('/opt/servicenow_cmdb_data/data').with(
          'ensure' => 'directory',
        )
      }
    end
  end
end
