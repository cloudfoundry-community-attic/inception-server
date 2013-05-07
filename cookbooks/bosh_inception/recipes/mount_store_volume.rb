if node.disk.mounted
  bash "format /var/vcap/store partition" do
    code "mkfs.#{node.disk.fstype} #{node.disk.device} -F"
    not_if "cat /proc/mounts | grep /var/vcap/store"
  end

  directory node.disk.dir do
    owner "root"
    group "root"
    mode "0755"
    recursive true
    action :create
  end

  mount node.disk.dir do
    device node.disk.device
    options "rw noatime"
    fstype node.disk.fstype
    action [ :enable, :mount ]
    not_if "cat /proc/mounts | grep /var/vcap/store"
  end
end