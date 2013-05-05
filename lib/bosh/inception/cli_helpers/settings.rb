require "settingslogic"

module Bosh::Inception::CliHelpers
  module Settings
    # The base directory for holding the manifest settings file
    # and private keys
    #
    # Defaults to ~/.bosh_inception; and can be overridden with either:
    # * $SETTINGS - to a folder (supported method)
    def settings_dir
      @settings_dir ||= File.expand_path(ENV["SETTINGS"] || "~/.bosh_inception")
    end

    def settings_path
      @settings_path ||= File.join(settings_dir, "settings.yml")
    end

    def settings
      @settings ||= begin
        unless File.exists?(settings_path)
          FileUtils.mkdir_p(settings_dir)
          File.open(settings_path, "w") { |file| file << "--- {}" }
        end
        Settingslogic.new(settings_path)
      end
    end

    def save_settings!
    end

    def migrate_old_settings
    end

  end
end
