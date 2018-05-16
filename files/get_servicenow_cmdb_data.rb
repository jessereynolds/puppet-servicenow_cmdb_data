#!/usr/bin/env ruby
# Author: Jesse Reynolds <jesse.reynolds@puppet.com>

# Retrieves data from ServiceNow's CMDB, transforms and writes out to a JSON file
# for consumption by such things as Hiera

require 'base64'
require 'json'
require 'rest_client'
require 'tempfile'
require 'yaml'

def retrieve_data(endpoint, username, password, query_list, field_list, proxy)
  query  = "sysparm_query=#{query_list.join('^')}"
  fields = "sysparm_fields=#{field_list.join(',')}"
  url    = "#{endpoint}?#{query}&#{fields}"

  RestClient.proxy = proxy if proxy

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
  tmpfile.chmod(0644)
  tmpfile.close
  File.rename(tmpfile.path, path)
end

def log(message)
  puts "#{Time.now}: #{message}"
end

config_file = ARGV[0]
unless config_file
  raise 'No config file path specified'
end
config = YAML.load_file(config_file)

endpoint         = config['servicenow_endpoint']
username         = config['servicenow_username']
password         = config['servicenow_password']
query_list       = config['servicenow_query_list']
field_list       = config['servicenow_field_list']
key_prefix       = config['key_prefix']
json_output_file = config['json_output_file']
proxy_config     = config['proxy']

if proxy_config && proxy_config != ''
  unless proxy_config =~ %r{^[a-zA-Z\d\.:-]}
    raise("proxy specified has illegal characters: [#{proxy}]")
  end
  proxy = proxy_config
else
  proxy = nil
end

proxy_message = " with proxy: #{proxy}" if proxy
log("Retrieving data from #{endpoint}#{proxy_message} ...")
servers = retrieve_data(endpoint, username, password, query_list, field_list, proxy)
log("Received #{servers.length} server records. Transforming ... ")
transformed = transform_data(servers, key_prefix)
log("Writing out data to #{json_output_file} ...")
writeout(JSON.pretty_generate(transformed), json_output_file)
log('Done')
