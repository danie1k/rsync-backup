#!/usr/bin/env bash

_common_setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  # get the containing directory of this file
  # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
  # as those will point to the bats executable's location or the preprocessed file respectively

   # shellcheck disable=SC2154
  local project_root="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  PATH="${project_root}/src:${project_root}/test/bin:${PATH}"

  # shellcheck disable=SC2034
  PATH_BACKUP="${PATH}"

  source rsync_offsite_backup.sh
}
