# Copyright (c) 2012-2013 Stark & Wayne, LLC

require "fog"

# Specs for the aws provider
describe Inception::Providers do
  include FileUtils
  include StdoutCapture

  describe "OpenStack" do
    before { Fog.mock! }
    let(:provider_attributes) do
      {
        "name" => "openstack",
        "credentials"=>{
          "openstack_username"=>"USERNAME", "openstack_api_key"=>"PASSWORD",
          "openstack_tenant"=>"TENANT", "openstack_auth_url"=>"TOKENURL/tokens",
          "openstack_region"=>""
        }
      }
    end
    subject { Inception::Providers.provider_client(provider_attributes) }
    let(:fog_compute) { subject.fog_compute }

    describe "create security group" do
      it "should open a single TCP port on a security group" do
        capture_stdout do
          ports = { ssh: 22 }
          subject.create_security_group("sg1-name", "sg1-desc", ports)
          p fog_compute.security_groups
          created_sg = fog_compute.security_groups.get("sg1-name")
          created_sg.name.should == "sg1-name"
          created_sg.description.should == "sg1-desc"
          created_sg.ip_permissions.should == [
            {
              "ipProtocol"=>"tcp",
              "fromPort"=>22,
              "toPort"=>22,
              "groups"=>[],
              "ipRanges"=>[ { "cidrIp"=>"0.0.0.0/0" } ]
            }
          ]
        end
      end
      it "should open a range of TCP ports" do
        capture_stdout do
          ports = { ssh: (22..30) }
          subject.create_security_group("sg-range-name", "sg-range-desc", ports)
          created_sg = fog_compute.security_groups.get("sg-range-name")
          created_sg.ip_permissions.should == [
            {
              "ipProtocol"=>"tcp",
              "fromPort"=>22,
              "toPort"=>30,
              "groups"=>[],
              "ipRanges"=>[ { "cidrIp"=>"0.0.0.0/0" } ]
            }
          ]
        end
      end
    end
  end
end
