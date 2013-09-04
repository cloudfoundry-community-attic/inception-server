#
# Cookbook Name:: bosh_inception
# Recipe:: install_ruby
#
# Copyright (c) 2013 Dr Nic Williams, Stark & Wayne, LLC
#
# MIT License
#

include_recipe "rvm::system"

group "rvm" do
  members "#{node.user.username}"
  append true
  action :modify
end
