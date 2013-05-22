# Copyright (c) 2012-2013 Stark & Wayne, LLC

module Inception; end

module Inception::Providers
  extend self

  # returns a BOSH provider (CPI) specific object
  # with helpers related to that provider
  # returns nil if +provider_name+ is unknown
  def provider_client(attributes)
    attributes = attributes.is_a?(Hash) ? ReadWriteSettings.new(attributes) : attributes
    case attributes.name.to_sym
    when :aws
      @aws_provider_client ||= begin
        require "inception/providers/clients/aws_provider_client"
        Inception::Providers::Clients::AwsProviderClient.new(attributes)
      end
    when :openstack
      @openstack_provider_client ||= begin
        require "inception/providers/clients/openstack_provider_client"
        Inception::Providers::Clients::OpenStackProviderClient.new(attributes)
      end
    else
      nil
    end
  end
end
