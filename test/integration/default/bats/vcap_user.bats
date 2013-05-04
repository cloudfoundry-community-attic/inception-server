#!/usr/bin/env bats

@test "vcap user created" {
  [ -d /home/vcap ]
  [ -f /home/vcap/.profile ]
  [ -f /home/vcap/.bashrc ]
  # [ -f /home/vcap/.bash_profile ]
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


