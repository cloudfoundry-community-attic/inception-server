describe Bosh::Inception::InceptionServer do
  include StdoutCapture

  describe "new AWS server" do
    let(:attributes) do
      {
        "ip_address" => "54.214.15.178",
        "key_pair" => {
          "name" => "inception",
          "private_key" => "private_key",
          "public_key" => "public_key"
        }
      }
    end
    let(:fog_compute) { Fog::Compute.new(
        :provider  => 'AWS', 
        :aws_access_key_id  => 'MOCK_AWS_ACCESS_KEY_ID',
        :aws_secret_access_key  => 'MOCK_AWS_SECRET_ACCESS_KEY')
    }
    let(:provider) { Bosh::Providers.for_bosh_provider_name("aws", fog_compute) }
    let(:ssh_dir) { "~/.bosh_inception/ssh" }
    subject { Bosh::Inception::InceptionServer.new(provider, attributes, ssh_dir) }

    before do
      Fog.mock!
      Fog::Mock.reset
      capture_stdout do
        provider.create_key_pair("inception")
        subject.create
      end
    end

    it "has default security groups" do
      subject.security_groups.should == ["ssh"]
      fog_compute.security_groups.get("ssh").should_not be_nil
    end

    it "has default size" do
      subject.size.should == "m1.small"
    end

    xit "is created" do
      fog_compute.servers.size.should == 1
    end
  end
end