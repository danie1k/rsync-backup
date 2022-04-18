#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup
}

teardown() {
  PATH="${PATH_BACKUP:?}"
}

@test "check_prerequisites should not find awk executable" {
  # GIVEN
  # shellcheck disable=SC2123
  PATH='.'

  # WHEN
  run check_prerequisites

  PATH="${PATH_BACKUP:?}"
  # THEN
  assert_failure
  assert_output 'ERROR: awk is not available or not in your PATH. Please install awk and try again.'
}
