module Conjur
  module Provisioner
    module AWS
      require 'aws-sdk-v1'
      
      module RoleHelper
        def validate
        end

        protected
        
        def aws_iam
          @aws_iam ||= ::AWS::IAM.new
        end
        
        def aws_role
          aws_iam.role[role_name]
        end
      end
      
      module BucketHelper
        attr_accessor :bucket_name
        
        def validate
          raise "bucket_name is missing" unless bucket_name
        end
        
        protected
        
        def aws_s3
          @aws_s3 ||= ::AWS::S3.new
        end
      end
      
      class DeleteRole
        include RoleHelper
        include BucketHelper

        attr_accessor :host_factory

        def role_name
          host_factory.id.parameterize
        end
        
        def token_file_name
          host_factory.id.parameterize
        end
        
        def validate
          super
          
          raise "host_factory is missing" unless host_factory
        end
        
        def perform
          delete_role
          delete_s3_token_file
        end
        
        protected
        
        def delete_role
          remove_params = {
            role_name: role_name,
            instance_profile_name: role_name
          }
          role_params = {
            role_name: role_name
          }
          instance_profile_params = {
            instance_profile_name: role_name
          }
  
          aws_iam.client.list_role_policies(role_params)[:policy_names].each do |policy|
            delete_policy_params = {
              role_name: role_name,
              policy_name: policy
            }
            aws_iam.client.delete_role_policy delete_policy_params
          end
          
          aws_iam.client.remove_role_from_instance_profile remove_params
          aws_iam.client.delete_instance_profile instance_profile_params
          aws_iam.client.delete_role role_params
        end
        
        def delete_s3_token_file
          bucket = aws_s3.buckets[bucket_name]
          bucket.objects[token_file_name].delete
        end
      end
      
      class CreateRole
        include RoleHelper
        include BucketHelper
        
        attr_accessor :host_factory_token
        
        def validate
          super
          
          raise "host_factory_token is missing" unless host_factory_token
        end

        def role_name
          host_factory.id.parameterize
        end
        
        def token_file_name
          host_factory.id.parameterize
        end
        
        # Creates an AWS IAM Role corresponding to the Layer. The Role can be assumed by EC2 instances.
        # Creates a system user (deputy) and adds it to the layer.
        # In S3, a file is created with the identity of the system user, along with other 
        # information needed by Conjur chef-solo. The file is in chef-solo JSON format.
        # It will be used by the [conjur-client Upstart job](https://github.com/conjur-cookbooks/conjur-client/blob/master/templates/default/conjur-bootstrap.conf.erb)
        # to finish the server configuration.
        def perform
          create_role
          create_s3_token_file
        end
      
        def host_factory
          host_factory_token.host_factory
        end
        
        def create_s3_token_file
          bucket = aws_s3.buckets[bucket_name]
          bucket = aws_s3.buckets.create(bucket_name) unless bucket.exists?
          
          bucket.objects[token_file_name].write host_factory_token.token
        end
        
        def create_role
          policy = {
            "Version" => "2012-10-17",
            "Statement" => [
              {
                "Effect" => "Allow",
                "Principal" => {
                  "Service" => "ec2.amazonaws.com"
                },
                "Action" => "sts:AssumeRole"
              }
            ]
          }
          role_params = {
            role_name: role_name,
            assume_role_policy_document: JSON.pretty_generate(policy)
          }
          instance_profile_params = {
            instance_profile_name: role_name
          }
  
          role = aws_iam.client.create_role role_params
          instance_profile = aws_iam.client.create_instance_profile instance_profile_params
          aws_iam.client.add_role_to_instance_profile role_name: role_name, instance_profile_name: role_name
          
          aws_iam.client.put_role_policy role_name: role_name, policy_name: 'read-bootstrap-file', policy_document: JSON.pretty_generate({
            "Statement" => [{
              "Effect" =>  "Allow",
              "Action" =>  "s3:GetObject",
              "Resource" =>  ["arn:aws:s3:::#{bucket_name}/#{token_file_name}"]
              }
            ]            
          })
        end
      end
    end
  end
end