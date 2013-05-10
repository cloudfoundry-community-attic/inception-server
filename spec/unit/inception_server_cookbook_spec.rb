describe Bosh::Inception::InceptionServerCookbook do
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

  let(:settings_dir) { File.expand_path("~/.bosh_inception") }
  let(:inception_server) { mock(user_host: "user@host", private_key_path: "path/to/key") }
  subject { Bosh::Inception::InceptionServerCookbook.new(inception_server, settings, settings_dir) }

  describe "in prepared settings dir" do
    before do
      attributes = '{"disk":{"mounted":true,"device":"/dev/abc"},"git":{"name":"Dr Nic Williams","email":"drnicwilliams@gmail.com"},"user":{"username":"user"}}'
      expected_cmd = "knife solo bootstrap user@host -i path/to/key -j '#{attributes}' -r 'bosh_inception'"
      subject.stub(:sh).with(expected_cmd)
      mkdir_p(File.join(settings_dir, "nodes"))
    end

    it "creates Berksfile" do
      subject.converge
      FileUtils.chdir(settings_dir) do
        File.should be_exists("Berksfile")
      end
    end
  end

end