#!/usr/bin/env bats

@test "vcap user created" {
  [ -d /home/vagrant ]
  [ -f /home/vagrant/.profile ]
  [ -f /home/vagrant/.bashrc ]
  # [ -f /home/vagrant/.bash_profile ]
}

# @test "all sudoers access" {
#   [ -f /etc/sudoers.d/vcap ]
#   run sudo grep "%vcap  ALL=(vcap) ALL" /etc/sudoers.d/vcap
#   [ "$status" -eq 0 ]
# }
# 
@test "~vagrant/.bosh_cache symlink" {
  run readlink ~vagrant/.bosh_cache
  [ "${lines[0]}" = "/var/vcap/store/bosh_cache" ]
}

