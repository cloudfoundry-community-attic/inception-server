require "thor"
require "highline"
require "fileutils"

# for the #sh helper
require "rake"
require "rake/file_utils"

require "escape"
require "bosh/inception/cli_helpers/display"
require "bosh/inception/cli_helpers/provider"
require "bosh/inception/cli_helpers/settings"

module Bosh::Inception
  class Cli < Thor
    include Thor::Actions
    include Bosh::Inception::CliHelpers::Display
    include Bosh::Inception::CliHelpers::Provider
    include Bosh::Inception::CliHelpers::Settings

    desc "deploy", "Create/upgrade a Bosh Inception VM"
    def deploy
      migrate_old_settings
      prepare_deploy_settings
      validate_deploy_settings
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
      # if git.name/git.email not provided, load it in from local ~/.gitconfig
      # provision public IP address for inception VM if not allocated one
      def prepare_deploy_settings
        gitconfig = File.expand_path("~/.gitconfig")
        if File.exists?(gitconfig)
          settings.set_default("git.name", `git config -f #{gitconfig} user.name`.strip)
          settings.set_default("git.email", `git config -f #{gitconfig} user.email`.strip)
          save_settings!
        end

        unless settings.exists?("inception.ip_address")
          provision_or_reuse_public_ip_address_for_inception
        end

        unless settings.exists?("inception.key_pair.private_key")
          recreate_key_pair_for_inception
        end
      end

      # Attempt to provision a new public IP; if none available,
      # then look for a pre-provisioned public IP that's not assigned
      # to a server; else error. The user needs to go get more
      # public IP addresses in this region.
      def provision_or_reuse_public_ip_address_for_inception
        say "Acquiring a public IP address... "
        if public_ip = provider_client.provision_or_reuse_public_ip_address
          say public_ip
          settings.set("inception.ip_address", public_ip)
          save_settings!
        else
          say "none available.", :red
          error "Please rustle up at least one public IP address and try again."
        end
      end

      DEFAULT_KEY_PAIR_NAME = "inception"

      def recreate_key_pair_for_inception
        key_pair_name = settings.set_default("inception.key_pair.name", DEFAULT_KEY_PAIR_NAME)
        provider_client.delete_key_pair_if_exists(key_pair_name)
        key_pair = provider_client.create_key_pair(key_pair_name)
        settings.set("inception.key_pair.private_key", key_pair.private_key)
        settings.set("inception.key_pair.fingerprint", key_pair.fingerprint)
      end
      

      # Required settings:
      # * git.name
      # * git.email
      def validate_deploy_settings
        begin
          settings.git.name
          settings.git.email
        rescue Settingslogic::MissingSetting => e
          error "Please setup local git user.name & user.email config; or specify git.name & git.email in settings.yml"
        end

        begin
          settings.provider.name
          settings.provider.region
          settings.provider.credentials
        rescue Settingslogic::MissingSetting => e
          error "Wooh there, we need provider.name, provider.region, provider.credentials in settings.yml to proceed."
        end

        begin
          settings.inception.ip_address
          settings.inception.key_pair.name
          settings.inception.key_pair.private_key
        rescue Settingslogic::MissingSetting => e
          error "Wooh there, we need inception.ip_address, inception.key_pair.name, & inception.key_pair.private_key in settings.yml to proceed."
        end
      end

      def run_ssh_command_or_open_tunnel(*args)
        error "Method not implemented: Cli#run_ssh_command_or_open_tunnel"
      end
    end
  end
end