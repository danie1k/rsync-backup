#!/usr/bin/env bats
# shellcheck disable=SC2034

given_yaml_config='
path:
  source: /tmp/
  remote: tmp/
rsync:
  info:
    - progress2
    - name0
'

setup() {
  load 'test_helper/common-setup'
  _common_setup

  if [[ "${BATS_TEST_NUMBER:?}" -eq 1 ]]; then
    echo "DEBUG: $(dasel --version)" >&3
    echo "DEBUG: $(yq --version)" >&3
  fi
}

teardown() {
  unset foo_bar
}

# _get_version -----------------------------------------------------------------

@test "_get_version : when no needle given" {
  # MOCK
  foo_bar() { echo 'foo_bar version 42.314'; }

  # WHEN
  run _get_version foo_bar

  # THEN
  assert_success
  assert_output '42.314'
}

@test "_get_version : when needle given" {
  # MOCK
  foo_bar() { echo 'foo_bar version 42 3.14'; }

  # WHEN
  run _get_version foo_bar 3

  # THEN
  assert_success
  assert_output '42'
}

@test "_get_version : when command/executable does not exist" {
  # WHEN
  run _get_version inexistent_command_name

  # THEN
  assert_success
  assert_output --regexp '^-$'
}

# _get_config_list -------------------------------------------------------------

# dasel

@test "_get_config_list : dasel : when a valid path given" {
  # MOCK
  DASEL_VER='anything'
  YQ_VER="${__NO_VALUE__:?}"

  # WHEN
  run _get_config_list "${given_yaml_config}" '.rsync.info'

  # THEN
  assert_success
  assert_output $'progress2\nname0'
}

@test "_get_config_list : dasel : when path to non-list given" {
  # MOCK
  DASEL_VER='anything'
  YQ_VER="${__NO_VALUE__:?}"

  # WHEN
  result="$(_get_config_list "${given_yaml_config}" '.path.source')"

  # THEN
  assert_equal $? 0
  assert_equal "${result}" "${__NO_VALUE__:?}"
}

@test "_get_config_list : dasel : when invalid path given" {
  # MOCK
  DASEL_VER='anything'
  YQ_VER="${__NO_VALUE__:?}"

  # WHEN
  result="$(_get_config_list "${given_yaml_config}" '.foo.bar')"

  # THEN
  assert_equal $? 0
  assert_equal "${result}" "${__NO_VALUE__:?}"
}

# yq

@test "_get_config_list : yq : when a valid path given" {
  # MOCK
  DASEL_VER="${__NO_VALUE__:?}"
  YQ_VER='anything'

  # WHEN
  run _get_config_list "${given_yaml_config}" '.rsync.info'

  # THEN
  assert_success
  assert_output $'progress2\nname0'
}

@test "_get_config_list : yq : when path to non-list given" {
  # MOCK
  DASEL_VER="${__NO_VALUE__:?}"
  YQ_VER='anything'

  # WHEN
  result="$(_get_config_list "${given_yaml_config}" '.path.source')"

  # THEN
  assert_equal $? 0
  assert_equal "${result}" "${__NO_VALUE__:?}"
}

@test "_get_config_list : yq : when invalid path given" {
  # MOCK
  DASEL_VER="${__NO_VALUE__:?}"
  YQ_VER='anything'

  # WHEN
  result="$(_get_config_list "${given_yaml_config}" '.foo.bar')"

  # THEN
  assert_equal $? 0
  assert_equal "${result}" "${__NO_VALUE__:?}"
}

# _get_config_value -------------------------------------------------------------

# dasel

@test "_get_config_value : dasel : when a valid path given" {
  # MOCK
  DASEL_VER='anything'
  YQ_VER="${__NO_VALUE__:?}"

  # WHEN
  run _get_config_value "${given_yaml_config}" '.path.source'

  # THEN
  assert_success
  assert_output '/tmp/'
}

@test "_get_config_value : dasel : when path to non-plain-value" {
  # MOCK
  DASEL_VER='anything'
  YQ_VER="${__NO_VALUE__:?}"

  # WHEN
  result="$(_get_config_value "${given_yaml_config}" '.rsync.info')"

  # THEN
  assert_equal $? 0
  assert_equal "${result}" '[progress2 name0]'
}

@test "_get_config_value : dasel : when invalid path given" {
  # MOCK
  DASEL_VER='anything'
  YQ_VER="${__NO_VALUE__:?}"

  # WHEN
  result="$(_get_config_value "${given_yaml_config}" '.foo.bar')"

  # THEN
  assert_equal $? 0
  assert_equal "${result}" "${__NO_VALUE__:?}"
}

# yq

@test "_get_config_value : yq : when a valid path given" {
  # MOCK
  DASEL_VER="${__NO_VALUE__:?}"
  YQ_VER='anything'

  # WHEN
  run _get_config_value "${given_yaml_config}" '.path.source'

  # THEN
  assert_success
  assert_output '/tmp/'
}

@test "_get_config_value : yq : when path to non-plain-value" {
  # MOCK
  DASEL_VER="${__NO_VALUE__:?}"
  YQ_VER='anything'

  # WHEN
  result="$(_get_config_value "${given_yaml_config}" '.rsync.info')"

  # THEN
  assert_equal $? 0
  assert_equal "${result}" $'- progress2\n- name0'
}

@test "_get_config_value : yq : when invalid path given" {
  # MOCK
  DASEL_VER="${__NO_VALUE__:?}"
  YQ_VER='anything'

  # WHEN
  result="$(_get_config_value "${given_yaml_config}" '.foo.bar')"

  # THEN
  assert_equal $? 0
  assert_equal "${result}" "${__NO_VALUE__:?}"
}
