#
# Cookbook Name:: bosh_inception
# Recipe:: git_config
#
# Copyright (c) 2013 Dr Nic Williams, Stark & Wayne, LLC
#
# MIT License
#

execute "git config user.name" do
  command "git config --global --replace-all user.name '#{node.git.name}'"
  user "vcap"
  group "vcap"
  action :run
  environment ({'HOME' => '/home/vcap'})
end

execute "git config user.email" do
  command "git config --global --replace-all user.email '#{node.git.email}'"
  user "vcap"
  group "vcap"
  action :run
  environment ({'HOME' => '/home/vcap'})
end

execute "git config color.ui" do
  command "git config --global color.ui true"
  user "vcap"
  group "vcap"
  action :run
  environment ({'HOME' => '/home/vcap'})
end

bash "install hub" do
  user "root"
  cwd "/var/vcap/store/repos"
  code <<-BASH
  if [[ ! -d hub ]]; then
    git clone https://github.com/defunkt/hub.git
    cd hub
  else
    cd hub
    git pull origin master
  fi
  rake install prefix=/usr/local
  BASH
  action :run
end

directory "/var/vcap/store/repos/hub" do
  owner "vcap"
  group "vcap"
  mode "0755"
  recursive true
  action :create
end
