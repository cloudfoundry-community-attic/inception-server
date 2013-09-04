#!/usr/bin/env bats

load discover_user

@test "~/.ssh/id_rsa" {
  [ -f $TEST_USER_HOME/.ssh/id_rsa ]
}

@test "~/.ssh/id_rsa.pub" {
  [ -f $TEST_USER_HOME/.ssh/id_rsa.pub ]
}

