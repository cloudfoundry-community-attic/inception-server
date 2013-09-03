# Copyright (c) 2012-2013 Stark & Wayne, LLC

module Inception; module Providers; module Clients; end; end; end

require "inception/providers/clients/fog_provider_client"
require "inception/providers/constants/openstack_constants"

class Inception::Providers::Clients::OpenStackProviderClient < Inception::Providers::Clients::FogProviderClient
  # @return [String] provisions a new public IP address in target region
  # TODO nil if none available
  def provision_public_ip_address(options={})
    address = fog_compute.addresses.create
    address.ip
    # TODO catch error and return nil
  end

  def associate_ip_address_with_server(ip_address, server)
    address = fog_compute.addresses.find { |a| a.ip == ip_address }
    address.server = server
  end

  # Hook method for FogProviderClient#create_security_group
  def ip_permissions(sg)
    sg.rules
  end

  # Hook method for FogProviderClient#create_security_group
  def authorize_port_range(sg, port_range, protocol, ip_range)
    sg.create_security_group_rule(port_range.min, port_range.max, protocol, ip_range)
  end

  def find_server_device(server, device)
    va = fog_compute.get_server_volumes(server.id).body['volumeAttachments']
    va.find { |v| v["device"] == device }
  end

  def create_and_attach_volume(name, disk_size, server, device)
    volume = fog_compute.volumes.create(:name => name,
                                        :description => "",
                                        :size => disk_size,
                                        :availability_zone => server.availability_zone)
    volume.wait_for { volume.status == 'available' }
    volume.attach(server.id, device)
    volume.wait_for { volume.status == 'in-use' }
    volume
  end

  def image_id
    raise "Not yet implemented: add inception.image_id & inception.initial_user and re-run 'inception deploy'"
  end

  def default_disk_device
    { "external" => "/dev/vdc", "internal" => "/dev/vdc" }
  end

  # Construct a Fog::Compute object
  # Uses +attributes+ which normally originates from +settings.provider+
  def setup_fog_connection
    configuration = Fog.symbolize_credentials(attributes.credentials)
    configuration[:provider] = "OpenStack"
    @fog_compute = Fog::Compute.new(configuration)
  end

  def fog_attributes(inception_server)
    # :name => "Inception VM",
    # :key_name => key_name,
    # :private_key_path => inception_vm_private_key_path,
    # :flavor_ref => inception_flavor.id,
    # :image_ref => inception_image.id,
    # :security_groups => [settings["inception"]["security_group"]],
    # :username => username
    {
      name: inception_server.server_name,
      key_name: inception_server.key_name,
      private_key_path: inception_server.private_key_path,
      image_ref: inception_server.image_id,
      flavor_ref: flavor_id(inception_server.flavor),
      security_groups: inception_server.security_groups,
      public_key: inception_server.public_key,
      public_ip_address: inception_server.ip_address,
      bits: 64,
      username: inception_server.initial_user,
    }
  end

  def openstack_constants
    Inception::Providers::Constants::OpenStackConstants
  end
end
