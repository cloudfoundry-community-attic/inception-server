require File.expand_path("../../support/aws/aws_helpers", __FILE__)

require "fog"

describe "AWS deployment deletion" do
  include FileUtils
  include StdoutCapture
  include SettingsHelper
  include AwsHelpers

  before do
    setup_home_dir
    Fog.mock!
    @cmd = Inception::Cli.new
    setting "provider.name", "aws"
    setting "provider.credentials.aws_access_key_id", "aws_access_key_id"
    setting "provider.credentials.aws_secret_access_key", "aws_secret_access_key"
    setting "provider.region", "us-west-2"
    setting "next_deploy_actions.no_converge", true
    capture_stdout { @cmd.deploy }
  end

  def perform_delete
    config = { shell: Thor::Base.shell.new }
    capture_stdout { @cmd.class.send(:dispatch, :delete, [], {:"non-interactive" => true}, config) }
  end

  it "clears out settings.yml" do
    perform_delete
    settings = ReadWriteSettings.new(File.expand_path("~/.bosh_inception/settings.yml"))
    settings.exists?("provider").should_not be_nil
    settings.exists?("git").should_not be_nil
    settings.exists?("inception.provisioned.disk_device").should be_nil
    settings.exists?("inception.provisioned.host").should be_nil
    settings.exists?("inception.provisioned.ip_address").should be_nil
    settings.exists?("inception.key_pair").should be_nil
    settings.exists?("inception.provisioned.disk_device").should be_nil
  end
end