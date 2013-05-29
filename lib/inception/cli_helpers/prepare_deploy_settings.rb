module Inception::CliHelpers
  module PrepareDeploySettings
    def update_git_config
      gitconfig = File.expand_path("~/.gitconfig")
      if File.exists?(gitconfig)
        say "Using your git user.name (#{`git config -f #{gitconfig} user.name`.strip})"
        settings.set("git.name", `git config -f #{gitconfig} user.name`.strip)
        settings.set("git.email", `git config -f #{gitconfig} user.email`.strip)
        save_settings!
      end
    end

    # Attempt to provision a new public IP; if none available,
    # then look for a pre-provisioned public IP that's not assigned
    # to a server; else error. The user needs to go get more
    # public IP addresses in this region.
    def provision_or_reuse_public_ip_address_for_inception
      say "Acquiring a public IP address... "
      if public_ip = provider_client.provision_or_reuse_public_ip_address
        say public_ip, :green
        settings.set("inception.provisioned.ip_address", public_ip)
        save_settings!
      else
        say "none available.", :red
        error "Please rustle up at least one public IP address and try again."
      end
    end

    def default_server_name
      "inception"
    end

    def default_key_pair_name
      default_server_name
    end

    def recreate_key_pair_for_inception
      key_pair_name = settings.set_default("inception.key_pair.name", default_key_pair_name)
      provider_client.delete_key_pair_if_exists(key_pair_name)
      key_pair = provider_client.create_key_pair(key_pair_name)
      settings.set("inception.key_pair.private_key", key_pair.private_key)
      settings.set("inception.key_pair.fingerprint", key_pair.fingerprint)
      save_settings!
    end

    def private_key_path_for_inception
      @private_key_path_for_inception ||= File.join(settings_dir, "ssh", settings.inception.key_pair.name)
    end

    # The keys for the inception server originate from the provider and are cached in
    # the manifest. The private key is stored locally; the public key is placed
    # on the inception server.
    def recreate_private_key_file_for_inception
      mkdir_p(File.dirname(private_key_path_for_inception))
      File.chmod(0700, File.dirname(private_key_path_for_inception))
      File.open(private_key_path_for_inception, "w") { |file| file << settings.inception.key_pair.private_key }
      File.chmod(0600, private_key_path_for_inception)
    end


    # Required settings:
    # * git.name
    # * git.email
    def validate_deploy_settings
      begin
        settings.git.name
        settings.git.email
      rescue ReadWriteSettings::MissingSetting => e
        error "Please setup local git user.name & user.email config; or specify git.name & git.email in settings.yml"
      end

      begin
        settings.provider.name
        settings.provider.credentials
      rescue ReadWriteSettings::MissingSetting => e
        error "Wooh there, we need provider.name & provider.credentials in settings.yml to proceed."
      end

      begin
        settings.inception.provisioned.ip_address
        settings.inception.key_pair.name
        settings.inception.key_pair.private_key
      rescue ReadWriteSettings::MissingSetting => e
        error "Wooh there, we need inception.provisioned.ip_address, inception.key_pair.name, & inception.key_pair.private_key in settings.yml to proceed."
      end
    end
  end
end
