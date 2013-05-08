#
# Cookbook Name:: bosh_inception
# Recipe:: packages
#
# Copyright (c) 2013 Dr Nic Williams, Stark & Wayne, LLC
#
# MIT License
#

include_recipe "apt"

%w[
  build-essential libsqlite3-dev curl rsync git-core
  libmysqlclient-dev libxml2-dev libxslt-dev libpq-dev libsqlite3-dev
  runit
  genisoimage
  debootstrap kpartx qemu-kvm
  whois
  tmux mosh
  vim
].each do |pkg|
  package pkg
end
