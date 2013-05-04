#!/usr/bin/env bats

@test "use file dirs created" {
  for dir in microboshes/deployments deployments releases repos stemcells systems tmp bosh_cache
  do
    [ -d /var/vcap/store/$dir ]
  done
}
