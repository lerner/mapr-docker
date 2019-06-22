#!/bin/bash

# Get script directory (absolute or relative) to this bash script
scriptDir=$(dirname $BASH_SOURCE)
[[ ! $scriptDir =~ ^/ ]] && scriptDir=$(pwd)/$scriptDir

if [[ -f $scriptDir/start-cluster-other.functions ]]; then
  . $scriptDir/start-cluster-other.functions
else
  echo "ERROR:  No $scriptDir/start-cluster-other.functions"
  exit
fi

initialize_other
rackem
wait_for_mount /apps
wait_for_mount /user
setup_user user1
setup_hivemeta
setup_spark
run_spark_test
run_hive_test
