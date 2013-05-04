#
# Cookbook Name:: bosh_inception
# Recipe:: default
#
# Copyright (c) 2013 Dr Nic Williams, Stark & Wayne, LLC
#
# MIT License
#

include_recipe "bosh_inception::vcap_user"
include_recipe "bosh_inception::useful_dirs"
include_recipe "bosh_inception::packages"
include_recipe "bosh_inception::setup_git"
include_recipe "bosh_inception::install_ruby"
include_recipe "bosh_inception::install_bosh"
