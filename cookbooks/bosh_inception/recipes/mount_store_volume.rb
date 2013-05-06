if node.disk.mounted
  mount "/var/vcap/store" do
    device node.disk.device
    fstype node.disk.fstype
    action :mount
  end
end