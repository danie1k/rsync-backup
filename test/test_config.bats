#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup

  export TMPFILE="$(mktemp)"
}

teardown() {
  rm -f "${TMPFILE}"
  unset CONFIG_FILE
  unset TMPFILE
}

# get_config_file --------------------------------------------------------------

@test "get_config_file should fail with error message for unreadable path" {
  # GIVEN
  export CONFIG_FILE='./inexistent/path'

  # WHEN
  run get_config_file

  # THEN
  assert_failure
  assert_output --partial "Given config file path is invalid: '${CONFIG_FILE}'"
}

@test "get_config_file should output config file contents if path is valid" {
  # GIVEN
  given_config_contents=$'foo bar\nlorem ipsum'
  echo "${given_config_contents}" >"${TMPFILE}"
  export CONFIG_FILE="${TMPFILE}"

  # WHEN
  run get_config_file

  # THEN
  assert_success
  assert_output "${given_config_contents}"
}

@test "get_config_file should output config file contents through envsubst" {
  # GIVEN
  given_config_contents=$'foo bar\nlorem ipsum'
  echo "${given_config_contents}" >"${TMPFILE}"
  export CONFIG_FILE="${TMPFILE}"

  # MOCK
  envsubst() { echo "lorem ipsum config:$(</dev/stdin)"; }

  # WHEN
  run get_config_file

  # THEN
  assert_success
  assert_output "lorem ipsum config:${given_config_contents}"
}
