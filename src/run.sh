#!/bin/bash


set -o pipefail
set -e

VERSION=0.1
LOCS=("${PWD}/run.json" "${HOME}/run.json" "/etc/run/run.json")

function find_cmd {

  JSON_CMD=$(jq --arg COMMAND "${2}" '.commands[] | select(.name == $COMMAND)' < "${1}")
  if [ "${JSON_CMD}" != "" ]; then
    CMD="$(echo "${JSON_CMD}" | jq -r '.value')"
    return 0
  else
    return 1 
  fi
}

function create_environment { 
  local RUN_FILE="${1}"
  local num=0
  num=$(jq '.env | length' < "${RUN_FILE}")
  if [ "$num" != "0" ]; then
  local env_json=" "
    for index in $( seq 1 "${num}"); do
        env_json=$(jq  --arg INDEX $((index-1)) '.env[$INDEX |tonumber]' < "$RUN_FILE")
        ENV="${ENV} export $(echo "${env_json}" | jq '.name')=$(echo "${env_json}" | jq '.value');"; 
    done
  fi
  
}
function create_environment_local {
  local RUN_FILE="${1}"
  local env_dict="{}"
  env_dict=$(jq --arg COMMAND "${2}" '.commands[] | select(.name == $COMMAND) |.env' < "${RUN_FILE}")
  local num=0
  num=$(echo "${env_dict}" | jq 'length')
  if [ "${num}" != "0" ]; then
      local env_json=" "
    for index in $( seq 1 "${num}"); do
        env_json=$(echo "${env_dict}" | jq  --arg INDEX $((index-1)) '.[$INDEX |tonumber]')
         LOCAL_ENV="${LOCAL_ENV} export $(echo "${env_json}" | jq '.name')=$(echo "${env_json}" | jq '.value');"; 
    done
  fi
}
function create_path_local {
  PATH_CMD="export PATH=${PATH}:${PROGDIR}"
  local RUN_FILE="${1}"
  local env_dict="{}"
  path_dict=$(jq --arg COMMAND "${2}" '.commands[] | select(.name == $COMMAND) |.path' < "${RUN_FILE}")
  local num=0
  num=$(echo "${path_dict}" | jq 'length')
  if [ "${num}" != "0" ]; then
      local path_json=" "
    for index in $( seq 1 "${num}"); do
        path_json=$(echo "${path_dict}" | jq -r --arg INDEX $((index-1)) '.[$INDEX |tonumber]')
        LOCAL_PATH="${PATH_CMD}:${path_json}" 
    done
  fi
}

function create_path {
  
  local RUN_FILE="${1}"
  local num=0
  num=$(jq '.path | length' < "${RUN_FILE}")

  if [ "$num" != "0" ]; then
    local path_json=""
    for index in $( seq 1 "${num}"); do
        path_json=$(jq  -r --arg INDEX $((index-1)) '.path[$INDEX |tonumber]' < "${RUN_FILE}")
         PATH_CMD="${LOCAL_PATH}:${path_json}"
    done
  fi
  PATH_CMD="${PATH_CMD};"
}

function cleanup {
  rm "${TEMP_FILE}"
  rm "${LOG_FILE}"
}


function setup_command {
    local CMD="${1}"
    echo -e '#!/bin/bash\nrun() {\n '"${CMD}"'\n}\n run' > "${TEMP_FILE}"
    chmod +x "${TEMP_FILE}"
}

function error_handling { 
  error=$?
  if [ "$error" -ne "0" ]; then
    cleanup
    
  fi
  exit "${error}"
}

function run_command {
  trap command_error_handling EXIT
  if [ -n "${QUIET}" ];then
    sh -c "${ENV} ${TEMP_FILE}" 2&> "${LOG_FILE}"
  else
    sh -c "${ENV} ${TEMP_FILE}" | tee "${LOG_FILE}"
  fi
}

function command_error_handling {
  error=$?
  if [ "$error" -ne "0" ]; then
    mv "${TEMP_FILE}" "${PWD}"/run.failed
    mv "${LOG_FILE}" "${PWD}"/run.log
    echo "The command failed. The script that was attempted is now available at ${PWD}/run.failed"
    echo "The log is available at ${PWD}/run.log"

  fi
  cleanup
  exit "${error}"
  
}

function validate_file {
  local FILE="$1"
  local NUM_COMMANDS=""
  local NUM_UNIQUE_COMMANDS=""
  NUM_COMMANDS=$(jq '.commands | length' < "${FILE}")
  NUM_UNIQUE_COMMANDS=$(jq '.commands | unique_by(.name) | length' < "${FILE}")
  

  if [ "${NUM_COMMANDS}" != "${NUM_UNIQUE_COMMANDS}" ]; then
    echo "oh dear"
    exit 1
  fi 
}
function main {
 for file in ${LOCS[*]}; do 
    if [ -f "${file}" ]; then
      validate_file "${file}" "${1}"
      
      if find_cmd "$file" "${1}" ; then
        create_environment "${file}"
        create_environment_local "$file" "${1}"
        create_path_local "${file}" "${1}"
        create_path "${file}" 

        
        setup_command "${CMD}" "TEMP_FILE" "LOG_FILE"
        ENV="${ENV}${LOCAL_ENV}${CLI_ENV}${PATH_CMD}"
        echo ${ENV}

        run_command
        return 0
      fi
    fi
  done
   echo "error: command ${1} not found"
   exit 1
}

function list_commands {
  
 for file in ${LOCS[*]}; do 
    if [ -f "${file}" ]; then
     echo "Commands available in ${file}:"
     jq  '.commands' < "${file}"
    fi

    done
}

function complete_commands {
  local FILE_COMMANDS=""
  local COMMANDS=""
 for file in ${LOCS[*]}; do 
    if [ -f "${file}" ]; then
     FILE_COMMANDS=$(jq  -r '.commands[] | .name' < "${file}" )
     COMMANDS="${COMMANDS} ${FILE_COMMANDS}"
    fi
    done
    COMMANDS=$(echo "${COMMANDS}" | xargs -n 1 | sort -u )

    COMP_FILE="${HOME}/run_completions.sh"
    echo "complete -W ${COMMANDS} run.sh" >  "${COMP_FILE}"
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
    echo "      List the available commands, these are gathered from: ${LOCS[*]}"
    echo
    echo "  -v, --version"
    echo "      Prints the version of the command."
    echo
    echo "  --"
    echo "      Do not interpret any more arguments as options."
    echo
  }
  # File name
  readonly PROGNAME=$(basename "${0}")
  # File name, without the extension
  readonly PROGBASENAME=${PROGNAME%.*}
  # File directory
  readonly PROGDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  # Arguments
  readonly ARGS=("$@")
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
    -e|--environment)
      shift
      CLI_ENV="${CLI_ENV} export ${1};"
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
    -*)
      echo "Invalid option '$1'. Use --help to see the valid options" >&2
      exit 1
      ;;
    # an option argument, continue
    *)  
      break
    ;;
    esac

  done

  cmds=("$@")

}


function new_main {
  parse_arguments "${@}"
  TEMP_FILE=$(mktemp /tmp/run.XXXXXXXX)
  LOG_FILE=$(mktemp /tmp/run.XXXXXXXX)
  trap error_handling EXIT
  

  if [ -z "${cmds[0]}" ]; then
     main "default"
     exit 0
  fi
  

  for cmd in "${cmds[@]}"; do
  echo ${cmd}
    main "${cmd}"
  done

}

new_main "$@"









