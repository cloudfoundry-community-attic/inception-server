# Copyright (c) 2012-2013 Stark & Wayne, LLC

module Inception; module Providers; module Clients; end; end; end

require "inception/providers/clients/fog_provider_client"
require "inception/providers/constants/aws_constants"

class Inception::Providers::Clients::AwsProviderClient < Inception::Providers::Clients::FogProviderClient
  include Inception::Providers::Constants::AwsConstants

  # @return [Integer] megabytes of RAM for requested flavor of server
  def ram_for_server_flavor(server_flavor_id)
    if flavor = fog_compute_flavor(server_flavor_id)
      flavor[:ram]
    else
      raise "Unknown AWS flavor '#{server_flavor_id}'"
    end
  end

  # @return [Hash] e.g. { :bits => 0, :cores => 2, :disk => 0,
  #   :id => 't1.micro', :name => 'Micro Instance', :ram => 613}
  # or nil if +server_flavor_id+ is not a supported flavor ID
  def fog_compute_flavor(server_flavor_id)
    aws_compute_flavors.find { |fl| fl[:id] == server_flavor_id }
  end

  # @return [Array] of [Hash] for each supported compute flavor
  # Example [Hash] { :bits => 0, :cores => 2, :disk => 0,
  #   :id => 't1.micro', :name => 'Micro Instance', :ram => 613}
  def aws_compute_flavors
    Fog::Compute::AWS::FLAVORS
  end

  def aws_compute_flavor_ids
    aws_compute_flavors.map { |fl| fl[:id] }
  end

  # Provision an EC2 or VPC elastic IP addess.
  # * VPC - provision_public_ip_address(vpc: true)
  # * EC2 - provision_public_ip_address
  # @return [String] provisions a new public IP address in target region
  # TODO nil if none available
  def provision_public_ip_address(options={})
    if options.delete(:vpc)
      options[:domain] = "vpc"
    else
      options[:domain] = options.delete(:domain) || "standard"
    end
    address = fog_compute.addresses.create(options)
    address.public_ip
    # TODO catch error and return nil
  end

  def associate_ip_address_with_server(ip_address, server)
    address = fog_compute.addresses.get(ip_address)
    address.server = server
  end

  def create_vpc(name, cidr_block)
    vpc = fog_compute.vpcs.create(name: name, cidr_block: cidr_block)
    vpc.id
  end

  # Creates a VPC subnet
  # @return [String] the subnet_id
  def create_subnet(vpc_id, cidr_block)
    subnet = fog_compute.subnets.create(vpc_id: vpc_id, cidr_block: cidr_block)
    subnet.subnet_id
  end

  def create_internet_gateway(vpc_id)
    gateway = fog_compute.internet_gateways.create(vpc_id: vpc_id)
    gateway.id
  end

  def find_server_device(server, device)
    server.volumes.all.find {|v| v.device == device}
  end

  def create_and_attach_volume(name, disk_size, server, device)
    volume = fog_compute.volumes.create(
        size: disk_size,
        name: name,
        description: '',
        device: device,
        availability_zone: server.availability_zone)
    # TODO: the following works in fog 1.9.0+ (but which has a bug in bootstrap)
    # https://github.com/fog/fog/issues/1516
    #
    # volume.wait_for { volume.status == 'available' }
    # volume.attach(server.id, "/dev/vdc")
    # volume.wait_for { volume.status == 'in-use' }
    #
    # Instead, using:
    volume.server = server
  end

  # Ubuntu 13.04
  def raring_image_id(region=nil)
    region = fog_compute.region
    # http://cloud-images.ubuntu.com/locator/ec2/
    image_id = case region.to_s
    when "ap-northeast-1"
      "ami-6b26ab6a"
    when "ap-southeast-1"
      "ami-2b511e79"
    when "eu-west-1"
      "ami-3d160149"
    when "sa-east-1"
      "ami-28e43e35"
    when "us-east-1"
      "ami-c30360aa"
    when "us-west-1"
      "ami-d383af96"
    when "ap-southeast-2"
      "ami-84a333be"
    when "us-west-2"
      "ami-bf1d8a8f"
    end
    image_id || raise("Please add Ubuntu 13.04 64bit (EBS) AMI image id to aws.rb#raring_image_id method for region '#{region}'")
  end

  def bootstrap(new_attributes = {})
    new_attributes[:image_id] ||= raring_image_id(fog_compute.region)
    vpc = new_attributes[:subnet_id]

    server = fog_compute.servers.new(new_attributes)

    unless new_attributes[:key_name]
      raise "please provide :key_name attribute"
    end
    unless private_key_path = new_attributes.delete(:private_key_path)
      raise "please provide :private_key_path attribute"
    end

    if vpc
      # TODO setup security group on new server
    else
      # make sure port 22 is open in the first security group
      security_group = fog_compute.security_groups.get(server.groups.first)
      authorized = security_group.ip_permissions.detect do |ip_permission|
        ip_permission['ipRanges'].first && ip_permission['ipRanges'].first['cidrIp'] == '0.0.0.0/0' &&
        ip_permission['fromPort'] == 22 &&
        ip_permission['ipProtocol'] == 'tcp' &&
        ip_permission['toPort'] == 22
      end
      unless authorized
        security_group.authorize_port_range(22..22)
      end
    end

    server.save
    unless Fog.mocking?
      server.wait_for { ready? }
      server.setup(:keys => [private_key_path])
    end
    server
  end

  # Construct a Fog::Compute object
  # Uses +attributes+ which normally originates from +settings.provider+
  def setup_fog_connection
    configuration = Fog.symbolize_credentials(attributes.credentials)
    configuration[:provider] = "AWS"
    configuration[:region] = attributes.region
    @fog_compute = Fog::Compute.new(configuration)
  end
end
