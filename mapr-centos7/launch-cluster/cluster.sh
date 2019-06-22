#!/bin/bash

actionArr=( start stop unpause pause remove list connect copy )
VERBOSE=false
usage() {
  echo ""
  [[ ! -z $1 ]] && echo "ERROR: $1" && echo ""
  echo "$(basename $0) "
  echo "        [ -c CLUSTERNAME ]            # MapR cluster name"
  echo "        [ -f LOCALPATH[:REMOTEPATH] ] # Local file to copy to launcher node"
  echo "        [ -v ]                        # Verbose"
  echo "        [ -h ]                        # Print help message"
  echo "        COMMAND                       # Cluster command:"
  for nextAction in ${actionArr[@]}; do
    printf "%15s%-19s%s%s containers\n" " " $nextAction "#  " $nextAction
  done
  echo ""
  exit
}

errexit()
{
  echo $date: ERROR: $1
  exit
}

errwarn()
{
  echo $date: WARN: $1
}

while getopts ":c:f:hv" OPTION
do
  case $OPTION in
    c)
      CLUSTERNAME=$OPTARG
      ;;
    f)
      FILEARG="$OPTARG"
      ;;
    v)
      VERBOSE=true
      ;;
    h)
      usage
      ;;
    *)
      usage "Invalid argument: $OPTARG"
      ;;
  esac
done

shift $(expr $OPTIND - 1 )
echo $1

# Remaining argument is command
  validAction=false
  ACTION=$1
  for nextAction in ${actionArr[@]}; do
    if [[ $nextAction = $ACTION ]]; then
      validAction=true
      break
    fi
  done
  ! $validAction && usage "Invalid action $ACTION"

# All clusters have a server with clustername-s1 for the first container
runningClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep ':Up' | grep -v '(Paused)' | sed "s/-s1:.*$//")
stoppedClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep -v ':Up' | sed "s/-s1:.*$//")
pausedClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep '(Paused)' | sed "s/-s1:.*$//")


remove_cluster(){
  if [[ -z $CLUSTERNAME ]]; then
    runningClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep ':Up' | grep -v '(Paused)' | sed "s/-s1:.*$//")
    stoppedClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep -v ':Up' | sed "s/-s1:.*$//")
    pausedClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep '(Paused)' | sed "s/-s1:.*$//")
    CLUSTERNAME="$runningClusters $stoppedClusters $pausedClusters"
    if [[ -z $CLUSTERNAME ]]; then
      echo "No clusters to be removed."
      return
    else
      echo "No cluster specified.  Removing all clusters: $CLUSTERNAME"
    fi
  fi

  for cluster in $CLUSTERNAME; do
    echo "Removing containers:"
    containers=$(docker ps -a --filter=name=${cluster}- | grep " ${cluster}\-" | cut -f 1 -d ' ')
    docker ps -a --filter=name=${cluster}- | grep " ${cluster}\-"
      echo -n "Continue [y/N]? "
      read -n 1 response
      echo ""
      if [[ ! $response =~ [yY] ]]; then
        echo "Operation aborted.  No containers removed."
        continue
      fi
    docker rm -vf $containers
    cat ./disklist.${cluster} >> disklist.available
    rm -f ./disklist.${cluster}
  done
}

stop_cluster(){
  if [[ -z $CLUSTERNAME ]]; then
    runningClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep ':Up' | grep -v '(Paused)' | sed "s/-s1:.*$//")
    CLUSTERNAME="$runningClusters"
    if [[ -z $CLUSTERNAME ]]; then
      echo "No running clusters to be stopped."
      return
    else
      echo "No cluster specified.  Stopping all running clusters: $CLUSTERNAME"
    fi
  fi

  for cluster in $CLUSTERNAME; do
    echo "Stopping containers:"
    containers=$(docker ps --filter=name=${cluster}- | grep " ${cluster}\-" | cut -f 1 -d ' ')
    docker ps --filter=name=${cluster}- | grep " ${cluster}\-"
      echo -n "Continue [y/N]? "
      read -n 1 response
      echo ""
      if [[ ! $response =~ [yY] ]]; then
        echo "Operation aborted.  No containers stopped."
        continue
      fi
    docker stop $containers
  done
}

start_cluster(){
  if [[ -z $CLUSTERNAME ]]; then
    stoppedClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep -v ':Up' | sed "s/-s1:.*$//")
    CLUSTERNAME="$stoppedClusters"
    if [[ -z $CLUSTERNAME ]]; then
      echo "No stopped clusters to be started."
      return
    else
      echo "No cluster specified.  Starting all stopped clusters: $CLUSTERNAME"
    fi
  fi

  for cluster in $CLUSTERNAME; do
    echo "Starting containers:"
    containers=$(docker ps -a --filter=name=${cluster}- | grep " ${cluster}\-" | cut -f 1 -d ' ')
    docker ps -a --filter=name=${cluster}- | grep " ${cluster}\-"
      echo -n "Continue [y/N]? "
      read -n 1 response
      echo ""
      if [[ ! $response =~ [yY] ]]; then
        echo "Operation aborted.  No containers started."
        continue
      fi
    docker start $containers
  done
}

