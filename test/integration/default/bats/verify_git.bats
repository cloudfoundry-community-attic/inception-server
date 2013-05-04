#!/usr/bin/env bats

@test "git config name is set" {
  run git config -f ~vcap/.gitconfig user.name
  [ "${lines[0]}" = "Nobody" ]
  
}

@test "git config email is set" {
  run git config -f ~vcap/.gitconfig user.email
  [ "${lines[0]}" = "nobody@in-the-house.com" ]
}

@test "hub installed" {
  run hub
  [ "$status" -eq 0 ]
}
