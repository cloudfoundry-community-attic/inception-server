# Copyright (c) 2012-2013 Stark & Wayne, LLC

module Bosh; module Providers; module Cli; end; end; end

class Bosh::Providers::Cli::ProviderCli
  include Inception::CliHelpers::Interactions

  attr_reader :provider_client
  attr_reader :attributes

  def initialize(attributes)
    @provider_client = provider_client
    @attributes = attributes.is_a?(Hash) ? Settingslogic.new(attributes) : attributes
    raise "@attributes must be Settingslogic (or Hash)" unless @attributes.is_a?(Settingslogic)
  end

end