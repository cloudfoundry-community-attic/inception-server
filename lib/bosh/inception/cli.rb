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
      error "Not implemented yet"
    end

    no_tasks do
    end
  end
end