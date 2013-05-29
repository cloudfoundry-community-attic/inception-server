# Copyright (c) 2012-2013 Stark & Wayne, LLC

require "fog"

# Specs for the aws provider
describe Inception::Providers do
  include FileUtils
  include StdoutCapture

  describe "AWS" do
    before { Fog.mock! }
    let(:provider_attributes) do
      {
        "name" => "aws",
        "region" => "us-west-2",
        "credentials" => {
          "aws_access_key_id"  => 'MOCK_AWS_ACCESS_KEY_ID',
          "aws_secret_access_key"  => 'MOCK_AWS_SECRET_ACCESS_KEY'
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
      it "should open a range of UDP ports" do
        capture_stdout do
          ports = { ssh: { protocol: "udp", ports: (60000..600050) } }
          subject.create_security_group("sg-range-udp-name", "sg-range-udp-name", ports)
          created_sg = fog_compute.security_groups.get("sg-range-udp-name")
          created_sg.ip_permissions.should == [
            { 
              "ipProtocol"=>"udp",
              "fromPort"=>60000, 
              "toPort"=>600050, 
              "groups"=>[], 
              "ipRanges"=>[ { "cidrIp"=>"0.0.0.0/0" } ] 
            }
          ]
        end
      end
      it "should open a range of ICMP ports" do
        capture_stdout do
          ports = { ping: { protocol: "icmp", ports: (3..4) } }
          subject.create_security_group("sg-range-icmp-name", "sg-range-icmp-name", ports)
          created_sg = fog_compute.security_groups.get("sg-range-icmp-name")
          created_sg.ip_permissions.should == [
            { 
              "ipProtocol"=>"icmp",
              "fromPort"=>3, 
              "toPort"=>4, 
              "groups"=>[], 
              "ipRanges"=>[ { "cidrIp"=>"0.0.0.0/0" } ] 
            }
          ]
        end
      end
      it "should open not open ports if they are already open" do
        capture_stdout do
          subject.create_security_group("sg2", "", { ssh: { protocol: "udp", ports: (60000..600050) } })
          subject.create_security_group("sg2", "", { ssh: { protocol: "udp", ports: (60010..600040) } })
          subject.create_security_group("sg2", "", { ssh: { protocol: "udp", ports: (60000..600050) } })
          created_sg = fog_compute.security_groups.get("sg2")
          created_sg.ip_permissions.should == [
            { 
              "ipProtocol"=>"udp",
              "fromPort"=>60000, 
              "toPort"=>600050, 
              "groups"=>[], 
              "ipRanges"=>[ { "cidrIp"=>"0.0.0.0/0" } ] 
            }
          ]
        end
      end
      xit "should open ports even if they are already open for a different protocol" do
        capture_stdout do
          subject.create_security_group("sg3", "", { ssh: { protocol: "udp", ports: (60000..600050) } })
          subject.create_security_group("sg3", "", { ssh: { protocol: "tcp", ports: (60000..600050) } })
          created_sg = fog_compute.security_groups.get("sg3")
          created_sg.ip_permissions.should == [
            { 
              "ipProtocol"=>"udp",
              "fromPort"=>60000, 
              "toPort"=>600050, 
              "groups"=>[], 
              "ipRanges"=>[ { "cidrIp"=>"0.0.0.0/0" } ] 
            },
            { 
              "ipProtocol"=>"tcp",
              "fromPort"=>60000, 
              "toPort"=>600050, 
              "groups"=>[], 
              "ipRanges"=>[ { "cidrIp"=>"0.0.0.0/0" } ] 
            }
          ]
        end
      end
      xit "should open ports even if they are already open for a different ip_range" do
        capture_stdout do
          default_ports = {
             all_internal_tcp: { protocol: "tcp", ip_range: "1.1.1.1/32", ports: (0..65535) }
          }
          subject.create_security_group("sg6", "sg6", default_ports)
          subject.create_security_group("sg6", "sg6", { mosh: { protocol: "tcp", ports: (15..30) } })
          created_sg = fog_compute.security_groups.get("sg6")
          created_sg.ip_permissions.should == [
            { 
              "ipProtocol"=>"tcp",
              "fromPort"=>0, 
              "toPort"=>65535, 
              "groups"=>[], 
              "ipRanges"=>[ { "cidrIp"=>"1.1.1.1/32" } ] 
            },
            { 
              "ipProtocol"=>"tcp",
              "fromPort"=>15, 
              "toPort"=>30, 
              "groups"=>[], 
              "ipRanges"=>[ { "cidrIp"=>"0.0.0.0/0" } ] 
            }
          ]
        end
      end
      xit "should open ports on the default sg" do
        capture_stdout do
          subject.create_security_group("default", "default", { mosh: { protocol: "tcp", ports: (15..30) } })
          created_sg = fog_compute.security_groups.get("default")
          expected_rule = { 
              "ipProtocol"=>"tcp",
              "fromPort"=>15, 
              "toPort"=>30, 
              "groups"=>[], 
              "ipRanges"=>[ { "cidrIp"=>"0.0.0.0/0" } ] 
            }
          created_sg.ip_permissions.should include expected_rule
        end
      end
      #AWS allows overlapping port ranges, and it makes it easier to see the separate "rules" that were added
      xit "should create overlapping port ranges" do
        capture_stdout do
          subject.create_security_group("sg4", "", { ssh: { protocol: "udp", ports: (10..20) } })
          subject.create_security_group("sg4", "", { ssh: { protocol: "udp", ports: (15..30) } })
          created_sg = fog_compute.security_groups.get("sg4")
          created_sg.ip_permissions.should == [
            { 
              "ipProtocol"=>"udp",
              "fromPort"=>10, 
              "toPort"=>20, 
              "groups"=>[], 
              "ipRanges"=>[ { "cidrIp"=>"0.0.0.0/0" } ] 
            },
            { 
              "ipProtocol"=>"udp",
              "fromPort"=>15, 
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
