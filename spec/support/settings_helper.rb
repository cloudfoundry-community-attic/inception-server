# assumes @cmd is Inception::Cli instance
module SettingsHelper
  def cmd
    @cmd ||= Inception::Cli.new
  end

  def provider
    cmd.provider_client
  end

  # Set a nested setting with "key1.key2.key3" notation
  def setting(nested_key, value)
    settings.set(nested_key, value)
  end

  # used by +SettingsSetter+ to access the settings
  def settings
    cmd.settings
  end
end