require 'rubygems'
require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
end

require 'rspec'
require 'rspec/its'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

require 'conjur/api'
require 'conjur-asset-aws'
require 'conjur-asset-host-factory'
