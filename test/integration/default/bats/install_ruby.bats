#!/usr/bin/env bats

load discover_user

expected_ruby_version = "1.9.3p429"

@test "ruby #{expected_ruby_version} is default" {
  run su - $TEST_USER -c "ruby -v"
  [ "$(echo ${lines[0]} | awk '{print $2}')" = expected_ruby_version ]
}
