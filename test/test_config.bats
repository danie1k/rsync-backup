#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup

  export TMPFILE="$(mktemp)"
}

teardown() {
  set -e
  rm -f "${TMPFILE}" "${PROJECT_ROOT:?}/test/bin/envsubst"

  set +e
  unset CONFIG_FILE
  unset DASEL_VER
  unset YQ_VER
  unset TMPFILE

  unset SSH_KEY
  unset SSH_HOST
  unset SSH_PORT
  unset SSH_USER
  unset PATH_SOURCE
  unset PATH_REMOTE
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
  {
    echo '#!/bin/sh'
    echo 'echo -n "lorem ipsum config:"'
    echo 'while read line; do echo "$line"; done < "${1:-/dev/stdin}"'
  } > "${PROJECT_ROOT}/test/bin/envsubst"
  chmod a+x "${PROJECT_ROOT}/test/bin/envsubst"

  # WHEN
  run get_config_file

  # THEN
  assert_success
  assert_output "lorem ipsum config:${given_config_contents}"
}

# load_required_config ---------------------------------------------------------

@test "load_required_config should load config file using dasel" {
  # GIVEN
  export DASEL_VER='irrelevant'
  export YQ_VER="${__NO_VALUE__:?}"
  export CONFIG_FILE="${PROJECT_ROOT:?}/src/example.config.yml"

  assert_equal "${SSH_KEY:-}" ''
  assert_equal "${SSH_HOST:-}" ''
  assert_equal "${SSH_PORT:-}" ''
  assert_equal "${SSH_USER:-}" ''
  assert_equal "${PATH_SOURCE:-}" ''
  assert_equal "${PATH_REMOTE:-}" ''

  # WHEN
  load_required_config

  # THEN
  assert_equal $? 0
  # shellcheck disable=SC2088
  assert_equal "${SSH_KEY}" '~/.ssh/id_rda'
  assert_equal "${SSH_HOST}" 'example.com'
  assert_equal "${SSH_PORT}" '22'
  assert_equal "${SSH_USER}" 'johndoe'
  assert_equal "${PATH_SOURCE}" '/tmp/'
  assert_equal "${PATH_REMOTE}" 'tmp/'
}

@test "load_required_config should load config file using yq" {
  # GIVEN
  export DASEL_VER="${__NO_VALUE__:?}"
  export YQ_VER='irrelevant'
  export CONFIG_FILE="${PROJECT_ROOT:?}/src/example.config.yml"

  assert_equal "${SSH_KEY:-}" ''
  assert_equal "${SSH_HOST:-}" ''
  assert_equal "${SSH_PORT:-}" ''
  assert_equal "${SSH_USER:-}" ''
  assert_equal "${PATH_SOURCE:-}" ''
  assert_equal "${PATH_REMOTE:-}" ''

  # WHEN
  load_required_config

  # THEN
  assert_equal $? 0
  # shellcheck disable=SC2088
  assert_equal "${SSH_KEY}" '~/.ssh/id_rda'
  assert_equal "${SSH_HOST}" 'example.com'
  assert_equal "${SSH_PORT}" '22'
  assert_equal "${SSH_USER}" 'johndoe'
  assert_equal "${PATH_SOURCE}" '/tmp/'
  assert_equal "${PATH_REMOTE}" 'tmp/'
}
