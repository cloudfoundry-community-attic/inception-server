#
# Cookbook Name:: bosh_inception
# Recipe:: git_config
#
# Copyright (c) 2013 Dr Nic Williams, Stark & Wayne, LLC
#
# MIT License
#

include_recipe "hub"

execute "git config user.name" do
  command "git config --global --replace-all user.name '#{node.git.name}'"
  user node.user.username
  group node.user.username
  action :run
  environment ({'HOME' => node["user"]["home"]})
end

execute "git config user.email" do
  command "git config --global --replace-all user.email '#{node.git.email}'"
  user node.user.username
  group node.user.username
  action :run
  environment ({'HOME' => node["user"]["home"]})
end

execute "git config color.ui" do
  command "git config --global color.ui true"
  user node.user.username
  group node.user.username
  action :run
  environment ({'HOME' => node["user"]["home"]})
end
