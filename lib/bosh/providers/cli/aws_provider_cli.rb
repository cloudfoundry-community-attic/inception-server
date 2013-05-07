# Copyright (c) 2012-2013 Stark & Wayne, LLC

module Bosh; module Providers; module Cli; end; end; end

require "bosh/providers/constants/aws_constants"

# Interactively prompt user for region & credential information for AWS
#
# Primary use within bosh-inception is to pass +settings.provider+ hash
# run #perform to gather credentials, then export the credentials/attributes.
#
#   settings["provider"] = {}
#   provider = AwsProviderCli.new(settings.provider)
#   provider_client.perform
#   settings.provider = provider_cli.export_attributes
class Bosh::Providers::Cli::AwsProviderCli
  include Bosh::Inception::CliHelpers::Interactions

  attr_reader :provider_client
  attr_reader :attributes

  def initialize(attributes)
    @provider_client = provider_client
    @attributes = attributes.is_a?(Hash) ? Settingslogic.new(attributes) : attributes
    raise "@attributes must be Settingslogic (or Hash)" unless @attributes.is_a?(Settingslogic)
  end

  def perform
    attributes.set("name", "aws") # ensure this property is correct
    choose_region unless attributes.exists?("region")
  end

  # helper to export the complete nested attributes as a pure Hash
  def export_attributes
    attributes.to_nested_hash
  end

  def choose_region
    hl.choose do |menu|
      menu.prompt = "Choose AWS region: "
      default_menu_item = nil
      aws_constants.region_labels.each do |region_info|
        label, code = region_info[:label], region_info[:code]
        menu_item = "#{label} (#{code})"
        if code == aws_constants.default_region_code
          menu_item = "*#{menu_item}"
          default_menu_item = menu_item 
        end
        menu.choice(menu_item) do
          attributes["region"] = code
        end
      end
      menu.default = default_menu_item if default_menu_item
    end
  end

  def aws_constants
    Bosh::Providers::Constants::AwsConstants
  end
end
