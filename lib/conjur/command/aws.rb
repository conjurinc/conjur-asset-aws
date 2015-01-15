require 'conjur/command'

class Conjur::Command::AWS < Conjur::Command
  desc "Manage AWS integration features"
  command :aws do |aws|
    aws.desc "Manage links between AWS IAM and the Conjur host factory."
    aws.command :"token-link" do |roles|
      roles.desc "Create an AWS IAM role with permission to read a Conjur host factory token stored in S3."
      roles.command :create do |c|
        c.desc "Host factory token"
        c.arg_name "token"
        c.flag [ :"host-factory-token" ]
    
        c.desc "AWS bucket to contain the metadata file(s) (will be created if missing)"
        c.arg_name "bucket"
        c.flag [ :bucket ]
        
        c.action do |global_options, options, args|
          require "conjur-asset-host-factory"
          
          host_factory_token = options[:"host-factory-token"]
          host_factory_token = api.show_host_factory_token(host_factory_token) if host_factory_token
          bucket = options[:bucket]
            
          require "conjur/provisioner/aws"
          
          provisioner = Conjur::Provisioner::AWS::CreateRole.new
          provisioner.host_factory_token = host_factory_token if host_factory_token
          provisioner.bucket_name = bucket if bucket
          
          provisioner.validate
          provisioner.perform
          
          puts "Created Conjur IAM link #{provisioner.role_name}"
        end
      end
      
      roles.desc "Delete the IAM role and token file"
      roles.command :delete do |c|
        c.desc "Host factory"
        c.arg_name "id"
        c.flag [ :"host-factory" ]
    
        c.desc "AWS bucket to contain the metadata file(s) (will be created if missing)"
        c.arg_name "bucket"
        c.flag [ :bucket ]
        
        c.action do |global_options, options, args|
          require "conjur-asset-host-factory"
          
          host_factory = options[:"host-factory"]
          host_factory = api.host_factory host_factory if host_factory
          bucket = options[:bucket]
            
          require "conjur/provisioner/aws"
          
          provisioner = Conjur::Provisioner::AWS::DeleteRole.new
          provisioner.host_factory = host_factory if host_factory
          provisioner.bucket_name = bucket if bucket
          
          provisioner.validate
          provisioner.perform
          
          puts "Deleted Conjur IAM link #{provisioner.role_name}"
        end
      end
    end
  end
end
