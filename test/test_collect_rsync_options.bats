#!/usr/bin/env bats

# shellcheck disable=SC2034
setup() {
  load 'test_helper/common-setup'
  _common_setup

  DRY_RUN_FLAG=0
  RSYNC_INFO="${__NO_VALUE__:?}"
  SSH_KEY='./path/to/key'
  SSH_PORT='42'
}

teardown() {
  unset DRY_RUN_FLAG
  unset RSYNC_INFO
  unset SSH_KEY
  unset SSH_PORT
}

@test "collect_rsync_options : without optional config, no dry-run" {
  assert_equal "${RSYNC_OPTIONS:-}" ''

  # WHEN
  collect_rsync_options

  # THEN
  assert_equal $? 0
  output="${RSYNC_OPTIONS[*]}"
  assert_output --partial '--human-readable'
  assert_output --partial '--rsh ssh -p 42 -i ./path/to/key'
  assert_output --partial '--info progress2'
  refute_output --partial '--itemize-changes'
  refute_output --partial '--dry-run'
}

@test "collect_rsync_options : with optional config, no dry-run" {
  assert_equal "${RSYNC_OPTIONS:-}" ''

  # GIVEN
  RSYNC_INFO='foo,bar'

  # WHEN
  collect_rsync_options

  # THEN
  assert_equal $? 0
  output="${RSYNC_OPTIONS[*]}"
  assert_output --partial '--human-readable'
  assert_output --partial '--rsh ssh -p 42 -i ./path/to/key'
  assert_output --partial '--info foo,bar'
  refute_output --partial '--itemize-changes'
  refute_output --partial '--dry-run'
}

@test "collect_rsync_options : without optional config, with dry-run" {
  assert_equal "${RSYNC_OPTIONS:-}" ''

  # GIVEN
  DRY_RUN_FLAG=1

  # WHEN
  collect_rsync_options

  # THEN
  assert_equal $? 0
  output="${RSYNC_OPTIONS[*]}"
  assert_output --partial '--human-readable'
  assert_output --partial '--rsh ssh -p 42 -i ./path/to/key'
  assert_output --partial '--info progress2'
  assert_output --partial '--itemize-changes'
  assert_output --partial '--dry-run'
}

@test "collect_rsync_options : with optional config, with dry-run" {
  assert_equal "${RSYNC_OPTIONS:-}" ''

  # GIVEN
  DRY_RUN_FLAG=1
  RSYNC_INFO='lorem,ipsum'

  # WHEN
  collect_rsync_options

  # THEN
  assert_equal $? 0
  output="${RSYNC_OPTIONS[*]}"
  assert_output --partial '--human-readable'
  assert_output --partial '--rsh ssh -p 42 -i ./path/to/key'
  assert_output --partial '--info lorem,ipsum'
  assert_output --partial '--itemize-changes'
  assert_output --partial '--dry-run'
}
