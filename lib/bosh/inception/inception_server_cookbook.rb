module Bosh::Inception
  # Perform converge chef cookbooks upon inception server
  class InceptionServerCookbook
    include FileUtils

    attr_reader :server, :settings, :project_dir

    class InvalidTarget < StandardError; end

    def initialize(inception_server, settings, project_dir)
      @server = inception_server
      @settings = settings
      @project_dir = project_dir
    end

    # To be invoked within the settings_dir
    def converge
      FileUtils.chdir(project_dir) do
        raise InvalidTarget, "please invoke within folder containing nodes dir" unless File.directory?("nodes")
        user_host = server.user_host
        key_path = server.private_key_path
        attributes = cookbook_attributes_for_inception.to_json
        sh %Q{knife solo bootstrap #{user_host} -i #{key_path} -j '#{attributes}' -r 'bosh_inception'}
      end
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