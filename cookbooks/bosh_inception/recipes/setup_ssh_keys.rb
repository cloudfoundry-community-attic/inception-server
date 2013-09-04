#
# Cookbook Name:: bosh_inception
# Recipe:: setup_ssh_keys
#
# Copyright (c) 2013 Dr Nic Williams, Stark & Wayne, LLC
#
# MIT License
#


execute "ssh-keygen" do
  command "ssh-keygen -N '' -f #{node["user"]["home"]}/.ssh/id_rsa"
  user node.user.username
  group node.user.username
  action :run
  environment ({'HOME' => node["user"]["home"]})
  not_if { File.exist?("#{node["user"]["home"]}/.ssh/id_rsa") }
end
