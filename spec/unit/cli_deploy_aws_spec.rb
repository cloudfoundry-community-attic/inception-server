require File.expand_path("../../spec_helper", __FILE__)
require File.expand_path("../../support/aws/aws_helpers", __FILE__)

require "fog"
require "active_support/core_ext/hash/keys"

describe "AWS deployment" do
  include FileUtils
  include StdoutCapture
  include SettingsHelper
  include AwsHelpers

  before do
    setup_home_dir
    Fog.mock!
    Fog::Mock.reset
    @cmd = Bosh::Inception::Cli.new
    @credentials = {aws_access_key_id: "ACCESS", aws_secret_access_key: "SECRET"}
    @fog_credentials = @credentials.merge(provider: "AWS")
  end

  describe "with simple manifest" do
    before do
      create_manifest(credentials: @credentials)
      cmd.stub(:converge_cookbooks)
      capture_stdout { cmd.deploy }
      # cmd.deploy
    end

    it "populates settings with git.name & git.email from ~/.gitconfig" do
      settings.git.name.should == "Dr Nic Williams"
      settings.git.email.should == "drnicwilliams@gmail.com"
    end

    it "creates an elastic IP automatically and assigns to settings.inception.ip_address" do
      settings.inception.ip_address.should_not be_nil
    end

    it "creates AWS key pair and assigns to inception.key_pair.name / private_key" do
      settings.inception.key_pair.name.should == "inception"
      settings.inception.key_pair.private_key.should_not be_nil
    end

    it "stores private key in local file" do
      local_private_key = File.expand_path("~/.bosh_inception/ssh/inception")
      File.should be_exist(local_private_key)
      File.read(local_private_key).should == settings.inception.key_pair.private_key
    end

    it "provisions inception VM" do
      settings.inception.flavor.should == "m1.small"
      settings.inception.disk_size.should == 16
      settings.inception.image_id.should == "ami-bf1d8a8f" # us-west-2 13.04 AMI
      settings.inception.security_groups.should == ["ssh"]

      settings.inception.provisioned.username.should == "ubuntu"
      settings.inception.provisioned.host.should_not be_nil
      settings.inception.provisioned.server_id.should_not be_nil

      settings.inception.provisioned.disk_device.external.should == "/dev/sdf"
      settings.inception.provisioned.disk_device.internal.should == "/dev/xvdf"
    end

  end

  describe "converge inception VM if it fails midway" do
    it "does not provision another IP address if already allocated" do
      create_manifest(credentials: @credentials, "inception.ip_address" => "1.2.3.4")
      capture_stdout { cmd.deploy }
      settings.inception.ip_address.should == "1.2.3.4"
    end

    it "provisions another server if server_id id unknown" do
      create_manifest(credentials: @credentials, "inception.provisioned.server_id" => "i-UNKNOWN")
      capture_stdout { cmd.deploy }
      settings.inception.provisioned.server_id.should_not == "i-UNKNOWN"
    end
  end
end