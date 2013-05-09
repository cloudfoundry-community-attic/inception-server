# Copyright (c) 2012-2013 Stark & Wayne, LLC

module Bosh; module Providers; module Clients; end; end; end

require "bosh/providers/clients/fog_provider_client"
require "bosh/providers/constants/openstack_constants"

class Bosh::Providers::Clients::OpenStackProviderClient < Bosh::Providers::Clients::FogProviderClient
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

  # Creates or reuses an OpenStack security group and opens ports.
  # 
  # +security_group_name+ is the name to be created or reused
  # +ports+ is a hash of name/port for ports to open, for example:
  # {
  #   ssh: 22,
  #   http: 80,
  #   https: 443
  # }
  def create_security_group(security_group_name, description, ports)
    security_groups = fog_compute.security_groups
    unless sg = security_groups.find { |s| s.name == security_group_name }
      sg = fog_compute.security_groups.create(name: security_group_name, description: description)
      puts "Created security group #{security_group_name}"
    else
      puts "Reusing security group #{security_group_name}"
    end
    ip_permissions = sg.rules
    ports_opened = 0
    ports.each do |name, port_defn|
      (protocol, port_range, ip_range) = extract_port_definition(port_defn)
      unless port_open?(ip_permissions, port_range, protocol, ip_range)
        sg.create_security_group_rule(port_range.min, port_range.max, protocol, ip_range)
        puts " -> opened #{name} ports #{protocol.upcase} #{port_range.min}..#{port_range.max} from IP range #{ip_range}"
        ports_opened += 1
      end
    end
    puts " -> no additional ports opened" if ports_opened == 0
    true
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
  end

  def delete_security_group_and_servers(sg_name)
    raise "not implemented yet"
  end

  # Construct a Fog::Compute object
  # Uses +attributes+ which normally originates from +settings.provider+
  def setup_fog_connection
    configuration = Fog.symbolize_credentials(attributes.credentials)
    configuration[:provider] = "OpenStack"
    unless attributes.region == openstack_constants.no_region_code
      configuration[:openstack_region] = attributes.region
    end
    @fog_compute = Fog::Compute.new(configuration)
  end

  def openstack_constants
    Bosh::Providers::Constants::OpenStackConstants
  end
end
