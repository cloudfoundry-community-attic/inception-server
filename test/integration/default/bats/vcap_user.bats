#!/usr/bin/env bats

@test "vcap user created" {
  [ -d /home/#{node.user.username} ]
  [ -f /home/#{node.user.username}/.profile ]
  [ -f /home/#{node.user.username}/.bashrc ]
  # [ -f /home/#{node.user.username}/.bash_profile ]
}

@test "all sudoers access" {
  [ -f /etc/sudoers.d/vcap ]
  run sudo grep "%vcap  ALL=(vcap) ALL" /etc/sudoers.d/vcap
  [ "$status" -eq 0 ]
}

@test "~vcap/.bosh_cache symlink" {
  run readlink ~vcap/.bosh_cache
  [ "${lines[0]}" = "/var/vcap/store/bosh_cache" ]
}


