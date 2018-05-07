#!/usr/bin/env ruby
# Author: Jesse Reynolds <jesse.reynolds@puppet.com>

# Retrieves data from ServiceNow's CMDB, transforms and writes out to a JSON file
# for consumption by such things as Hiera

require 'base64'
require 'json'
require 'rest_client'
require 'tempfile'
require 'yaml'

def retrieve_data(endpoint, username, password, query_list, field_list)
  query = "sysparm_query=#{query_list.join('^')}"
  fields = "sysparm_fields=#{field_list.join(',')}"
  url = "#{endpoint}?#{query}&#{fields}"

  begin
    opts = {
      authorization: "Basic #{Base64.strict_encode64("#{username}:#{password}")}",
      accept:        'application/json',
    }
    response = RestClient.get(url.to_s, opts)
  rescue => e
    raise "Error, unable to retrieve data from ServiceNow CMDB API: #{e}"
  end

  JSON.parse(response)['result']
end

def transform_data(servers, key_prefix)
  servers.each_with_object({}) do |server, memo|
    if server['fqdn'] && server['fqdn'] != ''
      memo["#{key_prefix}#{server['fqdn'].downcase}"] = server
    end
  end
end

def writeout(data, path)
  tmpfile = Tempfile.new('temp', File.dirname(path))
  tmpfile.write(data)
  tmpfile.close
  File.rename(tmpfile.path, path)
end

config_file = ARGV[0]
config      = YAML.load_file(config_file)

endpoint         = config['servicenow_endpoint']
username         = config['servicenow_username']
password         = config['servicenow_password']
query_list       = config['servicenow_query_list']
field_list       = config['servicenow_field_list']
key_prefix       = config['key_prefix']
json_output_file = config['json_output_file']

servers = retrieve_data(endpoint, username, password, query_list, field_list)
transformed = transform_data(servers, key_prefix)
writeout(JSON.pretty_generate(transformed), json_output_file)
