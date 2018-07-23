#!/usr/bin/env bats



@test "run without specifying a command and no default set for ${LOC}" {
  cp "_missing.json" "${LOC}"
  run ../src/run.sh
  
  [ "$status" -eq 1 ]
  [ "$output" = "error: command default not found" ]
}

@test "run without specifying a command and a default set for ${LOC}" {
  cp "_default.json" "${LOC}"
  run ../src/run.sh 
  [ "$status" -eq 0 ]
  [ "$output" = "This is the default command" ]
}

@test "Run a command for ${LOC}" {
  cp "_simple.json" "${LOC}"
  run ../src/run.sh init

  [ "$status" -eq 0 ]
  [ "$output" = "This is the init command" ]
}

@test "Run a non-existent command for ${LOC}" {
  cp "_missing.json" "${LOC}"
  run ../src/run.sh init
  [ "$status" -eq 1 ]
  [ "$output" = "error: command init not found" ]
}

@test "List commands when none are available" {

  run ../src/run.sh -l
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "Set global environment variable for command" {
  cp "_env.json" "${LOC}"
  run ../src/run.sh global
  [ "$status" -eq 0 ]
  [ "$output" = "Setting env in command works" ]
}

@test "Set environment variable from the command line for command" {
  cp "_env.json" "${LOC}"
  run ../src/run.sh -e CUSTOM_ENV=works cli
  [ "$status" -eq 0 ]
  [ "$output" = "Setting env in command works" ]
}

@test "Set environment variable from the command line for command using whole word" {
  cp "_env.json" "${LOC}"
  run ../src/run.sh --environment CUSTOM_ENV=works cli
  [ "$status" -eq 0 ]
  [ "$output" = "Setting env in command works" ]
}



@test "Set environment variable from the command line for command" {
  cp "_env.json" "${LOC}"
  run ../src/run.sh -e CUSTOM_ENV=works cli
  [ "$status" -eq 0 ]
  [ "$output" = "Setting env in command works" ]
}

@test "Set environment variable from the command line for command using multiple args" {
  cp "_env.json" "${LOC}"
  run ../src/run.sh -e CUSTOM_ENV=works -e OTHER_CUSTOM_ENV=yay multiple_cli
  [ "$status" -eq 0 ]
  [ "$output" = "Setting env in command works, yay" ]
}

@test "Set environment variable from the command line for command using whole word and multiple args" {
  cp "_env.json" "${LOC}"
  run ../src/run.sh  --environment CUSTOM_ENV=works --environment OTHER_CUSTOM_ENV=yay multiple_cli
  [ "$status" -eq 0 ]
  [ "$output" = "Setting env in command works, yay" ]
}




@test "Set local environment variable for command" {
  cp "_env.json" "${LOC}"
  run ../src/run.sh "local"
  [ "$status" -eq 0 ]
  [ "$output" = "Setting env in command works" ]
}

@test "Run the default command in quiet mode" {
  cp "_default.json" "${LOC}"
  run ../src/run.sh -q
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}



function teardown {
  if [ -f "${LOC}" ]; then
    rm "${LOC}"
  fi
}