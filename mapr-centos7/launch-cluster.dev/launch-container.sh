#!/bin/bash
# Parameters
# Cluster name
# User name (default to root for posix-client?)
# Posix-client (true/false)
# Image Name : Tag
#
# History:
#   20190402  Added -I option for running a DSR.  Yarn job required DSR be a known host.

# Examples: 
#
#   Start a postgress container
#   ./launch-container.sh -c sparky -u user1 -i mapr-pacc-postgres -p -v -m -U postgres -d /mapr/sparky/user/user1/postgres
#
#   Start a PACC
#   ./launch-container.sh -c drillsec -i maprtech/pacc:5.2.0_2.0_centos7 -p -m -u mapr
#
#   Start a twitter demo consumer
#   ./launch-container.sh -v -p -c drillsec -e "MAPR_PASSWORD=mapr" -u mapr -U mapr -t -i maprpartners/maprc-consumer:latest
#
#   Start a DSR as a regular user
#   CN=$(docker ps | grep '\-s1$' | sed -e 's/^.* //' -e 's/-s1$//') 
#   USERNAME=user1
#   /home/centos/.docker/mapr-centos7/launch-cluster/launch-container.sh -c $CN -i maprtech/data-science-refinery:v1.3.2_6.1.0_6.1.0_centos7 -I -u $USERNAME -U $USERNAME -m -t -p -e ZEPPELIN_NOTEBOOK_DIR=/mapr/$CN/user/$USERNAME/notebook
#   CID=$(docker ps | grep maprtech/data-science-refinery | cut -f 1 -d ' ')
#   docker exec $CID bash -c "MAPR_TICKETFILE_LOCATION=/tmp/mapr_ticket hadoop fs -put /opt/mapr/zeppelin/zeppelin-0.8.0/notebook /mapr/client610a/user/$USERNAME/"
#   while sleep 1; do echo -n "$(date): " ; zstatus=$(docker exec $CID  sudo -u $USERNAME /opt/mapr/zeppelin/zeppelin-0.8.0/bin/zeppelin-daemon.sh status); echo $zstatus; [[ "$zstatus" =~ "is running" ]] && break; done
#   sleep 10
#   docker exec $CID bash -c "sudo -u $USERNAME /opt/mapr/zeppelin/zeppelin-0.8.0/bin/zeppelin-daemon.sh restart"
#   echo "Browse to https://$(docker exec $CID hostname -f):9995"


usage() {
  echo ""
  echo "$(basename $0) "
  echo "          -c CLUSTERNAME          # MapR cluster name (docker container prefix)"
  echo "        [ -a DOCKER_RUN_ARGS ]    # Additional arguments to add to docker run command"
  echo "        [ -d POSTGRES_DATA_DIR ]  # MapR directory to be created for Postgres data"
  echo "        [ -e DOCKER_ENVVAR ]      # Option to pass into docker env variable (multiple -e options accepted)"
  echo "          -i DOCKER_IMAGE         # Docker image"
  echo "        [ -I ]                    # Find unused IP/hostname from -s1 /etc/hosts.  Default: Next available in docker network but won't be in server host files.  Incompatible with -w."
  echo "        [ -w ]                    # Re-start mapr-webproxy with updated /etc/hosts.  Incompatible with -I."
  echo "        [ -u USER_NAME ]          # Existing cluster user assigned ownership of MapR service ticket with impersonation (default: root)"
  echo "        [ -U USER_NAME ]          # Passed on to container as env var MAPR_CONTAINER_USER (default: root)"
  echo "        [ -m ]                    # Copy MapR ticket for Cluster user to client"
  echo "        [ -p ]                    # Docker container is MapR POSIX client"
  echo "        [ -r ]                    # Docker container run string passed into docker run"
#  echo "        [ -s ]                    # MapR security enabled"
  echo "        [ -t ]                    # Copy ssl_trustore from cluster to client"
  echo "        [ -V host_src:cntr_dest ] # Volume mapping. eg /home/centos/mysql:/var/mysql"
  echo "                                  # If block device file is specified instead of a host dir, a filesystem"
  echo "                                  # will be created on it. eg /var/mysql:/dev/xvdy"
  echo "        [ -O ]                    # Volume mount owner for chown (eg attunity:attunity)"
  echo "        [ -P ]                    # Volume mount permission for chmod (eg 775)"
  echo "        [ -v ]                    # Verbose"
  echo "        [ -W ]                    # Preview"
  echo "        [ -h ]                    # Print help message"
  echo ""
  exit
}

