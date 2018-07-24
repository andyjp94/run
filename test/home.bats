#!/usr/bin/env bats


@test "Only find and run commands in local file" {
  cp "./local/_default.json" "./run.json"
  cp "./home/_default.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"

  run ../src/run.sh

  [ "$status" -eq 0 ]
  [ "$output" = "local: This is the default command" ]
}

@test "Only find and run commands in user file" {
  cp "./local/_default.json" "./run.json"
  cp "./home/_default.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"

  run ../src/run.sh --user 

  [ "$status" -eq 0 ]
  [ "$output" = "home: This is the default command" ]
}

@test "Only find and run commands in user file shorthand" {
  cp "./local/_default.json" "./run.json"
  cp "./home/_default.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"

  run ../src/run.sh -u

  [ "$status" -eq 0 ]
  [ "$output" = "home: This is the default command" ]
}

@test "Only find and run commands in global file" {
  cp "./local/_default.json" "./run.json"
  cp "./home/_default.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"

  run ../src/run.sh --global

  [ "$status" -eq 0 ]
  [ "$output" = "global: This is the default command" ]
}

@test "Only find and run commands in global file shorthand" {
  cp "./local/_default.json" "./run.json"
  cp "./home/_default.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"

  run ../src/run.sh -g

  [ "$status" -eq 0 ]
  [ "$output" = "global: This is the default command" ]
}

@test "Only find and run commands in custom file shorthand" {
  cp "./local/_default.json" "./run.json"
  cp "./home/_default.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"
  cp "./_custom.json" "/tmp/run.json"

  run ../src/run.sh -f "/tmp/run.json"

  [ "$status" -eq 0 ]
  [ "$output" = "custom: This is the default command" ]
}

@test "Only find and run commands in custom file" {
  cp "./local/_default.json" "./run.json"
  cp "./home/_default.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"
  cp "./_custom.json" "/tmp/run.json"

  run ../src/run.sh --file "/tmp/run.json"

  [ "$status" -eq 0 ]
  [ "$output" = "custom: This is the default command" ]
}

function teardown {
    rm "./run.json"
    rm "${HOME}/run.json"
    rm "/etc/run/run.json"
}

@test "Just list global commands" {
  cp "./local/_default.json" "./run.json"
  cp "./home/_default.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"
  run ../src/run.sh -l -g

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Commands available in /etc/run/run.json:" ]
  [ "${lines[1]}" = "[" ]
  [ "${lines[2]}" = "  {" ]
  [ "${lines[3]}" = '    "name": "default",' ]
  [ "${lines[4]}" = '    "value": "echo \"global: This is the default command\""' ]
  [ "${lines[5]}" = "  }" ]
  [ "${lines[6]}" = "]" ]
 
}

@test "Just list user commands" {
  cp "./local/_default.json" "./run.json"
  cp "./home/_default.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"
  run ../src/run.sh -l -u

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Commands available in ${HOME}/run.json:" ]
  [ "${lines[1]}" = "[" ]
  [ "${lines[2]}" = "  {" ]
  [ "${lines[3]}" = '    "name": "default",' ]
  [ "${lines[4]}" = '    "value": "echo \"home: This is the default command\""' ]
  [ "${lines[5]}" = "  }" ]
  [ "${lines[6]}" = "]" ]
 
}

@test "Just list custom commands" {
  cp "./local/_default.json" "./run.json"
  cp "./home/_default.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"
  cp "./_custom.json" "/tmp/run.json"
  run ../src/run.sh -l -f "/tmp/run.json"

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Commands available in /tmp/run.json:" ]
  [ "${lines[1]}" = "[" ]
  [ "${lines[2]}" = "  {" ]
  [ "${lines[3]}" = '    "name": "default",' ]
  [ "${lines[4]}" = '    "value": "echo \"custom: This is the default command\""' ]
  [ "${lines[5]}" = "  }" ]
  [ "${lines[6]}" = "]" ]
 
}

@test "Just autocomplete the user file" {

  cp "./local/_default.json" "./run.json"
  cp "./home/_simple.json" "${HOME}/run.json"
  cp "./global/_env.json" "/etc/run/run.json"

  run ../src/run.sh -u -c
  [ "$(cat ${HOME}/run_completions.sh)" = "complete -W init run.sh" ]
  [ "${lines[0]}" = "The autocomplete configuration files is available at ${HOME}/run_completions.sh." ]
  [ "${lines[1]}" = "To use it simply source it, to source it on login add:" ]
  [ "${lines[2]}" =  "source ${HOME}/run_completions.sh" ]
  [ "${lines[3]}" =  "To your .bashrc" ]

}

@test "Just autocomplete the global file" {

  cp "./local/_env.json" "./run.json"
  cp "./home/_simple.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"

  run ../src/run.sh -g -c
  [ "$(cat ${HOME}/run_completions.sh)" = "complete -W default run.sh" ]
  [ "${lines[0]}" = "The autocomplete configuration files is available at ${HOME}/run_completions.sh." ]
  [ "${lines[1]}" = "To use it simply source it, to source it on login add:" ]
  [ "${lines[2]}" =  "source ${HOME}/run_completions.sh" ]
  [ "${lines[3]}" =  "To your .bashrc" ]

}