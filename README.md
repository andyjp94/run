# Welcome to Run

# What is it?
If you are familiar with the scripts section of yarn or npm then you are familiar with what this is trying to achieve but without the baggage of requiring node. A json config file that specifies what commands should be run. This can be used like a makefile that can also do deployment or linting or set environment variables before running commands. The benefit of this over bash scripts is readability.

# How does it know about the commands? <a id="files"></a>
This command will look for commands in the following files in the order shown:
1. ```./run.json```
2. ```${HOME}/run.json```
3. ```/etc/run/run.json```

A run.json file with all potential sections should looks like this:
```
{
	"commands": [{
		"name": "init",
		"value": "echo 'build system in ${DEBUG} mode'"
	}],
	"env": [{
		"name": "DEBUG",
		"value": "false"
	}]
	"vars": [{
		"name": "website",
		"value": "andrewjohnperry.com"
	}]
}
```

The environment variables can be accessed in the normal bash way within the commands. Variables can be accessed within the commands
but are not set in the environment that the command is run in. I can't think of a use case for variables right now but I'm certain there
will be some. The variable syntax is very similar to jinja2 style templating. It will be possible to override environment variables or variables from the command line.

# What will version one look like?
Features:
1. Can run commands that are specified in any of the three files discussed [earlier](#files)
2. Can override any type of variable from the command line
3. Automated installation




