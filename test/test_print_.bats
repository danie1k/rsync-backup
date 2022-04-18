#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup

  # MOCK / GIVEN
  export DASEL_VER='42'
  export ENVSUBST_VER='42'
  export RSYNC_PROTOCOL_VER='42'
  export RSYNC_VER='42'
  export YQ_VER='42'

  export SSH_USER='foo'
  export SSH_HOST='bar'
  export PATH_REMOTE='lorem/'
  export JOB_NAME='ipsum'
  export PATH_SOURCE='/given/path/'
}

teardown() {
  unset DASEL_VER
  unset ENVSUBST_VER
  unset RSYNC_PROTOCOL_VER
  unset RSYNC_VER
  unset YQ_VER

  unset DRY_RUN_FLAG
  unset JOB_NAME
  unset PATH_REMOTE
  unset PATH_SOURCE
  unset SSH_HOST
  unset SSH_USER
}

# print_usage ------------------------------------------------------------------

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

# print_nice_header ------------------------------------------------------------

@test "print_nice_header : when dry run is disabled" {
  # GIVEN
  export DRY_RUN_FLAG=0

  # WHEN
  run print_nice_header

  # THEN
  assert_success
  assert_output --partial 'STARTING RSYNC SESSION'
  assert_output --partial 'Job name:      ipsum'
  assert_output --partial 'Dry run:       no'
  assert_output --partial 'Local source:  /given/path/'
  assert_output --partial 'Remote target: foo@bar:lorem/'
}

@test "print_nice_header : when dry run is enabled" {
  # GIVEN
  export DRY_RUN_FLAG=1

  # WHEN
  run print_nice_header

  # THEN
  assert_success
  assert_output --partial 'STARTING RSYNC SESSION'
  assert_output --partial 'Job name:      ipsum'
  assert_output --partial 'Dry run:       yes'
  assert_output --partial 'Local source:  /given/path/'
  assert_output --partial 'Remote target: foo@bar:lorem/'
}
