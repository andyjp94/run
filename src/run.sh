#!/bin/bash


set -o pipefail
LOCS=("${PWD}/run.json" "${HOME}/run.json" "/etc/run/run.json")

function search_file {

  echo "searching $1"
  a=$(cat $file | jq --arg COMMAND $2 '.commands[] | select(.name == $COMMAND)')
  if [ "$a" != "" ]; then
    CMD=$(echo $a | jq -r '.value')
    num=$(cat $file | jq '.env | length')
    if [ "$num" != "0" ]; then
    for index in $( seq 1 ${num}); do
        env_json=$(cat $file | jq  --arg INDEX $((index-1)) '.env[$INDEX |tonumber]')
        ENV="${ENV} export $(echo $env_json | jq '.name')=$(echo $env_json | jq '.value');"; 
    done
    fi

    TEMP_FILE=$(mktemp /tmp/run.XXXXXXXX)
    LOG_FILE=$(mktemp /tmp/run.XXXXXXXX)
    echo -e '#!/bin/bash\nrun() {\n '"${CMD}"'\n}\n run' > ${TEMP_FILE}
    chmod +x ${TEMP_FILE}
    sh -c "${ENV} ${TEMP_FILE}" | tee ${LOG_FILE}
    if [ "$?" -ne "0" ]; then
      mv ${TEMP_FILE} ${PWD}/run.failed
      mv ${LOG_FILE} ${PWD}/run.log
      echo "The command failed. The script that was attempted is now available at ${PWD}/run.failed"
      echo "The log is available at ${PWD}/run.log"
    fi
    rm ${TEMP_FILE}

  fi
}




for file in ${LOCS[*]}; do 
    if [ -f $file ]; then
        search_file $file $1
    fi
done