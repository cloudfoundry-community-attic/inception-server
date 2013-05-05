require File.expand_path("../../spec_helper", __FILE__)
require File.expand_path("../../support/aws/helpers", __FILE__)

require "fog"
require "active_support/core_ext/hash/keys"

describe "AWS deployment" do
  include FileUtils
  include SettingsHelper
  include AwsHelpers

  before do
    Fog.mock!
    Fog::Mock.reset
    @cmd = Bosh::Inception::Cli.new

    credentials = {aws_access_key_id: "ACCESS", aws_secret_access_key: "SECRET"}
    @fog_credentials = credentials.merge(provider: "AWS")
    create_manifest(credentials: credentials)
  end

  xit "creates an EC2 inception VM  with the associated resources" do
    @cmd.deploy
  end

end