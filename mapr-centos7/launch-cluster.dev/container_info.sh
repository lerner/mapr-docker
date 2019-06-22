#!/bin/bash

# Get IP Address and hostname with container Name and Image for containers
# grep'd from docker ps by passed in arguments.
#
# Example: 
#  Get info for all containers created from image mysql:5.6
#	container_info.sh 'mysql:5.6' # without 5.6 tag, we get containers with mysql in their name also
#  Get info for all containers based on replicate image	
#	container_info.sh 'replicate' 
#  Get info for all containers in attn cluster
#	container_info.sh 'attn-' 
#  Get info for replicate container(s) in attn cluster
#	container_info.sh 'attn-' 'replicate'


GREPSTR="$@"
[[ -z $GREPSTR ]] && echo 'Usage: container_info.sh <docker_ps_grep_strings>' && exit

# Build pipeline of grep commands to filter down to desired containers
GREPCMD="docker ps "
for GREP in $GREPSTR; do
  GREPCMD+="| grep $GREP "
done
#CONTAINERIDS="$(docker ps | grep $GREPSTR | cut -f 1 -d ' ')"
CONTAINERIDS="$(eval $(echo $GREPCMD) | cut -f 1 -d ' ')"

FORMAT_STR='%-16s %-30s %-26s %-s\n'
printf "$FORMAT_STR" "IP Addr" "Hostname" "Container Name" "Image:Tag"

for ID in $CONTAINERIDS; do
  docker inspect $ID >$ID.json
  IP=$(jq -r '.[].NetworkSettings.Networks.mapr_nw.IPAMConfig.IPv4Address' $ID.json)
  HN=$(jq -r '.[].Config.Hostname' $ID.json)
  NAME=$(jq -r '.[].Name' $ID.json)
  IMAGE=$(jq -r '.[].Config.Image' $ID.json)
  printf "$FORMAT_STR" $IP $HN ${NAME#/} $IMAGE
  rm -f $ID.json
done

