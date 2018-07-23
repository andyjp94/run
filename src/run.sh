#!/bin/bash

set -o pipefail
set -e

VERSION=0.1
LOCS=("${PWD}/run.json" "${HOME}/run.json" "/etc/run/run.json")

function find_cmd {
  JSON_CMD=$(cat $1 | jq --arg COMMAND $2 '.commands[] | select(.name == $COMMAND)')
  if [ "${JSON_CMD}" != "" ]; then
    CMD="$(echo ${JSON_CMD} | jq -r '.value')"
    return 0
  else
    return 1 
  fi
}

function create_environment { 
  local RUN_FILE="${1}"
  local num=$(cat ${RUN_FILE} | jq '.env | length')
  if [ "$num" != "0" ]; then
    for index in $( seq 1 ${num}); do
        local env_json=$(cat $RUN_FILE | jq  --arg INDEX $((index-1)) '.env[$INDEX |tonumber]')
         ENV="${ENV} export $(echo $env_json | jq '.name')=$(echo $env_json | jq '.value');"; 
    done
  fi
  
}

function create_path {
  PATH_CMD="export PATH=${PATH}:${PROGDIR}"
  local RUN_FILE="${1}"
  local num=$(cat ${1} | jq '.path | length')
  if [ "$num" != "0" ]; then
    for index in $( seq 1 ${num}); do
        local path_json=$(cat $RUN_FILE | jq  -r --arg INDEX $((index-1)) '.path[$INDEX |tonumber]')
         PATH_CMD="${PATH_CMD}:${path_json}"
    done
  fi
  PATH_CMD="${PATH_CMD};"
}

function cleanup {
  rm ${TEMP_FILE}
  rm ${LOG_FILE}
}


function setup_command {
    local CMD="${1}"
    echo -e '#!/bin/bash\nrun() {\n '"${CMD}"'\n}\n run' > ${TEMP_FILE}
    chmod +x ${TEMP_FILE}
}

function error_handling { 
  error=$?
  if [ "$error" -ne "0" ]; then
    mv ${TEMP_FILE} ${PWD}/run.failed
    mv ${LOG_FILE} ${PWD}/run.log
    echo "The command failed. The script that was attempted is now available at ${PWD}/run.failed"
    echo "The log is available at ${PWD}/run.log"
    cleanup
    
  fi
  exit "${error}"
}

function run_command {
  if [ -n "${QUIET}" ];then
    sh -c "${ENV} ${TEMP_FILE}" 2&> ${LOG_FILE}
  else
    sh -c "${ENV} ${TEMP_FILE}" | tee "${LOG_FILE}"
  fi
 
}
function main {
 for file in ${LOCS[*]}; do 
    if [ -f $file ]; then
      if find_cmd $file $1 ; then
        create_environment "${file}" 
        create_path "${file}" 
        setup_command "${CMD}" "TEMP_FILE" "LOG_FILE"
        ENV="${ENV}${CLI_ENV}${PATH_CMD}"
        run_command

        # cleanup
        return 0
      fi
    fi
  done
}

function list_commands {
  
 for file in ${LOCS[*]}; do 
    if [ -f $file ]; then
     echo "Commands available in ${file}:"
     cat $file | jq  '.commands'
    fi

    done
}

function complete_commands {
  
 for file in ${LOCS[*]}; do 
    if [ -f $file ]; then
     local FILE_COMMANDS=$(cat ${file} | jq  -r '.commands[] | .name' )
     local COMMANDS="${COMMANDS} ${FILE_COMMANDS}"
    fi
    done
    COMMANDS=$(echo "${COMMANDS}" | xargs -n 1 | sort -u )

    COMP_FILE="${HOME}/run_completions.sh"
    echo "complete -W ${COMMANDS} run.sh" >  ${COMP_FILE}
    echo "The autocomplete configuration files is available at ${COMP_FILE}."
    echo "To use it simply source it, to source it on login add:"
    echo "source ${COMP_FILE}"
    echo "To your .bashrc"
}



function parse_arguments {

usage() {
	echo ""
	echo
	echo "Usage: $PROGNAME [-e|--environment-var key=value] [-l|--list] [-q|--quiet] [-v|--version] [-h|--help] commands..."
	echo
	echo "Options:"
	echo
	echo "  -h, --help"
	echo "      This help text."
	echo
  echo "  -e, --environment-var key=value"
  echo "      Sets an environment variable for the process, this will override"
  echo "      any environment variables specified in the run.json files."
  echo 
  echo "  -q, --quiet"
  echo "      Sends stderr and stdout to the log file alone."
  echo
	echo "  -l, --list <file>"
	echo "      List the available commands, these are gathered from: ${LOCS[@]}"
	echo
	echo "  -v, --version"
	echo "      Prints the version of the command."
	echo
	echo "  --"
	echo "      Do not interpret any more arguments as options."
	echo
}
# File name
readonly PROGNAME=$(basename $0)
# File name, without the extension
readonly PROGBASENAME=${PROGNAME%.*}
# File directory
readonly PROGDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# Arguments
readonly ARGS="$@"
# Arguments number
readonly ARGNUM="$#"




while [ "$#" -gt 0 ]
do
	case "$1" in
	-h|--help)
		usage
		exit 0
		;;
  -c|--complete)
    complete_commands
    exit 0
    ;;
  -l|--list)
    list_commands
    exit 0
    ;;
	-e|--environment-var)
		CLI_ENV="${CLI_ENV} export ${2};"
		shift
		;;
  -q|--quiet)
    QUIET=1
    shift
    ;;
  -v|--version)
    echo "${VERSION}"
    exit 0
    ;;
	--)
		break
		;;
	-*)
		echo "Invalid option '$1'. Use --help to see the valid options" >&2
		exit 1
		;;
	# an option argument, continue
	*)	;;
	esac
  if ! [[ $string = *"-"* ]]; then
    return 0
  fi
	shift
done

echo $1

if [ -z $1 ]; then
  echo "Must specify the command."
  exit 1
 fi
}

parse_arguments $@
TEMP_FILE=$(mktemp /tmp/run.XXXXXXXX)
LOG_FILE=$(mktemp /tmp/run.XXXXXXXX)
trap error_handling EXIT


if [[ $1 = *","* ]]; then
  IFS=', ' read -r -a array <<< $1
  for element in "${array[@]}"
  do
      main $element
  done

else
  while [ "$#" -gt 0 ]
    do
    main $1
    shift 
    done
fi



