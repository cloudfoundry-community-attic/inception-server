require "thor"
require "highline"
require "fileutils"

# for the #sh helper
require "rake"
require "rake/file_utils"

require "escape"
require "bosh/inception/cli_helpers/display"
require "bosh/inception/cli_helpers/settings"

module Bosh::Inception
  class Cli < Thor
    include Thor::Actions
    include Bosh::Inception::CliHelpers::Display
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
      def prepare_deploy_settings
        gitconfig = File.expand_path("~/.gitconfig")
        if File.exists?(gitconfig)
          settings.set_default("git.name", `git config -f #{gitconfig} user.name`.strip)
          settings.set_default("git.email", `git config -f #{gitconfig} user.email`.strip)
        end
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