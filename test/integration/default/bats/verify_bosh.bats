#!/usr/bin/env bats

load discover_user

@test "bosh micro installed" {
  run su - $TEST_USER -c "cd /home/vagrant/workspace/microboshes; bundle exec bosh micro"
  [ "$status" -eq 0 ]
}

@test "bosh-bootstrap installed" {
  run su - $TEST_USER -c "cd /home/vagrant/workspace/systems; bundle exec bosh-bootstrap"
  [ "$status" -eq 0 ]
}
