#!/usr/bin/env bats

load discover_user

@test "~/.fog contains default.aws_access_key_id" {
  run su - $TEST_USER -c "cat $TEST_USER_HOME/.fog"
  [ "${lines[0]}" = "---" ]
  [ "${lines[1]}" = ":default:" ]
  [ "${lines[2]}" = "  :aws_access_key_id: PERSONAL_ACCESS_KEY" ]
  [ "${lines[3]}" = "  :aws_secret_access_key: PERSONAL_SECRET" ]
}
