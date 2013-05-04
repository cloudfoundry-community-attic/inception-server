#!/usr/bin/env bats

@test "bosh installed for vcap user" {
  run su - vcap -c bosh
  [ "$status" -eq 0 ]
}

@test "bosh micro installed for vcap user" {
  run su - vcap -c "bosh micro"
  [ "$status" -eq 0 ]
}
