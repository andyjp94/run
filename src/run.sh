#!/bin/bash


set -o pipefail
LOCS=("${PWD}/run.json" "${HOME}/run.json" "/etc/run/run.json")
TEMP_FILE=$(mktemp /tmp/run.XXXXXXXX)
LOG_FILE=$(mktemp /tmp/run.XXXXXXXX)

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
  local num=$(cat ${1} | jq '.env | length')
  if [ "$num" != "0" ]; then
    for index in $( seq 1 ${num}); do
        local env_json=$(cat $RUN_FILE | jq  --arg INDEX $((index-1)) '.env[$INDEX |tonumber]')
         ENV="${ENV} export $(echo $env_json | jq '.name')=$(echo $env_json | jq '.value');"; 
    done
  fi
  
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
  local TEMP_FILE="${1}"
  local LOG_FILE="${2}"
  mv ${TEMP_FILE} ${PWD}/run.failed
  mv ${LOG_FILE} ${PWD}/run.log
  echo "The command failed. The script that was attempted is now available at ${PWD}/run.failed"
  echo "The log is available at ${PWD}/run.log"
  cleanup
}

function run_command {
  sh -c "${ENV} ${TEMP_FILE}" | tee "${LOG_FILE}"
  if [ "$?" -ne "0" ]; then
    error_handling ${TEMP_FILE} ${LOG_FILE}
    exit 1
  fi
}
function main {
 for file in ${LOCS[*]}; do 
    if [ -f $file ]; then
      if find_cmd $file $1 ; then
        create_environment "${file}" 
        setup_command "${CMD}" "TEMP_FILE" "LOG_FILE"
        run_command

        cleanup
        exit 0
      fi
    fi
  done
}



main $1