pause_cluster(){
  if [[ -z $CLUSTERNAME ]]; then
    runningClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep ':Up' | grep -v '(Paused)' | sed "s/-s1:.*$//")
    CLUSTERNAME="$runningClusters"
    if [[ -z $CLUSTERNAME ]]; then
      echo "No running clusters to be paused."
      return
    else
      echo "No cluster specified.  Pausing all running clusters: $CLUSTERNAME"
    fi
  fi

  for cluster in $CLUSTERNAME; do
    echo "Pausing containers:"
    containers=$(docker ps --filter=name=${cluster}- | grep " ${cluster}\-" | cut -f 1 -d ' ')
    docker ps --filter=name=${cluster}- | grep " ${cluster}\-"
      echo -n "Continue [y/N]? "
      read -n 1 response
      echo ""
      if [[ ! $response =~ [yY] ]]; then
        echo "Operation aborted.  No containers paused."
        continue
      fi
    docker pause $containers
  done
}

unpause_cluster(){
  if [[ -z $CLUSTERNAME ]]; then
    pausedClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep '(Paused)' | sed "s/-s1:.*$//")
    CLUSTERNAME="$pausedClusters"
    if [[ -z $CLUSTERNAME ]]; then
      echo "No paused clusters to be unpaused."
      return
    else
      echo "No cluster specified.  Unpausing all paused clusters: $CLUSTERNAME"
    fi
  fi

  for cluster in $CLUSTERNAME; do
    echo "Unpausing containers:"
    containers=$(docker ps -aq --filter=name=${cluster}-)
    docker ps --filter=name=${cluster}-
      echo -n "Continue [y/N]? "
      read -n 1 response
      echo ""
      if [[ ! $response =~ [yY] ]]; then
        echo "Operation aborted.  No containers unpaused."
        continue
      fi
    docker unpause $containers
  done
}

list_cluster(){
  if [[ -z $CLUSTERNAME ]]; then
    runningClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep ':Up' | grep -v '(Paused)' | sed "s/-s1:.*$//")
    pausedClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep '(Paused)' | sed "s/-s1:.*$//")
    stoppedClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep -v ':Up' | sed "s/-s1:.*$//")
    CLUSTERNAME="$runningClusters $pausedClusters $stoppedClusters"
  fi

  if $VERBOSE; then
    firstTime=true
    for cluster in $CLUSTERNAME; do
      if ! $firstTime ; then
        echo ""
        echo -n "List next cluster ($cluster) [y/N]? "
        read -n 1 response
        echo ""
        if [[ ! $response =~ [yY] ]]; then
          break
        fi
      fi
      echo ""
      echo "Cluster $cluster:"
      docker ps -a --filter=name=$cluster
      firstTime=false
    done
  else
    for status in running paused stopped; do
      clusters=${status}Clusters
      for cluster in ${!clusters}; do
        sshPort=$( docker ps -a --format "{{.Names}}:{{.Status}}:{{.Ports}}" \
                 | grep "^${cluster}\-" \
                 | grep '\-launcher:' \
		 | sed -e "s/^.*://" -e "s/-.*$//")
	[[ "$status" = "stopped" ]] && sshPort=""
        printf "%-30s%-10s%5d\n" $cluster $status $sshPort
      done
    done
  fi
}

connect_cluster() {
  runningClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep ':Up' | grep -v '(Paused)' | sed "s/-s1:.*$//")
  # if no cluster specified with -c option, connect to the first running cluster
  [[ -z $CLUSTERNAME ]] && CLUSTERNAME="${runningClusters%% *}" 
  [[ -z $CLUSTERNAME ]] && usage "No cluster specified and no running clusters"
  echo $CLUSTERNAME
  sshPort=$( docker ps -a --format "{{.Names}}:{{.Status}}:{{.Ports}}" \
           | grep "^${CLUSTERNAME}\-" \
           | grep '\-launcher:' \
           | sed -e "s/^.*://" -e "s/-.*$//")


  $VERBOSE && echo "sshpass -p mapr ssh -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $sshPort root@localhost"
  sshpass -p mapr ssh -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $sshPort root@localhost
}

copy_cluster() {
  runningClusters=$(docker ps -a --format "{{.Names}}:{{.Status}}" | grep '\-s1:' | grep ':Up' | grep -v '(Paused)' | sed "s/-s1:.*$//")
  # if no cluster specified with -c option, connect to the first running cluster
  [[ -z $CLUSTERNAME ]] && CLUSTERNAME="${runningClusters%% *}" 
  [[ -z $CLUSTERNAME ]] && usage "No cluster specified and no running clusters"
  echo $CLUSTERNAME
  sshPort=$( docker ps -a --format "{{.Names}}:{{.Status}}:{{.Ports}}" \
           | grep "^${CLUSTERNAME}\-" \
           | grep '\-launcher:' \
           | sed -e "s/^.*://" -e "s/-.*$//")


  LOCALPATH=${FILEARG%%:*}
  REMOTEPATH="" && [[ "$FILEARG" =~ ":" ]] && REMOTEPATH=${FILEARG##*:}
  [[ -z $LOCALPATH ]] && errexit "Copy command requires local file path to copy"
  $VERBOSE && echo "sshpass -p mapr scp -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P $sshPort $LOCALPATH root@localhost:$REMOTEPATH"
  sshpass -p mapr scp -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P $sshPort $LOCALPATH root@localhost:$REMOTEPATH
}

${ACTION}_cluster

