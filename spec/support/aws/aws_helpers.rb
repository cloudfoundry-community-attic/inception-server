require "active_support/core_ext/hash/keys"
module AwsHelpers
  extend self
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

  def aws_credentials?
    access_key = ENV['AWS_ACCESS_KEY_ID']
    secret_key = ENV["AWS_SECRET_ACCESS_KEY"]
    access_key && secret_key
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

  def prepare_aws(spec_name, aws_region, options={})
    setup_home_dir
    @cmd = nil
    @fog = nil
    create_manifest(options)
    destroy_test_constructs
  end

  def unique_number
    ENV['UNIQUE_NUMBER'] || Random.rand(100000)
  end

  def test_server_name
    "test-inception"
  end

  def create_manifest(options = {})
    credentials = options.delete(:credentials) || fog_credentials
    setting "provider.name", "aws"
    setting "provider.credentials", credentials.stringify_keys
    setting "provider.region", region
    setting "inception.name", test_server_name
    options.each { |key, value| setting(key, value) }
    cmd.save_settings!
  end

  def destroy_test_constructs
    puts "Destroying everything created by previous test... "
    # destroy servers using inception-vm SG
    provider.delete_servers_with_name(test_server_name)
    provider.delete_volumes_with_name(test_server_name)
    provider.delete_key_pair_if_exists(test_server_name)
    provider.cleanup_unused_ip_addresses
  end
end