# assumes @cmd is Bosh::Inception::Cli instance
module SettingsHelper
  # Set a nested setting with "key1.key2.key3" notation

  def setting(nested_key, value)
    target_settings_field = settings
    settings_key_portions = nested_key.split(".")
    parent_key_portions, final_key = settings_key_portions[0..-2], settings_key_portions[-1]
    parent_key_portions.each do |key_portion|
      target_settings_field[key_portion] ||= {}
      target_settings_field = target_settings_field[key_portion]
    end
    target_settings_field[final_key] = value
  end

  # used by +SettingsSetter+ to access the settings
  def settings
    @cmd.settings
  end

end