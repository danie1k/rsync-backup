#!/usr/bin/env bats

_mock_screen() {
  screen_list_stdout_result='There are screens on:\n'
  screen_list_stdout_result+='  4060579.pts-14.foobar (Detached)\n'
  screen_list_stdout_result+='  4055090.rsync:1234    (Detached)\n'
  screen_list_stdout_result+='  3052708.rsync:lorem   (Detached)\n'
  screen_list_stdout_result+='  3050193.rsync:ipsum   (Detached)\n'
  screen_list_stdout_result+='5 Sockets in /run/screens/S-johndoe.\n'

  stub screen \
    "-list : echo $'${screen_list_stdout_result}'" \
    "-list : echo $'${screen_list_stdout_result}'"
}

setup() {
  load 'test_helper/common-setup'
  load 'test_helper/mocks/stub'
  _common_setup
  _mock_screen
}

@test "get_active_jobs : verify screen mock" {
  # WHEN
  run screen -list

  # THEN
  assert_output --partial 'There are screens on'
  assert_output --partial '4060579.pts-14.foobar (Detached)'
  assert_output --partial '5 Sockets in /run/screens/S-johndoe'
}

@test "get_active_jobs result" {
  expected_stdout_result=$'4055090.rsync:1234\n'
  expected_stdout_result+=$'3052708.rsync:lorem\n'
  expected_stdout_result+='3050193.rsync:ipsum'

  # WHEN
  run get_active_jobs

  # THEN
  assert_output "${expected_stdout_result}"
}
