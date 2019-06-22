#!/bin/bash
# This builds replicate:latest image.
# TBD: Create tag with Attunity version and incorporate into "custom" build scripts
# TBD: Templatize Docker file with MapR version.  Currently hardcoded to 6.0
set -x
. ../version.sh

[[ $1 = "getSoftwareOnly" ]] && getSoftwareOnly=true


#REPLICATE_VERSION=6.0
#REPLICATE_VERSION=6.1
REPLICATE_VERSION=6.1.0-316
DOCKERFILE_TEMPLATE=Dockerfile.template

if [[ $REPLICATE_VERSION = "6.0" ]] ; then
  ATTUNITY_RPM=areplicate-6.0.0-308.x86_64.rpm
  DOCKER_RPM=AttunityReplicate_6_0_0_Linux_X64.rpm
  LICENSE_FILE=license_exp2019-02-27_ser60009617.txt
  DOCKERFILE_TEMPLATE=Dockerfile.6.0.template
else
  #ATTUNITY_RPM=areplicate-6.1.0-237.x86_64.rpm
  ATTUNITY_RPM=areplicate-${REPLICATE_VERSION}.x86_64.rpm
  DOCKER_RPM=$ATTUNITY_RPM
  LICENSE_FILE=license.json
fi


[[ ! -f $LICENSE_FILE ]] && cp ../../AttunitySoftware/$LICENSE_FILE $LICENSE_FILE

if [[ ! -f $DOCKER_RPM ]] ; then
  if [[ -f ../../AttunitySoftware/$ATTUNITY_RPM ]]; then 
    cp ../../AttunitySoftware/$ATTUNITY_RPM ./$DOCKER_RPM 
  else
    echo "No Attunity Software RPM available for Docker" 
    exit
  fi
fi

[[ ! -d odbc ]] && \
  tar xzvf ../../AttunitySoftware/repl-doc.tgz 

[[ $getSoftwareOnly ]] && exit

########## Standard buildme.sh code to get MEP repo running for installing librdkafka
sed -e"s/MAPR_CORE_VER/$MAPR_CORE_VER/" \
    -e"s/MAPR_MEP_VER/$MAPR_MEP_VER/" \
    -e"s/MAPR_HADOOP_VER/$MAPR_HADOOP_VER/" \
    -e"s/ATTUNITY_RPM/$ATTUNITY_RPM/" \
    $DOCKERFILE_TEMPLATE > Dockerfile

# Start yum repository containers for build
for REPO in core mep ; do
  runContainer=false
  [[ $REPO == "core" ]] && hostPort=8080 && VERS=$MAPR_CORE_VER
  [[ $REPO == "mep" ]] && hostPort=8081 && VERS=$MAPR_MEP_VER
  MSG=""

  if containerRunning=$(docker inspect --format '{{ .State.Running }}' mapr-${REPO}-repo) ; then 
    if [[ "$containerRunning" = "true" ]] ; then
      repoPort=$(docker inspect mapr-${REPO}-repo | python -c 'import sys, json; print json.load(sys.stdin)[0]["NetworkSettings"]["Ports"]["80/tcp"][0]["HostPort"]')
      if [[ $repoPort -ne $hostPort ]]; then
        echo "mapr-${REPO}-repo not running with port 80 exposed to host as $hostPort ... removing container and restarting."
        docker rm -vf mapr-${REPO}-repo
        runContainer=true
      fi
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
done

# Use IP address.  Containers doing yum installs do not have /etc/hosts set up but can NAT out to local host's IP
HOSTIP=$(/sbin/ip route | awk '/^default/ { DEV=$5 }; $0~DEV && /^[0-9]/ { print $9;exit }')
echo "core http://$HOSTIP:8080" > REPOSITORY
echo "mep http://$HOSTIP:8081" >> REPOSITORY

# Set versions for MapR internet repos.
[[ -f mapr_core.repo.template ]] && sed -e"s/MAPR_CORE_VER/$MAPR_CORE_VER/" mapr_core.repo.template > mapr_core.repo
[[ -f mapr_mep.repo.template ]] && sed -e"s/MAPR_MEP_VER/$MAPR_MEP_VER/" mapr_mep.repo.template > mapr_mep.repo

#Modify Docker file to use MapR client rather than basic CentOS image
sed -i -e "s/^FROM .*/FROM mapr_client_centos7:$MAPR_CORE_VER/" Dockerfile



time docker build -t replicate_mapr:${REPLICATE_VERSION}_${MAPR_CORE_VER}_${MAPR_MEP_VER} .
#time docker build --no-cache -t replicate:$REPLICATE_VERSION .

#rm -rf $DOCKER_RPM Dockerfile odbc repinit.sh $LICENSE_FILE

