# Copyright (c) 2012-2013 Stark & Wayne, LLC

module Bosh; module Providers; module Cli; end; end; end

require "bosh/providers/cli/provider_cli"
require "bosh/providers/constants/openstack_constants"

# Interactively prompt user for region & credential information for OpenStack
#
# Primary use within inception is to pass +settings.provider+ hash
# run #perform to gather credentials, then export the credentials/attributes.
#
#   settings["provider"] = {}
#   provider = OpenStackProviderCli.new(settings.provider)
#   provider_client.perform
#   settings.provider = provider_cli.export_attributes
class Bosh::Providers::Cli::OpenStackProviderCli < Bosh::Providers::Cli::ProviderCli

  def perform
    attributes.set("name", "openstack") # ensure this property is correct
    choose_region unless attributes.exists?("region")
    setup_credentials unless attributes.exists?("credentials.openstack_api_key")
  end

  # helper to export the complete nested attributes as a pure Hash
  def export_attributes
    attributes.to_nested_hash
  end

  def choose_region
    attributes.region = hl.ask("OpenStack Region (optional): ") do |q|
      q.default = openstack_constants.no_region_code
    end
  end

  def setup_credentials
    attributes.set_default("credentials", {})
    attributes.credentials["openstack_username"] = hl.ask("Username: ")
    attributes.credentials["openstack_api_key"] = hl.ask("Password: ")
    attributes.credentials["openstack_tenant"] = hl.ask("Tenant: ")
    attributes.credentials["openstack_auth_url"] = hl.ask("Authorization Token URL: ")
  end

  def openstack_constants
    Bosh::Providers::Constants::OpenStackConstants
  end
end
