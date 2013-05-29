require "fog"

module Inception
  class InceptionServer

    DEFAULT_SERVER_NAME = "inception"
    DEFAULT_FLAVOR = "m1.small"
    DEFAULT_DISK_SIZE = 16
    DEFAULT_SECURITY_GROUPS = ["ssh"]

    attr_reader :attributes

    # @provider_client [Inception::Providers::FogProvider] - interact with IaaS
    # @attributes [ReadWriteSettings]
    #
    # Required @attributes:
    #   {
    #     "name" => "inception",
    #     "ip_address" => "54.214.15.178",
    #     "key_pair" => {
    #       "name" => "inception",
    #       "private_key" => "private_key",
    #       "public_key" => "public_key"
    #     }
    #   }
    #
    # Including optional @attributes and default values:
    #   {
    #     "name" => "inception",
    #     "ip_address" => "54.214.15.178",
    #     "security_groups" => ["ssh"],
    #     "flavor" => "m1.small",
    #     "key_pair" => {
    #       "name" => "inception",
    #       "private_key" => "private_key",
    #       "public_key" => "public_key"
    #     }
    #   }
    def initialize(provider_client, attributes, ssh_dir)
      @provider_client = provider_client
      @ssh_dir = ssh_dir
      @attributes = attributes.is_a?(Hash) ? ReadWriteSettings.new(attributes) : attributes
      raise "@attributes must be ReadWriteSettings (or Hash)" unless @attributes.is_a?(ReadWriteSettings)
    end

    # Create the underlying server, with key pair & security groups, unless it is already created
    #
    # The @attributes hash is updated with a `provisioned` key during/after creation.
    # When saved as YAML it might look like:
    #   inception:
    #     provisioned:
    #       image_id: ami-123456
    #       server_id: i-e7f005d2
    #       security_groups:
    #         - ssh
    #         - mosh
    #       username: ubuntu
    #       disk_device: /dev/sdi
    #       host: ec2-54-214-15-178.us-west-2.compute.amazonaws.com
    #       validated: true
    #       converged: true
    def create
      validate_attributes_for_bootstrap
      ensure_required_security_groups
      create_missing_default_security_groups
      bootstrap_vm
      attach_persistent_disk
    end

    # Delete the server, volume and release the IP address
    def delete_all
      delete_server
      delete_volume
      delete_key_pair
      release_ip_address
    end

    def delete_server
      @fog_server = nil # force reload of fog_server model
      if fog_server
        print "Deleting server... "
        fog_server.destroy
        wait_for_termination(fog_server) unless Fog.mocking?
        puts "done."
      else
        puts "Server already destroyed"
      end
      provisioned.delete("host")
      provisioned.delete("server_id")
      provisioned.delete("username")
    end
    
    def delete_volume
      volume_id = provisioned.exists?("disk_device.volume_id")
      if volume_id && (volume = fog_compute.volumes.get(volume_id)) && volume.ready?
        print "Deleting volume... "
        volume.destroy
        wait_for_termination(volume, "deleting")
        puts ""
      else
        puts "Volume already destroyed"
      end
      provisioned.delete("disk_device")
    end
    
    def delete_key_pair
      key_pair_name = attributes.exists?("key_pair.name")
      if key_pair_name && key_pair = fog_compute.key_pairs.get(key_pair_name)
        puts "Deleting key pair '#{key_pair_name}'"
        key_pair.destroy
      else
        puts "Keypair already destroyed"
      end
      attributes.delete("key_pair")
    end
    

    def release_ip_address
      public_ip = provisioned.exists?("ip_address")
      if public_ip && ip_address = fog_compute.addresses.get(public_ip)
        puts "Releasing IP address #{public_ip}"
        ip_address.destroy
      else
        puts "IP address already released"
      end
      provisioned.delete("ip_address")
    end

    def security_groups
      @attributes.security_groups
    end

    def server_name
      @attributes["name"] ||= DEFAULT_SERVER_NAME
      @attributes.name
    end

    def key_name
      @attributes.key_pair.name
    end

    def private_key_path
      @private_key_path ||= File.join(@ssh_dir, key_name)
    end

    def public_key
      @attributes.exists?("key_pair.public_key")
    end

    # Flavor/instance type of the server to be provisioned
    # TODO: DEFAULT_FLAVOR should become IaaS/provider specific
    def flavor
      @attributes["flavor"] ||= DEFAULT_FLAVOR
    end

    # Size of attached persistent disk for the inception server
    def disk_size
      @attributes["disk_size"] ||= DEFAULT_DISK_SIZE
    end

    def ip_address
      provisioned.ip_address
    end

    def image_id
      @attributes["image_id"] ||= @provider_client.image_id
    end

    # The progresive/final attributes of the provisioned Inception server &
    # persistent disk.
    def provisioned
      @attributes["provisioned"] = {} unless @attributes["provisioned"]
      @attributes.provisioned
    end

    # Because @attributes["provisioned"] is not the same as @attributes.provisioned
    # we need a helper to export the complete nested attributes.
    def export_attributes
      attrs = attributes.to_nested_hash
      attrs["provisioned"] = provisioned.to_nested_hash
      attrs
    end

    def disk_devices
      provisioned["disk_device"] ||= default_disk_device
    end

    def external_disk_device
      disk_devices["external"]
    end

    def default_disk_device
      case @provider_client
      when Inception::Providers::Clients::AwsProviderClient
        { "external" => "/dev/sdf", "internal" => "/dev/xvdf" }
      when Inception::Providers::Clients::OpenStackProviderClient
        { "external" => "/dev/vdc", "internal" => "/dev/vdc" }
      else
        raise "Please implement InceptionServer#default_disk_device for #{@provider_client.class}"
      end
    end

    def user_host
      "#{provisioned.username}@#{provisioned.host}"
    end

    def fog_server
      @fog_server ||= begin
        if server_id = provisioned["server_id"]
          fog_compute.servers.get(server_id)
        end
      end
    end

    def fog_compute
      @provider_client.fog_compute
    end

    protected
    # set_resource_name(fog_server, "inception")
    # set_resource_name(volume, "inception-root")
    # set_resource_name(volume, "inception-store")
    def set_resource_name(resource, name)
      @provider_client.set_resource_name(resource, name)
    end

    def fog_attributes
      @provider_client.fog_attributes(self)
    end

    def validate_attributes_for_bootstrap
      missing_attributes = []
      missing_attributes << "provisioned.ip_address" unless @attributes.exists?("provisioned.ip_address")
      missing_attributes << "key_pair.private_key" unless @attributes.exists?("key_pair.private_key")
      if missing_attributes.size > 0
        raise "Missing InceptionServer attributes: #{missing_attributes.join(', ')}"
      end
    end

    # ssh group must be first (bootstrap method looks for port 22 in first group)
    def ensure_required_security_groups
      if @attributes["security_groups"] && @attributes["security_groups"].is_a?(Array)
        unless @attributes["security_groups"].include?("ssh")
          @attributes["security_groups"] = ["ssh", *@attributes["security_groups"]]
        end
      else
        @attributes["security_groups"] = ["ssh"]
      end
    end

    def create_missing_default_security_groups
      # provider method only creates group if missing
      @provider_client.create_security_group("ssh", "ssh", {ssh: 22})
    end

    def bootstrap_vm
      unless fog_server
        print "Booting #{flavor} inception server... "
        @fog_server = @provider_client.bootstrap(fog_attributes)
        provisioned["server_id"] = fog_server.id
        provisioned["host"] = fog_server.dns_name || fog_server.public_ip_address
        provisioned["username"] = fog_attributes[:username]
        puts provisioned.server_id
      end
      set_resource_name(fog_server, server_name)
    end

    def attach_persistent_disk
      unless Fog.mocking?
        print "Confirming ssh access to server... "
        Fog.wait_for(60) { fog_server.sshable?(ssh_options) }
        puts "done"
      end

      unless volume = @provider_client.find_server_device(fog_server, external_disk_device)
        print "Provisioning #{disk_size}Gb persistent disk for inception server... "
        volume = @provider_client.create_and_attach_volume("Inception Disk", disk_size, fog_server, external_disk_device)
        disk_devices["volume_id"] = volume.id
        puts disk_devices.volume_id
      end
      set_resource_name(volume, server_name)
    end

    def ssh_options
      {
        keys: [private_key_path]
      }
    end

    # Poll a fog model until it terminates; print . each second
    def wait_for_termination(fog_model, state_to_wait_for="terminated")
      fog_model.wait_for do
        print "."
        state == state_to_wait_for
      end
    end

    protected
    # TODO emit events rather than writing directly to STDOUT
    def say(*args)
      puts(*args)
    end
  end
end