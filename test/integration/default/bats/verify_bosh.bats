#!/usr/bin/env bats

load discover_user

@test "bosh micro installed" {
  run su - $TEST_USER -c "cd /var/vcap/store/microboshes; bundle exec bosh micro"
  [ "$status" -eq 0 ]
}

@test "bosh-cloudfoundry installed" {
  run su - $TEST_USER -c "cd /var/vcap/store/systems; bundle exec bosh cf"
  [ "$status" -eq 0 ]
}
