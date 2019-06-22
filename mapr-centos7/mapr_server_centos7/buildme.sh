#!/bin/bash

. ../version.sh

sed -e"s/MAPR_CORE_VER/$MAPR_CORE_VER/" \
    -e"s/MAPR_HADOOP_VER/$MAPR_HADOOP_VER/" \
    Dockerfile.template > Dockerfile

# AML remove MEP
#    -e"s/MAPR_MEP_VER/$MAPR_MEP_VER/" 



# Start yum repository containers for build
#for REPO in core mep ; do
for REPO in core ; do
  runContainer=false
  [[ $REPO == "core" ]] && hostPort=8080 && VERS=$MAPR_CORE_VER
  # [[ $REPO == "mep" ]] && hostPort=8081 && VERS=$MAPR_MEP_VER
  MSG=""

  if containerRunning=$(docker inspect --format '{{ .State.Running }}' mapr-${REPO}-repo) ; then 
    if [[ "$containerRunning" = "true" ]] ; then
      :
    elif [[ "$containerRunning" = "false" ]] ; then
      docker start mapr-${REPO}-repo
    else # Unknown state for container.  Remove it so it will be restarted.
      echo "Unknown state \"$containerRunning\" for mapr-${REPO}-repo.  Removing container."
      docker rm -vf mapr-${REPO}-repo
      runContainer=true
    fi
  else
    runContainer=true
  fi

  $runContainer && \
             docker run -d \
               -p $hostPort:80 \
               --name mapr-${REPO}-repo \
               -h mapr-${REPO}-repo.mapr.local \
               mapr_${REPO}_repo:$VERS 

  repoPort=$(docker inspect mapr-${REPO}-repo | python -c 'import sys, json; print json.load(sys.stdin)[0]["NetworkSettings"]["Ports"]["80/tcp"][0]["HostPort"]')
  if [[ $repoPort -ne $hostPort ]]; then
  #if [[ $(docker inspect mapr-${REPO}-repo | \
  #        jq -r '.[]|.NetworkSettings.Ports."80/tcp"[].HostPort') -ne $hostPort ]] ; then
    echo "mapr-${REPO}-repo not running with port 80 exposed to host as $hostPort ... exiting"
    exit 1
  else
    RUNNING_IMAGE=$(docker inspect mapr-${REPO}-repo | python -c 'import sys, json; print json.load(sys.stdin)[0]["Config"]["Image"]')
    #RUNNING_IMAGE=$(docker inspect mapr-${REPO}-repo | jq -r .[].Config.Image)
    if [[ "$RUNNING_IMAGE" = "mapr_${REPO}_repo:$VERS" ]]; then
      #echo "$([[ ! -z $MSG ]] && echo -n "Disregard error, ")mapr-${REPO}-repo ${MSG}running on port $hostPort"
      echo "mapr-${REPO}-repo ${MSG}running on port $hostPort"
    else
      docker stop mapr-${REPO}-repo
      docker rm -vf mapr-${REPO}-repo
      docker run -d \
               -p $hostPort:80 \
               --name mapr-${REPO}-repo \
               -h mapr-${REPO}-repo.mapr.local \
               mapr_${REPO}_repo:$VERS 
    fi 
  fi
done

# Use IP address.  Containers doing yum installs do not have /etc/hosts set up but can NAT out to local host's IP
HOSTIP=$(/sbin/ip route | awk '/^default/ { DEV=$5 }; $0~DEV && /^[0-9]/ { print $9;exit }')
echo "core http://$HOSTIP:8080" > REPOSITORY

# Set versions for MapR internet repos.
[[ -f mapr_core.repo.template ]] && sed -e"s/MAPR_CORE_VER/$MAPR_CORE_VER/" mapr_core.repo.template > mapr_core.repo
# [[ -f mapr_mep.repo.template ]] && sed -e"s/MAPR_MEP_VER/$MAPR_MEP_VER/" mapr_mep.repo.template > mapr_mep.repo

#time docker build -t $(basename $(pwd)):${MAPR_CORE_VER}_${MAPR_MEP_VER} .
time docker build -t $(basename $(pwd)):${MAPR_CORE_VER} .

#rm -f REPOSITORY
