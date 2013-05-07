describe Bosh::Inception::InceptionServer do
  include StdoutCapture

  describe "new AWS server" do
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
    let(:attributes) do
      {
        "provisioned" => {
          "ip_address" => "54.214.15.178"
        },
        "key_pair" => {
          "name" => "inception",
          "private_key" => "private_key",
          "public_key" => "public_key"
        }
      }
    end
    let(:provider_client) { Bosh::Providers.provider_client(provider_attributes) }
    let(:ssh_dir) { "~/.bosh_inception/ssh" }
    subject { Bosh::Inception::InceptionServer.new(provider_client, attributes, ssh_dir) }
    let(:fog_compute) { subject.fog_compute }

    before do
      Fog.mock!
      Fog::Mock.reset
      capture_stdout do
        provider_client.create_key_pair("inception")
        subject.create
      end
    end

    it "has default security groups" do
      subject.security_groups.should == ["ssh"]
      fog_compute.security_groups.get("ssh").should_not be_nil
    end

    it "has default flavor" do
      subject.flavor.should == "m1.small"
    end

    it "has default disk size" do
      subject.disk_size.should == 16
    end

    xit "is created" do
      fog_compute.servers.size.should == 1
    end
  end
end