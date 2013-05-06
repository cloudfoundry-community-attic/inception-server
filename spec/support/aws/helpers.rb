module AwsHelpers
  include SettingsHelper

  def keep_after_test?
    ENV['KEEP_AFTER_TEST']
  end

  def region
    @region ||= "us-west-2"
  end

  def fog
    @fog ||= Fog::Compute.new(fog_credentials.merge(:region => region))
  end

  def fog_credentials
    @fog_credentials ||= begin
      access_key = ENV['AWS_ACCESS_KEY_ID']
      secret_key = ENV["AWS_SECRET_ACCESS_KEY"]
      unless access_key && secret_key
        raise "Please provided $AWS_ACCESS_KEY_ID and $AWS_SECRET_ACCESS_KEY"
      end
      credentials = {
        :provider                 => 'AWS',
        :aws_access_key_id        => access_key,
        :aws_secret_access_key    => secret_key
      }
    end
  end

  def cmd
    @cmd ||= Bosh::Inception::Cli.new
  end

  def provider
    cmd.provider
  end

  def prepare_aws(spec_name, aws_region)
    setup_home_dir
    @cmd = nil
    @fog = nil
    create_manifest
    destroy_test_constructs(bosh_name)
  end

  def unique_number
    ENV['UNIQUE_NUMBER'] || Random.rand(100000)
  end

  def create_manifest(options = {})
    credentials = options.delete(:credentials) || fog_credentials.stringify_keys
    setting "provider.name", "aws"
    setting "provider.credentials", credentials
    setting "provider.region", region
    setting "inception.key_pair.name", "inception"
    setting "inception.key_pair.private_key", "sadfsdfa"
    options.each { |key, value| setting(key, value) }
    cmd.save_settings!
  end

  def destroy_test_constructs(bosh_name)
    puts "Destroying everything created by previous tests..."
    # destroy servers using inception-vm SG
    provider.delete_security_group_and_servers("#{bosh_name}-inception-vm")
    provider.delete_security_group_and_servers(bosh_name)

    # TODO delete "inception" key pair? Why isn't it named for the bosh/inception VM?
    provider.delete_key_pair(bosh_name)

    provider.cleanup_unused_ip_addresses
  end

end