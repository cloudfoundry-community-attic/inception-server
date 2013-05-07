# Copyright (c) 2012-2013 Stark & Wayne, LLC

module Bosh; end

module Bosh::Providers
  extend self

  # returns a BOSH provider (CPI) specific object
  # with helpers related to that provider
  # returns nil if +provider_name+ is unknown
  def provider_client(attributes)
    attributes = attributes.is_a?(Hash) ? Settingslogic.new(attributes) : attributes
    case attributes.name.to_sym
    when :aws
      @aws_provider_client ||= begin
        require "bosh/providers/clients/aws_provider_client"
        Bosh::Providers::Clients::AwsProviderClient.new(attributes)
      end
    when :openstack
      @openstack_provider_client ||= begin
        require "bosh/providers/clients/openstack_provider_client"
        Bosh::Providers::Clients::OpenStackProviderClient.new(attributes)
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
end
