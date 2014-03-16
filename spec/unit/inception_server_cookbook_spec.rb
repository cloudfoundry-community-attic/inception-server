describe Inception::InceptionServerCookbook do
  include FileUtils
  include StdoutCapture
  include SettingsHelper

  before do
    setup_home_dir
    Fog.mock!
    setting "provider.name", "aws"
    setting "provider.credentials.aws_access_key_id", "aws_access_key_id"
    setting "provider.credentials.aws_secret_access_key", "aws_secret_access_key"
    setting "provider.region", "us-west-2"
    setting "git.name", "Dr Nic Williams"
    setting "git.email", "drnicwilliams@gmail.com"
    setting "inception.host", "host"
    setting "inception.provisioned.username", "user"
    setting "inception.provisioned.disk_device.internal", "/dev/abc"
  end

  let(:settings_dir) { File.expand_path("~/.inception_server") }
  let(:inception_server) { instance_double("Inception::InceptionServerCookbook", user_host: "user@host", private_key_path: "path/to/key") }
  subject { Inception::InceptionServerCookbook.new(inception_server, settings, settings_dir) }

  describe "in prepared settings dir" do
    before do
      attributes = '{"disk":{"mounted":true,"device":"/dev/abc"},"git":{"name":"Dr Nic Williams","email":"drnicwilliams@gmail.com"},"user":{"username":"user"},"fog":{"aws_access_key_id":"aws_access_key_id","aws_secret_access_key":"aws_secret_access_key"}}'
      cmd_arguments = "user@host -i path/to/key -j '#{attributes}' -r 'bosh_inception'"
      subject.should_receive(:sh).with("knife solo prepare #{cmd_arguments}")
      subject.prepare

      subject.should_receive(:sh).with("knife solo cook #{cmd_arguments}")
      subject.converge
    end

    it "creates Berksfile" do
      FileUtils.chdir(settings_dir) do
        File.should be_exists("Berksfile")
      end
    end

    it "copies in cookbook" do
      FileUtils.chdir(settings_dir) do
        File.should be_exists("cookbooks/bosh_inception/recipes/default.rb")
      end
    end
  end

  describe "after initial converge" do
    it "does not prepare/install chef again" do
      setting "cookbook.prepared", true
      cookbook = Inception::InceptionServerCookbook.new(inception_server, settings, settings_dir)

      attributes = '{"disk":{"mounted":true,"device":"/dev/abc"},"git":{"name":"Dr Nic Williams","email":"drnicwilliams@gmail.com"},"user":{"username":"user"},"fog":{"aws_access_key_id":"aws_access_key_id","aws_secret_access_key":"aws_secret_access_key"}}'
      cmd_arguments = "user@host -i path/to/key -j '#{attributes}' -r 'bosh_inception'"

      subject.should_receive(:sh).with("knife solo cook #{cmd_arguments}") # just to stub :sh
      subject.prepare
      subject.converge
    end
  end

end
