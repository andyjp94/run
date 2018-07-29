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



@test "Just list global commands" {
  cp "./local/_default.json" "./run.json"
  cp "./home/_default.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"
  run ../src/run.sh -l -g

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Commands available in /etc/run/run.json:" ]
  [ "${lines[1]}" = "[" ]
  [ "${lines[2]}" = "  {" ]
  [ "${lines[3]}" = '    "command": "default",' ]
  [ "${lines[4]}" = '    "executes": [' ]
  [ "${lines[5]}" = '      "echo \"global: This is the default command\""' ]
  [ "${lines[6]}" = '    ]' ]
  [ "${lines[7]}" = "  }" ]
  [ "${lines[8]}" = "]" ]
 
}

@test "Just list user commands" {
  cp "./local/_default.json" "./run.json"
  cp "./home/_default.json" "${HOME}/run.json"
  cp "./global/_default.json" "/etc/run/run.json"
  run ../src/run.sh -l -u

  [ "$status" -eq 0 ]
  echo "${lines[0]}"
  [ "${lines[0]}" = "Commands available in /root/run.json:" ]
  [ "${lines[1]}" = "[" ]
  [ "${lines[2]}" = "  {" ]
  [ "${lines[3]}" = '    "command": "default",' ]
  [ "${lines[4]}" = '    "executes": [' ]
  [ "${lines[5]}" = '      "echo \"home: This is the default command\""' ]
  [ "${lines[6]}" = '    ]' ]
  [ "${lines[7]}" = "  }" ]
  [ "${lines[8]}" = "]" ]
 
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
  [ "${lines[3]}" = '    "command": "default",' ]
  [ "${lines[4]}" = '    "executes": [' ]
  [ "${lines[5]}" = '      "echo \"custom: This is the default command\""' ]
  [ "${lines[6]}" = '    ]' ]
  [ "${lines[7]}" = "  }" ]
  [ "${lines[8]}" = "]" ]
 
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



@test "Create the run.json in the working directory" {

  run ../src/run.sh -i -wd

  test_json="/tmp/test.json"

    [ "$status" -eq 0 ]

    jq '.' << EOF > "${test_json}"
{
	"commands": [{
		"command": "default",
		"executes": ["echo \"This is the default command\""],
    "watches": [],
		"env": [{
			"name": "local_env",
			"value": "true"
		}],
		"path": ["/usr/sbin"]
	}],
  "watches": [],
	"env": [{
		"name": "global_env",
		"value": "true"
	}],
	"path": [
		"/usr/local/bin"
	]
}
EOF

  diff "${test_json}" "./run.json"
   [ "$?" = "0" ]


}


@test "Create the run.json in the home directory" {

  run ../src/run.sh -i -u

  test_json="/tmp/test.json"

    [ "$status" -eq 0 ]

    jq '.' << EOF > "${test_json}"
{
	"commands": [{
		"command": "default",
		"executes": ["echo \"This is the default command\""],
    "watches": [],
		"env": [{
			"name": "local_env",
			"value": "true"
		}],
		"path": ["/usr/sbin"]
	}],
  "watches": [],
	"env": [{
		"name": "global_env",
		"value": "true"
	}],
	"path": [
		"/usr/local/bin"
	]
}
EOF

  diff "${test_json}" "${HOME}/run.json"
   [ "$?" = "0" ]

}


@test "Create the run.json in the /etc/run/ directory" {

  run ../src/run.sh -i -g

  test_json="/tmp/test.json"

    [ "$status" -eq 0 ]

    jq '.' << EOF > "${test_json}"
{
	"commands": [{
		"command": "default",
		"executes": ["echo \"This is the default command\""],
    "watches": [],
		"env": [{
			"name": "local_env",
			"value": "true"
		}],
		"path": ["/usr/sbin"]
	}],
  "watches": [],
	"env": [{
		"name": "global_env",
		"value": "true"
	}],
	"path": [
		"/usr/local/bin"
	]
}
EOF

  diff "${test_json}" "/etc/run/run.json"
   [ "$?" = "0" ]

}

@test "Create the run.json in a custom directory" {

  run ../src/run.sh -i -f "/tmp/run.json"

  test_json="/tmp/test.json"

    [ "$status" -eq 0 ]

    jq '.' << EOF > "${test_json}"
{
	"commands": [{
		"command": "default",
		"executes": ["echo \"This is the default command\""],
    "watches": [],
		"env": [{
			"name": "local_env",
			"value": "true"
		}],
		"path": ["/usr/sbin"]
	}],
  "watches": [],
	"env": [{
		"name": "global_env",
		"value": "true"
	}],
	"path": [
		"/usr/local/bin"
	]
}
EOF

  diff "${test_json}" "/tmp/run.json"
   [ "$?" = "0" ]

}

@test "Create the run.json in all the standard directories" {

  run ../src/run.sh -i

  test_json="/tmp/test.json"

    [ "$status" -eq 0 ]
  


    jq '.' << EOF > "${test_json}"
{
	"commands": [{
		"command": "default",
		"executes": ["echo \"This is the default command\""],
    "watches": [],
		"env": [{
			"name": "local_env",
			"value": "true"
		}],
		"path": ["/usr/sbin"]
	}],
  "watches": [],
	"env": [{
		"name": "global_env",
		"value": "true"
	}],
	"path": [
		"/usr/local/bin"
	]
}
EOF

  diff "${test_json}" "/etc/run/run.json"
   [ "$?" = "0" ]

  diff "${test_json}" "./run.json"
   [ "$?" = "0" ]

  diff "${test_json}" "${HOME}/run.json"
   [ "$?" = "0" ]

}

@test "init does not overwrite if flag is not set" {

  cp "./local/_env.json" "./run.json"

  run ../src/run.sh -i -wd

  [ "$status" -eq 1 ]
  
  [ "$lines" = "${PWD}/run.json already exists. To overwrite use the -o flag." ]
}

@test "init does overwrite file if flag is set" {

  cp "./local/_env.json" "./run.json"

  run ../src/run.sh -i -wd -o

  [ "$status" -eq 0 ]

    test_json="/tmp/test.json"

    jq '.' << EOF > "${test_json}"
{
	"commands": [{
		"command": "default",
		"executes": ["echo \"This is the default command\""],
    "watches": [],
		"env": [{
			"name": "local_env",
			"value": "true"
		}],
		"path": ["/usr/sbin"]
	}],
  "watches": [],
	"env": [{
		"name": "global_env",
		"value": "true"
	}],
	"path": [
		"/usr/local/bin"
	]
}
EOF

  diff "${test_json}" "./run.json"
   [ "$?" = "0" ]

}

@test "test running an array of commands" {
  cp "local/_multiple.json" "./run.json"
  run ../src/run.sh
  echo 
  [ "${lines[0]}" = "local: This is the first command" ]
  [ "${lines[1]}" = "local: This is the second command" ]
  [ "${lines[2]}" = "a" ]
  [ "$status" -eq 0 ]
}

@test "test adding optional arguments without specifying command" {
  cp "./local/_default.json" "./run.json"
  run ../src/run.sh "--" "a"
  [ "$status" -eq 0 ]
  [ "$lines" = "local: This is the default command a" ]
}

@test "test adding optional arguments" {
  cp "./local/_env.json" "./run.json"
  run ../src/run.sh "local" "--" ",yay"

  [ "$status" -eq 0 ]
  [ "$lines" = "local: Setting env in command works ,yay" ]
}

function teardown {
    for file in "./run.json" "${HOME}/run.json" "/etc/run/run.json" "/tmp/run.json"; do
      if [ -f "${file}" ]; then
        rm ${file}
      fi
    done
}