require File.expand_path("../../spec_helper", __FILE__)
require File.expand_path("../../support/aws/helpers", __FILE__)

require "fog"
require "active_support/core_ext/hash/keys"

describe "AWS deployment" do
  include FileUtils
  include SettingsHelper
  include AwsHelpers

  before do
    setup_home_dir
    Fog.mock!
    Fog::Mock.reset
    @cmd = Bosh::Inception::Cli.new

    credentials = {aws_access_key_id: "ACCESS", aws_secret_access_key: "SECRET"}
    @fog_credentials = credentials.merge(provider: "AWS")
    create_manifest(credentials: credentials)
  end

  it "populates settings with git.name & git.email from ~/.gitconfig" do
    cmd.deploy
    settings.git.name.should == "Dr Nic Williams"
    settings.git.email.should == "drnicwilliams@gmail.com"
  end

  xit "creates an EC2 inception VM  with the associated resources" do
    cmd.deploy
  end

end