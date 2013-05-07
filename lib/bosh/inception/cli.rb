require "thor"
require "highline"
require "fileutils"
require "json"

# for the #sh helper
require "rake"
require "rake/file_utils"

require "escape"
require "bosh/inception/cli_helpers/display"
require "bosh/inception/cli_helpers/provider"
require "bosh/inception/cli_helpers/settings"
require "bosh/inception/cli_helpers/prepare_deploy_settings"

module Bosh::Inception
  class Cli < Thor
    include Thor::Actions
    include FileUtils
    include Bosh::Inception::CliHelpers::Display
    include Bosh::Inception::CliHelpers::Provider
    include Bosh::Inception::CliHelpers::Settings
    include Bosh::Inception::CliHelpers::PrepareDeploySettings

    desc "deploy", "Create/upgrade a Bosh Inception VM"
    def deploy
      migrate_old_settings
      prepare_deploy_settings
      perform_deploy
      converge_cookbooks
    end

    desc "destroy", "Destroy target Bosh Inception VM"
    def destroy
      migrate_old_settings
      error "Not implemented yet"
    end

    desc "ssh [COMMAND]", "Open an ssh session to the inception VM [do nothing if local machine is the inception VM]"
    long_desc <<-DESC
      If a command is supplied, it will be run, otherwise a session will be opened.
    DESC
    def ssh(cmd=nil)
      migrate_old_settings
      run_ssh_command_or_open_tunnel(cmd)
    end

    desc "tmux", "Open an ssh (with tmux) session to the inception VM [do nothing if local machine is inception VM]"
    long_desc <<-DESC
      Opens a connection using ssh and attaches to the most recent tmux session;
      giving you persistance across disconnects.
    DESC
    def tmux
      migrate_old_settings
      run_ssh_command_or_open_tunnel(["-t", "tmux attach || tmux new-session"])
    end

    no_tasks do
      # update settings.git.name/git.email from local ~/.gitconfig if available
      # provision public IP address for inception VM if not allocated one
      # Note: helper methods are in bosh/inception/cli_helpers/prepare_deploy_settings.rb
      def prepare_deploy_settings
        header "Preparing deployment settings"
        update_git_config
        provision_or_reuse_public_ip_address_for_inception unless settings.exists?("inception.ip_address")
        recreate_key_pair_for_inception unless settings.exists?("inception.key_pair.private_key")
        recreate_private_key_file_for_inception
        validate_deploy_settings
      end

      def perform_deploy
        header "Provision inception VM"
        server = InceptionServer.new(provider_client, settings.inception, settings_ssh_dir)
        server.create
      ensure
        # after any error handling, still save the current InceptionServer state back into settings.inception
        settings["inception"] = server.export_attributes
        save_settings!
      end

      # Perform converge chef cookbooks upon Inception VM
      # Does not update settings
      def converge_cookbooks
        header "Prepare inception VM"
        server = InceptionServer.new(provider_client, settings.inception, settings_ssh_dir)
        cookbook = InceptionServerCookbook.new(server, settings)
        cookbook.converge
      end

      def run_ssh_command_or_open_tunnel(cmd)
        recreate_private_key_file_for_inception
        unless settings.exists?("inception.provisioned.host")
          exit "Inception VM has not finished launching; run to complete: bosh-inception deploy"
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