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