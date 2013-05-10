module Inception::CliHelpers
  module Infrastructure
    # Prompts user to choose an Iaas provider
    # Sets settings.provider.name
    def configure_provider
      unless valid_infrastructure?
        choose_fog_provider unless settings.exists?("provider.name")
        choose_provider unless settings.exists?("provider.name")
        setup_provider_credentials
      end
      confirm_infrastructure
    end

    # Displays a prompt for known IaaS that are configured
    # within .fog config file if found.
    #
    # If no ~/.fog file found or user chooses "Alternate credentials"
    # then no changes are made to settings.
    #
    # For example:
    #
    # 1. AWS (default)
    # 2. AWS (bosh)
    # 3. Alternate credentials
    # Choose infrastructure:  1
    #
    # If .fog config only contains one provider, do not prompt.
    #
    # fog config file looks like:
    # :default:
    #   :aws_access_key_id:     PERSONAL_ACCESS_KEY
    #   :aws_secret_access_key: PERSONAL_SECRET
    # :bosh:
    #   :aws_access_key_id:     SPECIAL_IAM_ACCESS_KEY
    #   :aws_secret_access_key: SPECIAL_IAM_SECRET_KEY
    #
    # Convert this into:
    # { "AWS (default)" => {:aws_access_key_id => ...}, "AWS (bosh)" => {...} }
    #
    # Then display options to user to choose.
    #
    # Currently detects following fog providers:
    # * AWS
    # * OpenStack
    #
    # If "Alternate credentials" is selected, then user is prompted for fog
    # credentials:
    # * provider?
    # * access keys?
    # * API URI or region?
    #
    # Sets (unless 'Alternate credentials' is chosen)
    # * settings.provider.name
    # * settings.provider.credentials
    #
    # For AWS, the latter has keys:
    #   {:aws_access_key_id, :aws_secret_access_key}
    #
    # For OpenStack, the latter has keys:
    #   {:openstack_username, :openstack_api_key, :openstack_tenant
    #      :openstack_auth_url, :openstack_region }
    def choose_fog_provider
      fog_providers = {}
      # Prepare menu options:
      # each provider/profile name gets a menu choice option
      fog_config.inject({}) do |iaas_options, fog_profile|
        profile_name, profile = fog_profile
        if profile[:aws_access_key_id]
          # TODO does fog have inbuilt detection algorithm?
          fog_providers["AWS (#{profile_name})"] = {
            "name" => "aws",
            "provider" => "AWS",
            "aws_access_key_id" => profile[:aws_access_key_id],
            "aws_secret_access_key" => profile[:aws_secret_access_key]
          }
        end
        if profile[:openstack_username]
          # TODO does fog have inbuilt detection algorithm?
          fog_providers["OpenStack (#{profile_name})"] = {
            "name" => "openstack",
            "provider" => "OpenStack",
            "openstack_username" => profile[:openstack_username],
            "openstack_api_key" => profile[:openstack_api_key],
            "openstack_tenant" => profile[:openstack_tenant],
            "openstack_auth_url" => profile[:openstack_auth_url],
            "openstack_region" => profile[:openstack_region]
          }
        end
      end
      # Display menu
      # Include "Alternate credentials" as the last option
      if fog_providers.keys.size > 0
        hl.choose do |menu|
          menu.prompt = "Choose infrastructure:  "
          fog_providers.each do |label, credentials|
            menu.choice(label) do
              settings.set("provider.name", credentials.delete("name"))
              settings.set("provider.credentials", credentials)
              save_settings!
            end
          end
          menu.choice("Alternate credentials")
        end
      end
    end

    # Prompts user to pick from the supported regions
    def choose_provider
      hl.choose do |menu|
        menu.prompt = "Choose infrastructure:  "
        menu.choice("AWS") do
          settings.provider["name"] = "aws"
        end
        menu.choice("OpenStack") do
          settings.provider["name"] = "openstack"
        end
      end
    end

    def setup_provider_credentials
      say "Using provider #{settings.provider.name}:"
      say ""
      settings.set_default("provider", {}) # to ensure settings.provider exists
      provider_cli = Bosh::Providers.provider_cli(settings.provider.name, settings.provider)
      provider_cli.perform
      settings["provider"] = provider_cli.export_attributes
      settings.create_accessors!
    end

    def valid_infrastructure?
      settings.exists?("provider.name") &&
        settings.exists?("provider.region") &&
        settings.exists?("provider.credentials") &&
        provider_client
    end

    def confirm_infrastructure
      confirm "Using #{settings.provider.name}/#{settings.provider.region}"
    end

    def fog_config
      @fog_config ||= begin
        if File.exists?(File.expand_path(fog_config_path))
          say "Found infrastructure API credentials at #{fog_config_path} (override with $FOG)"
          YAML.load_file(File.expand_path(fog_config_path))
        else
          say "No existing #{fog_config_path} fog configuration file", :yellow
          {}
        end
      end
    end

    def fog_config_path
      ENV['FOG'] || "~/.fog"
    end
  end
end