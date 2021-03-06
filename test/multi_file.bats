#!/usr/bin/env bats

@test "run without specifying a command and no default set for ${LOC}" {
  cp "./local/_missing.json" "${LOC}"
  cp "./home/_missing.json" "${BACK_LOC}"
  run ../src/run.sh
  
  [ "$status" -eq 1 ]
  [ "$output" = "error: command default not found" ]
}

@test "run without specifying a command and a default set for ${LOC}" {
  cp "./local/_default.json" "${LOC}"
  cp "./home/_default.json" "${BACK_LOC}"
  run ../src/run.sh 
  [ "$status" -eq 0 ]
  [ "$output" = "local: This is the default command" ]
}

@test "Run a command for ${LOC}" {
  cp "./local/_simple.json" "${LOC}"
   cp "./home/_simple.json" "${BACK_LOC}"
  run ../src/run.sh init

  [ "$status" -eq 0 ]
  [ "$output" = "local: This is the init command" ]
}

@test "Run a non-existent command for ${LOC}" {
  cp "./local/_missing.json" "${LOC}"
  cp "./home/_missing.json" "${BACK_LOC}"
  run ../src/run.sh init
  [ "$status" -eq 1 ]
  [ "$output" = "error: command init not found" ]
}

@test "List commands when none are available" {

  run ../src/run.sh -l
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "List commands when one is available" {
  cp "./local/_default.json" "${LOC}"
  cp "./home/_default.json" "${BACK_LOC}"
  run ../src/run.sh -l
  
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Commands available in ${LOC}:" ]
  [ "${lines[1]}" = "[" ]
  [ "${lines[2]}" = "  {" ]
  [ "${lines[3]}" = '    "name": "default",' ]
  [ "${lines[4]}" = '    "value": "echo \"local: This is the default command\""' ]
  [ "${lines[5]}" = "  }" ]
  [ "${lines[6]}" = "]" ]
  [ "${lines[7]}" = "Commands available in ${BACK_LOC}:" ]
  [ "${lines[8]}" = "[" ]
  [ "${lines[9]}" = "  {" ]
  [ "${lines[10]}" = '    "name": "default",' ]
  [ "${lines[11]}" = '    "value": "echo \"home: This is the default command\""' ]
  [ "${lines[12]}" = "  }" ]
  [ "${lines[13]}" = "]" ]

}


@test "Set global environment variable for command" {
  cp "./local/_env.json" "${LOC}"
  cp "./home/_env.json" "${BACK_LOC}"
  run ../src/run.sh global
  [ "$status" -eq 0 ]
  [ "$output" = "local: Setting env in command works" ]
}

@test "Set environment variable from the command line for command" {
  cp "./local/_env.json" "${LOC}"
  cp "./home/_env.json" "${BACK_LOC}"
  run ../src/run.sh -e CUSTOM_ENV=works cli
  [ "$status" -eq 0 ]
  [ "$output" = "local: Setting env in command works" ]
}

@test "Set environment variable from the command line for command using whole word" {
  cp "./local/_env.json" "${LOC}"
  cp "./home/_env.json" "${BACK_LOC}"
  run ../src/run.sh --environment CUSTOM_ENV=works cli
  [ "$status" -eq 0 ]
  [ "$output" = "local: Setting env in command works" ]
}


@test "Set environment variable from the command line for command using multiple args" {
  cp "./local/_env.json" "${LOC}"
  cp "./home/_env.json" "${BACK_LOC}"
  run ../src/run.sh -e CUSTOM_ENV=works -e OTHER_CUSTOM_ENV=yay multiple_cli
  [ "$status" -eq 0 ]
  [ "$output" = "local: Setting env in command works, yay" ]
}

@test "Set environment variable from the command line for command using whole word and multiple args" {
  cp "./local/_env.json" "${LOC}"
  cp "./home/_env.json" "${BACK_LOC}"
  run ../src/run.sh  --environment CUSTOM_ENV=works --environment OTHER_CUSTOM_ENV=yay multiple_cli
  [ "$status" -eq 0 ]
  [ "$output" = "local: Setting env in command works, yay" ]
}




@test "Set local environment variable for command" {
  cp "./local/_env.json" "${LOC}"
  cp "./home/_env.json" "${BACK_LOC}"
  run ../src/run.sh "local"
  [ "$status" -eq 0 ]
  [ "$output" = "local: Setting env in command works" ]
}

@test "Run the default command in quiet mode" {
  cp "./local/_default.json" "${LOC}"
  cp "./home/_default.json" "${BACK_LOC}"
  run ../src/run.sh -q
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "Run the default command in quiet mode with full name" {
  cp "./local/_default.json" "${LOC}"
  cp "./home/_default.json" "${BACK_LOC}"
  run ../src/run.sh --quiet
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}


@test "Run multiple commands" {
  cp "./local/_env.json" "${LOC}"
  cp "./home/_env.json" "${BACK_LOC}"
  run ../src/run.sh "global" "local"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "local: Setting env in command works" ]
  [ "${lines[1]}" = "local: Setting env in command works" ]
}

@test "Run multiple commands and preserve cli environment overrides between commands" {
  cp "./local/_env.json" "${LOC}"
  cp "./home/_env.json" "${BACK_LOC}"
  run ../src/run.sh -e CUSTOM_ENV=works "local" "cli"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "local: Setting env in command works" ]
  [ "${lines[1]}" = "local: Setting env in command works" ]
}



function teardown {
  if [ -f "${LOC}" ]; then
    rm "${LOC}"
  fi
    if [ -f "${BACK_LOC}" ]; then
    rm "${BACK_LOC}"
  fi
}