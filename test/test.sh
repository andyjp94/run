#!/bin/bash

set -e

mkdir /etc/run || exit 1
for loc in "./run.json" "${HOME}/run.json" "/etc/run/run.json" ;do
  cd ~/test/ || exit 1
  LOC=${loc} bats local_runner.sh

  
done