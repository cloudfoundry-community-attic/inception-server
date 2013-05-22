module Inception
  
  class NextDeployActions
    def initialize(attributes, cli_options)
      @attributes = attributes.is_a?(Hash) ? ReadWriteSettings.new(attributes) : attributes
      raise "@attributes must be ReadWriteSettings (or Hash)" unless @attributes.is_a?(ReadWriteSettings)
      raise "@cli_options must be Hash" unless cli_options.is_a?(Hash)
      apply_cli_options(cli_options)
    end

    def skip_chef_converge?
      @attributes["no_converge"] || @attributes["no-converge"] || @attributes["skip_chef_converge"]
    end

    protected
    def apply_cli_options(cli_options)
      @attributes.merge(cli_options)
    end
  end
end