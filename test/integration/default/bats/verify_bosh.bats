#!/usr/bin/env bats

@test "bosh micro installed for vcap user" {
  run su - vcap -c "cd /var/vcap/store/microboshes; bundle exec bosh micro"
  [ "$status" -eq 0 ]
}

@test "bosh-cloudfoundry installed for vcap user" {
  run su - vcap -c "cd /var/vcap/store/systems; bundle exec bosh cf"
  [ "$status" -eq 0 ]
}
