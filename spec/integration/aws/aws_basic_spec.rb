require File.expand_path("../../../spec_helper", __FILE__)
require File.expand_path("../../../support/aws/aws_helpers", __FILE__)

describe "AWS deployment without Chef run" do
  include FileUtils
  include AwsHelpers

  if AwsHelpers.aws_credentials?
    before do
      prepare_aws("basic", aws_region, "next_deploy_actions.no_converge" => true)
    end
    after(:all) do
      destroy_test_constructs unless keep_after_test?
    end

    def aws_region
      ENV['AWS_REGION'] || "us-west-2"
    end

    it "creates an EC2 inception/microbosh with the associated resources" do
      create_manifest

      manifest_file = home_file(".bosh_inception", "settings.yml")
      File.should be_exists(manifest_file)

      cmd.deploy

      inception_servers = fog.servers.select { |s| s.tags["Name"] == test_server_name && s.ready? }
      inception_servers.size.should == 1

      server = inception_servers.first
      server.volumes.size.should == 2
      named_volume = server.volumes.select { |s| s.tags["Name"] == test_server_name }
      named_volume.should_not be_nil
    end
  else
    it "no AWS integration specs run; missing $AWS_ACCESS_KEY_ID etc"
  end
end