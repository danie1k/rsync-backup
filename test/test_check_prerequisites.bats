#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup
}

teardown() {
  PATH="${PATH_BACKUP:?}"
}

@test "check_prerequisites should not find dasel executable" {
  # GIVEN
  # shellcheck disable=SC2123
  PATH='.'

  # WHEN
  run check_prerequisites

  # THEN
  assert_failure
  assert_output 'ERROR: dasel is not available or not in your PATH. Please install dasel and try again.'
}
