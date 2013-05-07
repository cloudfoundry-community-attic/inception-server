module Bosh::Inception
  # Perform converge chef cookbooks upon Inception VM
  class InceptionServerCookbook
    include FileUtils

    attr_reader :server, :settings

    def initialize(inception_server, settings)
      @server = inception_server
      @settings = settings
    end

    def converge
      user_host = server.user_host
      key_path = server.private_key_path
      attributes = cookbook_attributes_for_inception.to_json
      sh %Q{knife solo cook #{user_host} -i #{key_path} -j '#{attributes}' -r 'bosh_inception'}
    end

    protected
    def cookbook_attributes_for_inception
      {
        "disk" => {
          "mounted" => true,
          "device" => settings.inception.provisioned.disk_device.internal
        },
        "git" => {
          "name" => settings.git.name,
          "email" => settings.git.email
        },
        "user" => {
          "username" => settings.inception.provisioned.username
        }
      }
    end

  end
end