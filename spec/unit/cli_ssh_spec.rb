# Copyright (c) 2012-2013 Stark & Wayne, LLC

# Specs for 'ssh' related behavior. Includes CLI commands:
# * ssh
# * tmux
# * mosh
describe Inception do
  include FileUtils
  include SettingsHelper

  before do
    setup_home_dir
    @cmd = Inception::Cli.new
    setting "provider.name", "aws"
    setting "provider.credentials.aws_access_key_id", "aws_access_key_id"
    setting "provider.credentials.aws_secret_access_key", "aws_secret_access_key"
    setting "provider.region", "us-west-2"
    setting "inception.key_pair.name", "inception"
    setting "inception.key_pair.private_key", <<-EOS
-----BEGIN RSA PRIVATE KEY-----
xV67ZHvuRdoNDbFXscpF5uK4sEwbsvSJw73qtYAgUWfhXQKBgQDCQaO9Hf6UKd4PyPeLlSGE7akS
p57tEdMoXIE1BzUbQJL5UWfTsL6PDU7PJbIDWsR4CqESLcU3D/JVl7F5bQ6cgLifP3SuDh4oMLtK
ToA13XEsLnlLnyyi+i1dDv97Yz5jjULy8wsbiVpneabckol4427947OZwIvsHDF+KXHy3w==
-----END RSA PRIVATE KEY-----
EOS
    setting "inception.name", "inception"
    setting "inception.provisioned.host", "ec2-1-2-3-4.compute-1.amazonaws.com"
    setting "inception.provisioned.username", "vcap"
  end

  describe "ssh" do
    let(:private_key_path) { home_file(".inception_server/ssh/inception") }

    describe "normal" do
      it "launches ssh session" do
        @cmd.should_receive(:exit)
        @cmd.should_receive(:system).
          with("ssh -i #{private_key_path} vcap@ec2-1-2-3-4.compute-1.amazonaws.com")
        @cmd.ssh
      end
      it "runs ssh command" do
        @cmd.should_receive(:exit)
        @cmd.should_receive(:system).
          with("ssh -i #{private_key_path} vcap@ec2-1-2-3-4.compute-1.amazonaws.com 'some command'")
        @cmd.ssh("some command")
      end
    end

    describe "tmux" do
      it "launches ssh session" do
        @cmd.should_receive(:exit)
        @cmd.should_receive(:system).
          with("ssh -i #{private_key_path} vcap@ec2-1-2-3-4.compute-1.amazonaws.com -t 'tmux attach || tmux new-session'")
        @cmd.tmux
      end
    end

    describe "mosh" do
      before { Fog.mock! }
      after { Fog.unmock! }
      xit "should check whether mosh is installed" do
         @cmd.should_receive(:system).
          with("mosh --version")
        @cmd.stub!(:exit)
        @cmd.ensure_mosh_installed
      end
      xit "launches mosh session" do
        @cmd.stub!(:ensure_mosh_installed).and_return(true)
        @cmd.should_receive(:exit)
        @cmd.should_receive(:system).
          with("mosh --ssh 'ssh -i #{@private_key_path}' vcap@ec2-1-2-3-4.compute-1.amazonaws.com")
        @cmd.mosh
      end
      xit "should ensure that the mosh ports are opened" do
        expected_ports = {
          mosh: { 
            protocol: "udp", 
            ports: (60000..60050) 
          }
        } 
        @cmd.provider.stub!(:create_security_group)
          .with('default','not used', expected_ports)
        @cmd.ensure_security_group_allows_mosh
      end
    end

    describe "share-ssh" do
      it "should display an example .ssh/config & private key" do
        @cmd.should_receive(:say).with(<<-EOS)
To access the inception server, add the following to your ~/.ssh/config

  Host inception
    User vcap
    Hostname ec2-1-2-3-4.compute-1.amazonaws.com
    IdentityFile ~/.ssh/inception

Create a file ~/.ssh/inception with all the lines below:

-----BEGIN RSA PRIVATE KEY-----
xV67ZHvuRdoNDbFXscpF5uK4sEwbsvSJw73qtYAgUWfhXQKBgQDCQaO9Hf6UKd4PyPeLlSGE7akS
p57tEdMoXIE1BzUbQJL5UWfTsL6PDU7PJbIDWsR4CqESLcU3D/JVl7F5bQ6cgLifP3SuDh4oMLtK
ToA13XEsLnlLnyyi+i1dDv97Yz5jjULy8wsbiVpneabckol4427947OZwIvsHDF+KXHy3w==
-----END RSA PRIVATE KEY-----


Change the private key to be read-only to you:

  $ chmod 700 ~/.ssh
  $ chmod 600 ~/.ssh/inception

You can now access the inception server running:

  $ ssh inception
EOS
        @cmd.share_ssh
      end

      it "should display an example .ssh/config & private key with custom name" do
        @cmd.should_receive(:say).with(<<-EOS)
To access the inception server, add the following to your ~/.ssh/config

  Host company-xyz
    User vcap
    Hostname ec2-1-2-3-4.compute-1.amazonaws.com
    IdentityFile ~/.ssh/company-xyz

Create a file ~/.ssh/company-xyz with all the lines below:

-----BEGIN RSA PRIVATE KEY-----
xV67ZHvuRdoNDbFXscpF5uK4sEwbsvSJw73qtYAgUWfhXQKBgQDCQaO9Hf6UKd4PyPeLlSGE7akS
p57tEdMoXIE1BzUbQJL5UWfTsL6PDU7PJbIDWsR4CqESLcU3D/JVl7F5bQ6cgLifP3SuDh4oMLtK
ToA13XEsLnlLnyyi+i1dDv97Yz5jjULy8wsbiVpneabckol4427947OZwIvsHDF+KXHy3w==
-----END RSA PRIVATE KEY-----


Change the private key to be read-only to you:

  $ chmod 700 ~/.ssh
  $ chmod 600 ~/.ssh/company-xyz

You can now access the inception server running:

  $ ssh company-xyz
EOS
        @cmd.share_ssh("company-xyz")
      end
    end
  end
end
