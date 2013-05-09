require File.expand_path("../../../spec_helper", __FILE__)
require File.expand_path("../../../support/aws/aws_helpers", __FILE__)

describe "AWS deployment using gems and publish stemcells" do
  include FileUtils
  include AwsHelpers

  before { prepare_aws("basic", aws_region) }
  after { destroy_test_constructs unless keep_after_test? }

  def aws_region
    ENV['AWS_REGION'] || "us-west-2"
  end

  it "creates an EC2 inception/microbosh with the associated resources" do
    create_manifest

    manifest_file = home_file(".bosh_inception", "manifest.yml")
    File.should be_exists(manifest_file)

    cmd.deploy

    inception_servers = fog.servers.select {|s| s.tags["Name"] == test_server_name}
    inception_servers.size.should == 1

    inception_servers.volumes.size.should == 2
    named_volume = inception_servers.volumes.select {|s| s.tags["Name"] == test_server_name}
    named_volume.should_not be_nil
  end

end