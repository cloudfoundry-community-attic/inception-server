#!/usr/bin/env bats

@test "use file dirs created" {
  for dir in microboshes/deployments deployments releases repos stemcells inception tmp bosh_cache
  do
    [ -d /var/vcap/$dir ]
  done
}
