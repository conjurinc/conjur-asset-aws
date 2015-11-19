#!/usr/bin/env ruby

require 'conjur/cli'
require 'optparse'
require 'erb'

def render_template(options)
	ssl_cert = ''
	File.open(options[:cert_path] ? options[:cert_path] : Conjur.configuration.cert_file, 'r') do |stream|
	    while(line = stream.gets)
	        ssl_cert << line
	    end

	    stream.close()
	end

	options[:ssl_cert] = ssl_cert

	template = ''
	File.open('create.erb', 'r') do |stream|
	    while(line = stream.gets)
	        template << line
	    end

	    stream.close()
	end

	renderer = ERB.new(template)
	puts renderer.result(binding)
end

def get_options()
	options = {};

	opts = OptionParser.new do |opts|
      opts.banner = "Usage: create.rb [options]"

      opts.separator ""
      opts.separator "Available options:"

      opts.on("-i", "--host-id HOST-ID", "REQUIRED - ID of the host to be created") do |host_id|
        options[:host_id] = host_id
      end

      opts.on("-r", "--role HOST-FACTORY", "REQUIRED - Name of the AWS IAM role with access to the token") do |role|
        options[:role] = role
      end

      opts.on("-b", "--bucket BUCKET", "REQUIRED - Name of the bucket the token is stored in") do |bucket|
        options[:bucket] = bucket
      end

      opts.on("-c", "--cert CERTIFICATE", "Path to the appliance certificate") do |cert_path|
        options[:cert_path] = cert_path
      end

      opts.on("-h", "--help") do
      	puts opts
      	exit
      end
    end.parse!

   	raise OptionParser::MissingArgument if options[:host_id].nil?
   	raise OptionParser::MissingArgument if options[:role].nil?
   	raise OptionParser::MissingArgument if options[:bucket].nil?

    return options;
end

render_template(get_options())

