#!/bin/bash

LOCS=("${PWD}/run.json" "${HOME}/run.json" "/etc/run/run.json")

function search_file {

  echo "searching $1"
  a=$(cat $file | jq --arg COMMAND $2 '.commands[] | select(.name == $COMMAND)')
  if [ "$a" != "" ]; then
    num=$(cat $file | jq '.env | length')
    for index in $( seq 1 ${num}); do
        env_json=$(cat $file | jq  --arg INDEX $((index-1)) '.env[$INDEX |tonumber]')
        CMD="${CMD} export $(echo $env_json | jq '.name')=$(echo $env_json | jq '.value');"; 
    done

    echo -e '#!/bin/bash\necho_baz() { echo "[$DEBUG]"; }\n echo_baz' > /tmp/a.txt
    sh -c "${CMD} /tmp/a.txt"
    # echo ${CMD}

  fi
}




for file in ${LOCS[*]}; do 
    if [ -f $file ]; then
        search_file $file $1
    fi
done