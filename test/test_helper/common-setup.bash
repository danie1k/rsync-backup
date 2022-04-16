#!/usr/bin/env bash

_common_setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  # get the containing directory of this file
  # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
  # as those will point to the bats executable's location or the preprocessed file respectively

  export PROJECT_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME:?}")/.." >/dev/null 2>&1 && pwd)"
  PATH="${PROJECT_ROOT}/src:${PROJECT_ROOT}/test/bin:${PATH}"

  export PATH_BACKUP="${PATH}"

  source rsync_offsite_backup.sh
}
