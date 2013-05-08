#!/usr/bin/env bats

@test "ruby 1.9.3p392 is default" {
  run su - vagrant -c "ruby -v"
  [ "$(echo ${lines[0]} | awk '{print $2}')" = "1.9.3p392" ]
}
