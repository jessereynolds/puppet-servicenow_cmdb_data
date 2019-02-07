#!/usr/bin/env ruby
# Author: Jesse Reynolds <jesse.reynolds@puppet.com>

# Retrieves data from ServiceNow's CMDB, transforms and writes out to a JSON file
# for consumption by such things as Hiera

require 'base64'
require 'json'
require 'rest_client'
require 'tempfile'
require 'yaml'
require 'uri'

# Class for making queries against SNOW, means we don't have to keep passing
# usernames and passwords around. It also caches values so that if we are doing
# recursive queries that return the same date we don't wast bandwidth
class ServiceNow # rubocop:disable Style/ClassAndModuleChildren
  # Manages connections
  class Connection
    attr_accessor :username
    attr_accessor :password
    attr_accessor :endpoint
    attr_accessor :proxy

    def initialize(opts = {})
      @endpoint = opts[:endpoint]
      @username = opts[:username]
      @password = opts[:password]
      @proxy    = opts[:proxy]
      @cache    = {}
    end

    # Run a ServiceNow query with a given set of params
    def query(params = {})
      uri = URI(endpoint)
      uri.query = params_to_query(params)

      get(uri)
    end

    # Do a direct get request against an arbitrary URI. This uses the supplied
    # username, password and proxy
    def get(uri)
      return @cache[uri] if cached?(uri)

      begin
        RestClient.proxy = proxy if proxy
        response = RestClient.get(uri.to_s, client_opts)
      rescue => e
        raise "Error, unable to retrieve data from ServiceNow CMDB API: #{e}"
      end

      # Cache the result in case we are asked again
      result = JSON.parse(response)['result']
      cache(uri, result)
    end

    private

    def cache(uri, result)
      @cache[uri] = result
      result
    end

    def cached?(uri)
      @cache.key?(uri)
    end

    def params_to_query(params)
      params.map { |param, value| "#{param}=#{value}" }.join('&')
    end

    def client_opts
      opts = {}
      opts[:accept] = 'application/json'
      opts[:authorization] = "Basic #{Base64.strict_encode64("#{username}:#{password}")}" if username && password
      opts
    end
  end
end

def retrieve_data(connection, query_list = nil, field_list = nil, extra_args = nil)
  params = {}
  params['sysparm_query']  = query_list.join('^') if query_list
  params['sysparm_fields'] = field_list.join(',') if field_list
  if extra_args
    extra_args.each do |string|
      arg, val = string.split('=')
      params[arg] = val
    end
  end

  connection.query(params)
end

def transform_data(data, key_prefix = nil, primary_key = nil)
  data.map! do |ci|
    final_object = {}
    # Loop over each CI and transform the key name to be friendly and also
    # query the relationship if there is one
    ci.each do |key, value|
      # Clean any nastyness from the key name
      new_key = key.downcase.gsub(%r{['"\.\*]}, '_')

      # Check if the value is a link and if so resolve it
      if value.is_a?(Hash) && value.key?('link')
        puts "Found relationship for #{key}, querying: #{value['link']}"
        value = @connection.get(value['link'])
      end

      final_object[new_key] = value
    end

    final_object
  end

  if primary_key
    # If we have passed a primary_key then we want the output as a hash
    data.group_by { |ci| "#{key_prefix}#{ci[primary_key].downcase}" }
  else
    data
  end
end

def writeout(data, path)
  tmpfile = Tempfile.new('temp', File.dirname(path))
  tmpfile.write(data)
  tmpfile.chmod(0o644)
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
extra_args       = config['servicenow_extra_args']
key_prefix       = config['key_prefix']
json_output_file = config['json_output_file']
proxy_config     = config['proxy']
primary_key      = config['primary_key']

if proxy_config && proxy_config != ''
  unless proxy_config =~ %r{^[a-zA-Z\d\.:-]}
    raise("proxy specified has illegal characters: [#{proxy}]")
  end
  proxy = proxy_config
else
  proxy = nil
end

@connection = ServiceNow::Connection.new(
  endpoint: endpoint,
  username: username,
  password: password,
  proxy: proxy_config,
)
proxy_message = " with proxy: #{proxy}" if proxy
log("Retrieving data from #{endpoint}#{proxy_message} ...")
servers = retrieve_data(@connection, query_list, field_list, extra_args)
log("Received #{servers.length} server records. Transforming ... ")
transformed = transform_data(servers, key_prefix, primary_key)
log("Writing out data to #{json_output_file} ...")
writeout(JSON.pretty_generate(transformed), json_output_file)
log('Done')
