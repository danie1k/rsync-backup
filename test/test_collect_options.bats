#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup

  unset CONFIG_FILE
  unset DRY_RUN_FLAG
  unset JOB_NAME
  unset LIST_ONLY_FLAG

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

@test "collect_options should print usage when no args given" {
  # WHEN
  run collect_options

  # THEN
  assert_failure
  assert_output --partial 'Usage:'
}

@test "collect_options should print usage when '-h' arg given" {
  # WHEN
  run collect_options -h

  # THEN
  assert_failure
  assert_output --partial 'Usage:'
}

@test "collect_options should exit with error when '--' arg given" {
  # WHEN
  run collect_options --help

  # THEN
  assert_failure
  assert_output --partial 'Long options are not supported'
}

@test "collect_options should correctly export 'CONFIG_FILE' variable" {
  # GIVEN
  local given_file_path='foo/bar.yml'

  # WHEN
  collect_options -c "${given_file_path}"

  # THEN
  assert_equal $? 0
  assert_equal "${CONFIG_FILE:?}" "${given_file_path}"
}

@test "collect_options should correctly export 'DRY_RUN_FLAG' variable" {
  # WHEN
  collect_options -d

  # THEN
  assert_equal $? 0
  assert_equal ${DRY_RUN_FLAG:?} 1
}

@test "collect_options should correctly export 'JOB_NAME' variable" {
  # GIVEN
  local given_name='lorem-ipsum'

  # WHEN
  collect_options -n "${given_name}"

  # THEN
  assert_equal $? 0
  assert_equal "${JOB_NAME:?}" "rsync:${given_name}"
}

@test "collect_options should correctly export 'LIST_ONLY_FLAG' variable" {
  # WHEN
  collect_options -l

  # THEN
  assert_equal $? 0
  assert_equal ${LIST_ONLY_FLAG:?} 1
}
