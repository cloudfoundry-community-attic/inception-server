#
# Cookbook Name:: bosh_inception
# Recipe:: install_ruby
#
# Copyright (c) 2013 Dr Nic Williams, Stark & Wayne, LLC
#
# MIT License
#

include_recipe "chruby::system"

bash "Install bundler"  do
  versioned_bundler = "bundler -v '>= 1.5.2'"
  code <<-BASH
    source /etc/profile.d/chruby.sh
    unset GEM_HOME
    unset GEM_PATH
    gem specification #{versioned_bundler} >/dev/null 2>&1 || gem install --no-rdoc --no-ri #{versioned_bundler}
  BASH
end
