#!/usr/bin/env bats

load discover_user

@test "git config name is set" {
  run git config -f $TEST_USER_HOME/.gitconfig user.name
  [ "${lines[0]}" = "Nobody" ]
}

@test "git config email is set" {
  run git config -f $TEST_USER_HOME/.gitconfig user.email
  [ "${lines[0]}" = "nobody@in-the-house.com" ]
}

@test "hub installed" {
  run hub
  [ "$status" -eq 0 ]
}
