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
      error "Not implemented yet"
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
      def run_ssh_command_or_open_tunnel(*args)
        error "Method not implemented: Cli#run_ssh_command_or_open_tunnel"
      end
    end
  end
end