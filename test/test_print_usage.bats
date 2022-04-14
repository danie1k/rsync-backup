#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup
}

@test "print_usage result" {
  # WHEN
  run print_usage

  # THEN
  assert_success
  assert_output --partial 'Usage:'
  assert_output --partial 'Options:'
  assert_output --partial 'Version'
}
