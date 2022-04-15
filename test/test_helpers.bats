#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup
}

teardown() {
  unset foo_bar
}

@test "_get_version :  when no needle given" {
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
