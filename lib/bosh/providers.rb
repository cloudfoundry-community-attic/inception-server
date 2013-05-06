# Copyright (c) 2012-2013 Stark & Wayne, LLC

module Bosh; end

module Bosh::Providers
  extend self

  # returns a BOSH provider (CPI) specific object
  # with helpers related to that provider
  def for_bosh_provider(provider_name, credentials)
    fog_compute = Fog::Compute.new(credentials.merge(provider: fog_provider_for(provider_name)))
    case provider_name.to_sym
    when :aws
      require "bosh/providers/aws"
      Bosh::Providers::AWS.new(fog_compute)
    when :openstack
      require "bosh/providers/openstack"
      Bosh::Providers::OpenStack.new(fog_compute)
    else
      raise "please support #{provider_name} provider"
    end
  end

  def fog_provider_for(provider_name)
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
  # @deprecated - use for_bosh_provider instead
  def for_bosh_provider_name(provider_name, fog_compute)
    puts "DEPRECATED: Bosh::Providers.for_bosh_provider_name (#{caller.first.inspect})"
    case provider_name.to_sym
    when :aws
      require "bosh/providers/aws"
      Bosh::Providers::AWS.new(fog_compute)
    when :openstack
      require "bosh/providers/openstack"
      Bosh::Providers::OpenStack.new(fog_compute)
    else
      raise "please support #{provider_name} provider"
    end
  end
end
