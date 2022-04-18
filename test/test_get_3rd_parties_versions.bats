#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup

  unset DASEL_VER
  unset ENVSUBST_VER
  unset RSYNC_PROTOCOL_VER
  unset RSYNC_VER
  unset YQ_VER
}

@test "get_3rd_parties_versions" {
  # MOCK
  dasel() { echo 'lorem ipsum 42'; }
  envsubst() { echo 'lorem ipsum 42'; }
  rsync() { echo 'lorem ipsum foo bar 42'; }
  yq() { echo 'lorem ipsum 42'; }

  # WHEN
  get_3rd_parties_versions

  # THEN
  assert_equal $? 0
  assert_equal "${DASEL_VER:?}" '42'
  assert_equal "${ENVSUBST_VER:?}" '42'
  assert_equal "${RSYNC_PROTOCOL_VER:?}" '42'
  assert_equal "${RSYNC_VER:?}" 'foo'
  assert_equal "${YQ_VER:?}" '42'
}