posixClient=false
VERBOSE=false
PREVIEW=false
dockerEnvStr=""
copySslTruststore=false
sslTruststoreMapping="" 
copyMaprTicket=false
maprTicketMapping=""
rerunWebProxy=false
volumeMapping=""
containerRunString=""
mntPerm=755
mntOwner=$(whoami)
extractIP=false

while getopts ":a:c:d:e:i:ImpO:P:r:tu:U:vV:wW" OPTION
do
  case $OPTION in
    a)
      addlDockerArgs=$OPTARG
      ;;
    c)
      clusterName=$OPTARG
      ;;
    d)
      dockerEnvStr+=" -e PGDATA_LOCATION=$OPTARG"
      ;;
    e)
      dockerEnvStr+=" -e $OPTARG"
      ;;
    i)
      dockerImage=$OPTARG
      ;;
    I)
      extractIP=true
      ;;
    m)
      copyMaprTicket=true
      ;;
    p)
      posixClientOptString="\
        -e MAPR_MOUNT_PATH=/mapr \
        --cap-add SYS_ADMIN \
        --cap-add SYS_RESOURCE \
        --device /dev/fuse \
       " 

       #  --privileged \

      ;;
    r)
      containerRunString="$OPTARG"
      ;;
    t)
      copySslTruststore=true
      ;;
    u)
      clusterUserName=$OPTARG
      ;;
    U)
      containerUserName=$OPTARG
      ;;
    V)
      volumeMappingArg=$OPTARG
      ;;
    O)
      mntOwner=$OPTARG
      ;;
    P)
      mntPerm=$OPTARG
      ;;
    v)
      VERBOSE=true
      ;;
    W)
      PREVIEW=true
      ;;
    w)
      rerunWebProxy=true
      ;;
    h)
      usage
      ;;
    *)
      usage "Invalid argument: $OPTARG"
      ;;
  esac
done

$extractIP && $rerunWebProxy && echo "-I and -w incompatible" && exit

# Generate ticket
# sshpass -p mapr ssh -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 32832 root@scale-67 maprlogin generateticket -type service -user user1 -out $PWD/maprticket_user1
# Copy ticket to docker host
# sshpass -p mapr scp -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P 32832 root@scale-67:/tmp/maprticket_user1 ./maprticket_user1
# 1. From cluster name, get generate ticket on host cluster-s1 (probably should not use service ticket
# 2. Copy ticket to ./maprticket
# 3. Determine cldbs
# 4. Determine UID - err if not found in /etc/passwd
# 5. Determine add_host string
# 6. Determine network and next network 

scriptDir=$(dirname $BASH_SOURCE)
[[ ! $scriptDir =~ ^/ ]] && scriptDir=$(pwd)/$scriptDir
. $scriptDir/docker-functions.sh

# 1. Get ssh port of server -s1 in cluster
sshPort=$(docker inspect ${clusterName}-s1 | jq -r '.[].NetworkSettings.Ports["22/tcp"][].HostPort')
[[ -z $sshPort ]] && echo "No container name ${clusterName}-s1 with exposed ssh port." && exit 1
[[ -z $containerUserName ]] && containerUserName=root
[[ -z $clusterUserName ]] && clusterUserName=root

# 2. Determine UID - err if not found in /etc/passwd
#containerUID=$(sshpass -p mapr ssh -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $sshPort root@localhost id -u $containerUserName 2>&1)
#if [[ $containerUID =~ "no such user" ]]; then
  #echo "No such user $containerUserName in container ${clusterName}-s1"
  #exit 1
#fi 

# 3. From cluster name, get generate ticket on host cluster-s1 
#sshpass -p mapr ssh -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $sshPort root@localhost maprlogin generateticket -type service -user $containerUserName -out /root/maprticket_$containerUserName
sshpass -p mapr ssh -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $sshPort root@localhost maprlogin generateticket -type servicewithimpersonation -user $clusterUserName -out /root/maprticket_$clusterUserName

# 4. Copy ticket to ./maprticket
if $copyMaprTicket; then
  sshpass -p mapr scp -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P $sshPort root@localhost:/root/maprticket_$clusterUserName ./maprticket_${clusterName}_$clusterUserName
  #chown $clusterUserName ./maprticket_${clusterName}_$clusterUserName
  chmod 777 ./maprticket_${clusterName}_$clusterUserName
  maprTicketMapping=" -v ${PWD}/maprticket_${clusterName}_$clusterUserName:/tmp/mapr_ticket:ro"
  maprTicketMapping+=" -v ${PWD}/maprticket_${clusterName}_$clusterUserName:/opt/mapr/conf/maprfuseticket:ro"
