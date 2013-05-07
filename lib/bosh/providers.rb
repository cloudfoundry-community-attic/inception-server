# Copyright (c) 2012-2013 Stark & Wayne, LLC

module Bosh; end

module Bosh::Providers
  extend self

  # returns a BOSH provider (CPI) specific object
  # with helpers related to that provider
  # returns nil if +provider_name+ is unknown
  def provider_client(provider_name, provider_region, credentials)
    credentials = credentials.inject({}) do |mem, key_value|
      key, value = key_value
      mem[key.to_sym] = value
      mem
    end
    provider = {
      provider: fog_provider_label_for(provider_name),
      region: provider_region
    }
    fog_compute = Fog::Compute.new(provider.merge(credentials))
    case provider_name.to_sym
    when :aws
      @aws_provider_client ||= begin
        require "bosh/providers/clients/aws_provider_client"
        Bosh::Providers::Clients::AwsProviderClient.new(fog_compute)
      end
    when :openstack
      @openstack_provider_client ||= begin
        require "bosh/providers/clients/openstack_provider_client"
        Bosh::Providers::Clients::OpenStackProviderClient.new(fog_compute)
      end
    else
      nil
    end
  end

  def provider_cli(provider_name, provider_settings)
    case provider_name.to_sym
    when :aws
      require "bosh/providers/cli/aws_provider_cli"
      Bosh::Providers::Cli::AwsProviderCli.new(provider_settings)
    when :openstack
      require "bosh/providers/cli/openstack_provider_cli"
      Bosh::Providers::Cli::OpenStackProviderCli.new(provider_settings)
    else
      nil
    end
  end

  def fog_provider_label_for(provider_name)
    case provider_name.to_sym
    when :aws
      "AWS"
    when :openstack
      "OpenStack"
    else
      raise "please support #{provider_name} provider"
    end
  end

  # returns a BOSH provider (CPI) specific object
  # with helpers related to that provider
  # @deprecated - use provider_client instead
  def for_bosh_provider_name(provider_name, fog_compute)
    puts "DEPRECATED: Bosh::Providers.for_bosh_provider_name (#{caller.first.inspect})"
    case provider_name.to_sym
    when :aws
      require "bosh/providers/clients/aws_provider_client"
      Bosh::Providers::Clients::AwsProviderClient.new(fog_compute)
    when :openstack
      require "bosh/providers/clients/openstack_provider_client"
      Bosh::Providers::Clients::OpenStackProviderClient.new(fog_compute)
    else
      raise "please support #{provider_name} provider"
    end
  end
end
