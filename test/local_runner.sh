#!/usr/bin/env bats



@test "run without specifying a command and no default set for ${LOC}" {
  cp "_fancy.json" "${LOC}"
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




function teardown {
  if [ -f "${LOC}" ]; then
    rm "${LOC}"
  fi
}