fi

# 5. Copy ssl_truststore
if $copySslTruststore; then
  [[ -f ./ssl_truststore_${clusterName} ]] && rm -f ./ssl_truststore_${clusterName}
  sshpass -p mapr scp -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P $sshPort root@localhost:/opt/mapr/conf/ssl_truststore ./ssl_truststore_${clusterName}
  sslTruststoreMapping=" -v ${PWD}/ssl_truststore_${clusterName}:/opt/mapr/conf/ssl_truststore:ro"
fi

# 6. Determine cldbs
cldbList=$(sshpass -p mapr ssh -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $sshPort root@localhost maprcli node list -noheader -columns hostname -filter [csvc==cldb] | cut -f1 -d ' ' | tr '\n' ',')
cldbList=${cldbList%,}

# 7. Determine add_host string
addHostString=''
addHostList=$(docker inspect --format '{{ .HostConfig.ExtraHosts }}' ${clusterName}-s1  | sed -e 's/\[//' -e 's/\]//')
while [[ $addHostList =~ ":" ]]; do 
  nextHost=${addHostList%%:*}
  addHostList=${addHostList#*:}
  nextIP=${addHostList%% *}
  addHostList=${addHostList#* }
  addHostString="$addHostString --add-host '$nextHost:$nextIP'"
done
#echo $addHostString
#exit

# 8. Determine network and next network IP and hostname
last_client() {
  # $1 is basename
  # $@ is list of containers starting with $basename
  local max
  let max=0
  basename=$1
  shift
#echo " $basename : $*"
  for nextContainer in $* ; do
    #echo "nextContainer=$nextContainer"
    num=${nextContainer#${basename}}
    num=${num%%-*}
    #echo "$num"
    [[ $num -gt $max ]] && max=$num
    [[ $max -eq $num ]] && lastContainer=$nextContainer
  done
  # let max+=1 # for next_client
  echo $lastContainer
}

next_client_hostname() {
  # $1 is client container
  containerName=$1
  echo $(increment_number_in_string $(docker inspect --format "{{.Config.Hostname}}" $containerName))
}

is_number()
{
  re='^[0-9]+$'
  if ! [[ $1 =~ $re ]] ; then
    false
  else
    true
  fi
}


increment_number_in_string() {
  # Finds last number within a string and increments that number
  # (make sure there is not a number in the domain name or that will get incremented!)
  # if second parameter is given, return only the number, not the string
  incString=$1
  numonly=false
  [[ $2 = 'numonly' ]] && numonly=true
  local headStr
  local tailStr
  local numberStr

  tailStr=${incString##*[0-9]}
  headStr=${incString%${tailStr}}
  numberStr=${headStr##*[!0-9]}
  headStr=${headStr%${numberStr}}

#  numberStr=${incString##${headStr}}
#  numberStr=${numberStr%%${tailStr}}
  if ! is_number $numberStr; then
    echo "Invalid string for numeric increment: $incString"
    exit
  fi
  digits=$(echo ${#numberStr})
  let nextNum=10#${numberStr}+1
  printf -v numberStr "%0${digits}d" $nextNum
  if $numonly; then
    echo ${numberStr}
  else
    echo ${headStr}${numberStr}${tailStr}
  fi
}

clientList=$(docker ps -a --format "{{.Names}}" | grep "^${clusterName}-c[0-9]*")
if [[ -z $clientList ]]; then
  echo "No clients defined for cluster $clusterName.  Is cluster running?"
  exit
else
  #echo $clientList
  lastClient=$(last_client ${clusterName}-c $clientList)
  #echo last=$lastClient
  nextClient="${clusterName}-c$(increment_number_in_string ${lastClient#${clusterName}-c} numonly)"
  #echo next=$nextClient
fi

nw=$(docker_network $lastClient)
dockerNetwork=$nw
if $extractIP ; then

  #  Get all possible hosts from first server container
  hostarray=(); while read -r line ; do hostarray+=("$line"); done < <(docker inspect ${clusterName}-s1 | jq '.[].HostConfig.ExtraHosts|.[]' | sed -e 's/"//g')

  # for each running container, remove that entry from possible hosts to use for new container
  for container in $(docker network inspect $dockerNetwork | jq -r '.[].Containers[].Name'); do
    HN="$(docker inspect $container | jq -r '.[].Config.Hostname')"
    DN="$(docker inspect $container | jq -r '.[].Config.Domainname')"
    FQDN="${HN}${DN}"
    nextHostIdx=${#hostarray[@]}
    while let nextHostIdx--; do 
      nextHostFQDN="${hostarray[$nextHostIdx]%% *}"
      if [[ "$FQDN" = "$nextHostFQDN" ]] ; then
        hostarray[$nextHostIdx]=""	# This host is a running container, remove it from possible hostnames to use
      fi
    done
  done
  # Grab the last available host entry that has the same basename as ${clusterName}-s1 container (do not use kdc hostname)
  nextHostIdx=${#hostarray[@]}
  while let nextHostIdx--; do
    [[ -z ${hostarray[$nextHostIdx]} ]] && continue
    availableHost=${hostarray[$nextHostIdx]%%.*}
    availableHostBasename=$(echo $availableHost | sed -e 's/[0-9]*$//')
    clusterHostBasename=$(docker inspect ${clusterName}-s1 | jq -r '.[].Config.Hostname' | cut -f1 -d. | sed -e 's/[0-9]*$//')
    if [[ $availableHostBasename = $clusterHostBasename ]] ; then
      fqdn=${hostarray[$nextHostIdx]%% *}
      ip=${hostarray[$nextHostIdx]##*:}
    fi
  done
  if [[ -z $ip ]] ; then
    echo "Unable to find available IP/Hostname.  Try removing an existing client container or re-run without -I option."
    exit
  fi
else
  fqdn=$(next_client_hostname $lastClient)
  ip=$(docker_next_ip $nw)
fi

#echo -h $fqdn --name=$nextClient --network $nw --ip $ip
#echo "$addHostString"

declare -a dockerProxyAddHostArgsArr
setup_existing_addhost_args()
{
  # TBD: sort by IP address
  dockerNetwork=$nw
  for container in $(docker network inspect $dockerNetwork | jq -r '.[].Containers[].Name'); do 
    HN="$(docker inspect $container | jq -r '.[].Config.Hostname')"
    DN="$(docker inspect $container | jq -r '.[].Config.Domainname')"
    FQDN="${HN}${DN}"
    SHHN=${FQDN%%.*}
    IP=$(docker inspect $container | jq -r ".[].NetworkSettings.Networks.$dockerNetwork.IPAddress")
    dockerProxyAddHostArgsArr+=( --add-host "$FQDN $SHHN":$IP )
   #dockerProxyAddHostArgsArr+=( "--add-host \"$FQDN $SHHN\":$IP" )
  done
}

#setup_existing_addhost_args 
#dockerProxyAddHostArgsArr+=( --add-host "$fqdn ${fqdn%%.*}":$ip )
#echo "${dockerProxyAddHostArgsArr[@]}"

rerun_webproxy() {
  #setup_existing_addhost_args 
  dockerProxyAddHostArgsArr+=( --add-host "$fqdn ${fqdn%%.*}":$ip )
  containerIP=$(docker inspect --format "{{ .NetworkSettings.Networks.$nw.IPAddress }}" mapr-webproxy)
  #echo containerIP=$containerIP
  #exit
  docker rm -vf mapr-webproxy
#containerIP="172.24.0.103"
#containerIP="172.25.0.103"
  docker run -d "${dockerProxyAddHostArgsArr[@]}" -h mapr-webproxy.mapr.local --name=mapr-webproxy -p 3128:3128 --network $nw --ip $containerIP --restart always    squid:3.1.23
}
setup_existing_addhost_args 
$rerunWebProxy && rerun_webproxy 

volumeMappingSrc=$(echo $volumeMappingArg | cut -f1 -d':')
volumeMappingDst=$(echo $volumeMappingArg | cut -f2 -d':')
if [[ -b $volumeMappingSrc ]]; then
  # mkfs file system, mount it and add it to fstab
  # TBD:  This needs to be cleaned up manually if the devices is reused
  mkfs -t xfs -f $volumeMappingSrc # /dev/xvdo
  dataMountPoint=$(mktemp -d -p /var/tmp $clusterName.${dockerImage%%:*}.XXXXX )
  sleep 5
  UUID=$(ls -l /dev/disk/by-uuid/ | grep /${volumeMappingSrc##*/}$ | tr -s ' ' | cut -f 9 -d ' ')
  echo "UUID=$UUID $dataMountPoint              xfs     defaults        0 0" >> /etc/fstab
  mount $dataMountPoint
  chmod -R $mntPerm $dataMountPoint
  chown -R $mntOwner $dataMountPoint
  volumeMapping="-v ${dataMountPoint}:${volumeMappingDst}"
elif [[ ! -z $volumeMappingArg ]]; then
  volumeMapping="-v $volumeMappingArg"
fi

$PREVIEW && VERBOSE=true

$VERBOSE && echo "docker run -d \
  -it \
  -e MAPR_CLDB_HOSTS=$cldbList \
  -e MAPR_CLUSTER=$clusterName \
  -e MAPR_CONTAINER_USER=$containerUserName \
  $dockerEnvStr \
  $posixClientOptString \
  -e MAPR_TICKETFILE_LOCATION=/tmp/mapr_ticket \
  $sslTruststoreMapping \
  $maprTicketMapping \
  $volumeMapping \
  ${dockerProxyAddHostArgsArr[@]} \
  -h $fqdn --name=$nextClient --network $nw --ip $ip --restart always $dockerImage \
  $containerRunString"

$PREVIEW && exit

#  -e MAPR_CONTAINER_UID=$containerUID \

# Use eval to ensure quotes in addHostString are properly picked up
set -x
#eval $(echo "\

docker run -d \
  -it \
  -e MAPR_CLDB_HOSTS=$cldbList \
  -e MAPR_CLUSTER=$clusterName \
  -e MAPR_CONTAINER_USER=$containerUserName \
  $addlDockerArgs \
  $dockerEnvStr \
  $posixClientOptString \
  -e MAPR_TICKETFILE_LOCATION=/tmp/mapr_ticket \
  $sslTruststoreMapping \
  $maprTicketMapping \
  $volumeMapping \
  "${dockerProxyAddHostArgsArr[@]}" \
  -h $fqdn --name=$nextClient --network $nw --ip $ip --restart always $dockerImage \
  $containerRunString \

#  ")
set +x

#  -e MAPR_CONTAINER_UID=$containerUID \

#  -h $fqdn --name=$nextClient --network $nw --ip $ip --restart always maprtech/pacc:5.2.1_3.0_centos7
exit

# Example docker run command
docker run -d \
  -it \
  -e MAPR_CLDB_HOSTS=spark01.mapr.local,spark02.mapr.local \
  -e MAPR_CLUSTER=sparky \
  -e MAPR_CONTAINER_USER=user1 \
  -e MAPR_CONTAINER_UID=5001 \
  -e MAPR_MOUNT_PATH=/mapr \
  --cap-add SYS_ADMIN \
  --cap-add SYS_RESOURCE \
  --device /dev/fuse \
  -e MAPR_TICKETFILE_LOCATION=/tmp/mapr_ticket \
  -v $PWD/maprticket_user1:/tmp/mapr_ticket:ro \
  --add-host 'sparky-mapr-mysql.mapr.local sparky-mapr-mysql:172.200.0.118' \
  --add-host 'sparky-mapr-kdc.mapr.local sparky-mapr-kdc:172.200.0.119' \
  --add-host 'mapr-webproxy.mapr.local mapr-webproxy:172.200.0.120' \
  --add-host 'mapr-core-repo.mapr.local mapr-core-repo:172.200.0.107' \
  --add-host 'mapr-mep-repo.mapr.local mapr-mep-repo:172.200.0.108' \
  --add-host 'spark01.mapr.local spark01:172.200.0.121' \
  --add-host 'spark02.mapr.local spark02:172.200.0.122' \
  --add-host 'spark03.mapr.local spark03:172.200.0.123' \
  --add-host 'spark04.mapr.local spark04:172.200.0.124' \
  --add-host 'spark05.mapr.local spark05:172.200.0.125' \
  --add-host 'spark06.mapr.local spark06:172.200.0.126' \
  --add-host 'spark07.mapr.local spark07:172.200.0.127' \
  --add-host 'spark08.mapr.local spark08:172.200.0.128' \
  --add-host 'spark09.mapr.local spark09:172.200.0.129' \
  -h spark101.mapr.local --name=sparky-pacc1 --network mapr_nw --ip 172.200.0.201 --restart always maprtech/pacc:5.2.1_3.0_centos7

