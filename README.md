# Welcome to Run
[![Build Status](https://travis-ci.org/andyjp94/run.svg?branch=master)](https://travis-ci.org/andyjp94/run)  
## What is it?
If you are familiar with the scripts section of yarn or npm then you are familiar with what this is trying to achieve but without the baggage of requiring node. A json config file that specifies what commands should be run. This can be used like a makefile that can also do deployment or linting or set environment variables before running commands. The benefit of this over bash scripts is readability.

## How does it know about the commands? <a id="files"></a>
This command will look for commands in the following files in the order shown:
1. ```./run.json```
2. ```${HOME}/run.json```
3. ```/etc/run/run.json```

A run.json file with all potential sections should looks like this:
```
{
	"commands": [{
		"command": "default",
		"executes": ["echo \"This is the default command\""],
		"env": [{
			"name": "local_env",
			"value": "true"
		}],
		"path": ["/usr/sbin"]
	}],
	"env": [{
		"name": "global_env",
		"value": "true"
	}],
	"path": [
		"/usr/local/bin"
	]
}   
```

## How To:
Run the first default command found
```
./run.sh
```  
Run the default command found in "${HOME}/run.json
```
./run.sh --user
```
Create all the run.json files
```
./run.sh -i
```
Create the run.json in the working directory
```
./run.sh -wd
```
Overwrite an existing run.json
```
./run.sh -u -o
```
List all available commands
```
./run.sh -l
```
List the globally available commands
```
./run.sh -l -g
```
Generate the autocompletion file for all command
```
./run.sh -c
```
Generate the autocompletion file for a custom command
```
./run.sh -c -f x.json
```
Override an environment variable in run.json from cli
```
./run.sh -e x=y
```




The environment variables can be accessed in the normal bash way within the commands. Variables can be accessed within the commands
but are not set in the environment that the command is run in. I can't think of a use case for variables right now but I'm certain there
will be some. The variable syntax is very similar to jinja2 style templating. It will be possible to override environment variables or variables from the command line.


## Contributing
1. Clone repository
2. Configure the hooks
```
git config core.hooksPath .githooks
```
3. Install the development dependencies:
```
jq
shellcheck
https://github.com/sstephenson/bats.git
```



