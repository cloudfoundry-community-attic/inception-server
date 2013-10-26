if node.disk.mounted
  if File.exist?(node.disk.device)
    package "btrfs-tools" if node.disk.fstype == "btrfs"

    bash "format #{node.disk.dir} partition" do
      code "mkfs.#{node.disk.fstype} #{node.disk.device}"
      not_if "cat /proc/mounts | grep #{node.disk.dir}"
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
      not_if "cat /proc/mounts | grep #{node.disk.dir}"
    end
  else
    $stderr.puts "Skipping mounting volume as cannot find #{node.disk.device}"
  end
end
