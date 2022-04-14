#!/usr/bin/env bats

get_active_jobs_stdout=(
  '4055090.rsync:1234'
  '3052708.rsync:lorem'
  '3050193.rsync:ipsum'
)

setup() {
  load 'test_helper/common-setup'
  load 'test_helper/mocks/stub'
  _common_setup
}

@test "list_active_jobs should show message when no jobs" {
  # MOCK
  get_active_jobs() { echo ''; }

  # WHEN
  run list_active_jobs

  # THEN
  assert_output 'No active rsync jobs'
}

@test "list_active_jobs should show header and list of the jobs" {
  # MOCK
  get_active_jobs() { echo -e "${get_active_jobs_stdout[0]}\n${get_active_jobs_stdout[1]}\n${get_active_jobs_stdout[2]}"; }

  # WHEN
  run list_active_jobs

  # THEN
  assert_output --partial 'CURRENTLY ACTIVE RSYNC SESSIONS'
  assert_output --partial 'To attach to the session run: rsync -r'
  assert_output --partial "(01) ${get_active_jobs_stdout[0]}"
  assert_output --partial "(02) ${get_active_jobs_stdout[1]}"
  assert_output --partial "(03) ${get_active_jobs_stdout[2]}"
  refute_output --partial '(04)'
}
