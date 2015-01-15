#
# Copyright (C) 2015 Conjur Inc
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
require 'spec_helper'

require 'conjur/provisioner/aws'

describe Conjur::Provisioner::AWS::CreateRole do
  let(:id) { 'org-1.0/the-factory' }
  let(:token) { double(:token) }
  let(:provisioner) {
    Conjur::Provisioner::AWS::CreateRole.new.tap do |p|
      p.host_factory_token = token
      p.bucket_name = 'the-bucket'
    end
  }
  
  context "attributes" do
    subject { provisioner }
    its(:bucket_name) { should == "the-bucket" }
    its(:role_name) { should == "org-1-0-the-factory" }
    its(:bootstrap_file_name) { should == "org-1-0-the-factory.json" }
  end
  context "provision" do
    let(:s3) { double(:s3) }
    let(:iam) { double(:iam) }
    before {
      provisioner.stub(:aws_s3).and_return s3
      provisioner.stub(:aws_iam).and_return iam
    }
    
    describe "#provision" do
      it "creates the role and bootstrap file" do
        provisioner.should_receive :create_role
        provisioner.should_receive :create_s3_bootstrap_file
        provisioner.perform
      end
    end
    
    describe "#create_role" do
      let(:role) { double(:role) }
      it "creates the role" do
        iam.stub_chain(:client, :create_role) do |args|
          args[:role_name].should == "org-1-0-the-factory"
          args[:assume_role_policy_document].should =~ /ec2.amazonaws.com/
        end.and_return role
        iam.stub_chain(:client, :create_instance_profile).with(instance_profile_name: "org-1-0-the-factory")
        iam.stub_chain(:client, :add_role_to_instance_profile).with(role_name: "org-1-0-the-factory", instance_profile_name: "org-1-0-the-factory")
        iam.stub_chain(:client, :put_role_policy) do |args|
          args[:role_name].should == 'org-1-0-the-factory'
          args[:policy_name].should == 'read-bootstrap-file'
          args[:policy_document].should =~ /arn:aws:s3:::the-bucket\/org-1-0-the-factory/
        end 
        
        provisioner.send :create_role
      end
    end
    describe "#create_s3_bootstrap_file" do
      let(:bucket) { double(:bucket) }
      let(:host_id) { "org-1.0/the-factory/ec2_instance" }
      let(:host) { double(:host, id: host_id, api_key: "the-api-key", roleid: "ci:host:#{host_id}") }
      it "creates the bootstrap file" do
        Conjur::API.any_instance.should_receive(:create_host).with(id: host_id).and_return host
        s3.stub_chain(:buckets, :[]).and_return double(:bucket, exists?: false)
        s3.stub_chain(:buckets, :create).with("the-bucket").and_return bucket
        bucket.stub_chain(:objects, :[], :write).with(/the-api-key/)
        provisioner.should_receive(:add_host).with host.roleid
        
        provisioner.send :create_s3_bootstrap_file
      end
    end
  end
end