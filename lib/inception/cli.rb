require "thor"
require "highline"
require "fileutils"
require "json"

# to prompt user for infrastructure choice/credentials
require "cyoi/cli/provider"

# for the #sh helper
require "rake"
require "rake/file_utils"

require "escape"
require "inception/cli_helpers/display"
require "inception/cli_helpers/interactions"
require "inception/cli_helpers/provider"
require "inception/cli_helpers/settings"
require "inception/cli_helpers/prepare_deploy_settings"

module Inception
  class Cli < Thor
    include FileUtils
    include Inception::CliHelpers::Display
    include Inception::CliHelpers::Interactions
    include Inception::CliHelpers::Provider
    include Inception::CliHelpers::Settings
    include Inception::CliHelpers::PrepareDeploySettings

    desc "deploy", "Create/upgrade a Bosh inception server"
    def deploy
      migrate_old_settings
      configure_provider
      prepare_deploy_settings
      perform_deploy
      converge_cookbooks
    end

    desc "delete", "Destroy target Bosh inception server, volumes & release the IP address"
    # method_option :"non-interactive", aliases: ["-n"], type: :boolean, desc: "Don't ask questions, just get crankin'"
    def delete
      migrate_old_settings
      perform_delete(options[:"non-interactive"])
    end

    desc "ssh [COMMAND]", "Open an ssh session to the inception server [do nothing if local machine is the inception server]"
    long_desc <<-DESC
      If a command is supplied, it will be run, otherwise a session will be opened.
    DESC
    def ssh(cmd=nil)
      migrate_old_settings
      run_ssh_command_or_open_tunnel(cmd)
    end

    desc "tmux", "Open an ssh (with tmux) session to the inception server [do nothing if local machine is inception server]"
    long_desc <<-DESC
      Opens a connection using ssh and attaches to the most recent tmux session;
      giving you persistance across disconnects.
    DESC
    def tmux
      migrate_old_settings
      run_ssh_command_or_open_tunnel(["-t", "tmux attach || tmux new-session"])
    end

    desc "share-ssh", "Display the SSH config & private key that can be given to others to share access to the inception server"
    def share_ssh(name=settings.inception.name)
      user = "vcap"
      host = settings.inception.provisioned.host
      private_key_path = "~/.ssh/#{name}"
      private_key = settings.inception.key_pair.private_key
      say <<-EOS
To access the inception server, add the following to your ~/.ssh/config

  Host #{name}
    User #{user}
    Hostname #{host}
    IdentityFile #{private_key_path}

Create a file #{private_key_path} with all the lines below:

#{private_key}

Change the private key to be read-only to you:

  $ chmod 700 ~/.ssh
  $ chmod 600 #{private_key_path}

You can now access the inception server running:

  $ ssh #{name}
EOS
    end

    no_tasks do
      def configure_provider
        save_settings!
        provider_cli = Cyoi::Cli::Provider.new([settings_dir])
        provider_cli.execute!
        reload_settings!
      end

      # update settings.git.name/git.email from local ~/.gitconfig if available
      # provision public IP address for inception server if not allocated one
      # Note: helper methods are in inception/cli_helpers/prepare_deploy_settings.rb
      def prepare_deploy_settings
        header "Preparing deployment settings"
        update_git_config
        provision_or_reuse_public_ip_address_for_inception unless settings.exists?("inception.provisioned.ip_address")
        recreate_key_pair_for_inception unless settings.exists?("inception.key_pair.private_key")
        recreate_private_key_file_for_inception
        validate_deploy_settings
        setup_next_deploy_actions
      end

      def perform_deploy
        header "Provision inception server"
        server = InceptionServer.new(provider_client, settings.inception, settings_ssh_dir)
        server.create
      ensure
        # after any error handling, still save the current InceptionServer state back into settings.inception
        settings["inception"] = server.export_attributes
        save_settings!
      end

      def setup_next_deploy_actions
        settings["next_deploy_actions"] ||= {}
        @next_deploy_actions = NextDeployActions.new(settings.next_deploy_actions, options)
      end

      # Perform converge chef cookbooks upon inception server
      # Does not update settings
      def converge_cookbooks
        if @next_deploy_actions.skip_chef_converge?
          header "Prepare inception server", skip: "Requested to be skipped on this deploy."
        else
          header "Prepare inception server"
          server = InceptionServer.new(provider_client, settings.inception, settings_ssh_dir)
          cookbook = InceptionServerCookbook.new(server, settings, settings_dir)
          cookbook.prepare
          settings.set("cookbook.prepared", true)
          save_settings!
          cookbook.converge
        end
      end

      def perform_delete(non_interactive)
        server = InceptionServer.new(provider_client, settings.inception, settings_ssh_dir)
        header "Deleting inception server, volumes and releasing IP address"
        server.delete_all
      ensure
        # after any error handling, still save the current InceptionServer state back into settings.inception
        settings["inception"] = server.export_attributes
        settings.delete("cookbook")
        save_settings!
      end

      def run_ssh_command_or_open_tunnel(cmd)
        recreate_private_key_file_for_inception
        unless settings.exists?("inception.provisioned.host")
          exit "inception server has not finished launching; run to complete: inception deploy"
        end

        server = InceptionServer.new(provider_client, settings.inception, settings_ssh_dir)
        username = settings.inception.provisioned.username
        host = settings.inception.provisioned.host
        result = system Escape.shell_command(["ssh", "-i", server.private_key_path, "#{username}@#{host}", cmd].flatten.compact)
        exit result
      end
    end
  end
end