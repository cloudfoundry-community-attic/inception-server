#!/usr/bin/env bats

@test "ruby 1.9.3p392 is default for ~vcap user" {
  run su - vcap -c "ruby -v"
  [ "$(echo ${lines[0]} | awk '{print $2}')" = "1.9.3p392" ]
}
