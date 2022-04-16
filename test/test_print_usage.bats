#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup

  # MOCK
  export DASEL_VER='42'
  export ENVSUBST_VER='42'
  export RSYNC_PROTOCOL_VER='42'
  export RSYNC_VER='42'
  export YQ_VER='42'
}

teardown() {
  unset DASEL_VER
  unset ENVSUBST_VER
  unset RSYNC_PROTOCOL_VER
  unset RSYNC_VER
  unset YQ_VER
}

@test "print_usage result" {
  # WHEN
  run print_usage

  # THEN
  assert_success
  assert_output --partial 'Usage:'
  assert_output --partial 'Options:'
  assert_output --partial 'dasel:'
  assert_output --partial 'envsubst:'
  assert_output --partial 'rsync:'
  assert_output --partial 'yq:'
}
