#!/bin/bash

D_MAPRSEC=false; MAPRSEC=$D_MAPRSEC
D_KERB=false; KERB=$D_KERB
SECURE=false
VERBOSE=false
DEBUG=false
D_CLUSTERNAME=my.cluster.com; CLUSTERNAME=$D_CLUSTERNAME

D_KERB_REALM=MAPR.LOCAL; KERB_REALM=$D_KERB_REALM
D_DOMAIN=mapr.local; DOMAIN=$D_DOMAIN
SSHOPTS="-o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
dockerHost='<dockerHostIP>'

usage() {
  echo ""
  [[ ! -z $1 ]] && echo "ERROR: $1"
  echo ""
  echo "$(basename $0) "
  echo "        [ -c CLUSTERNAME ]      # MapR cluster name            (default: $D_CLUSTERNAME)"
  echo "        [ -D DOMAIN ]           # Cluster network domain       (default: $D_DOMAIN)"
  echo "        [ -H DockerHost ]       # Docker host name or IP for proxy message on success"
  echo "        [ -s |                  # -s Use Mapr Security         (default: $D_MAPRSEC)"
  echo "          -k KDCHN [ -K REALM ]]# -k Use Kerberos KDC at hostname KDCHN"
  echo "                                # -K Kerberos REALM            (default: $D_KERB_REALM)"
  echo "        [ -U MapRURL ]          # AWS CloudFormation URL to pass MapR cluster startup status"
  echo "        [ -d ]                  # debug
  echo "        [ -v ]                  # Verbose
  echo "        [ -h ]                  # Print help message"
  echo ""
}

while getopts ":c:dD:hH:k:K:sU:v" OPTION
do
  case $OPTION in
    c)
      CLUSTERNAME=$OPTARG
      ;;
    d)
      DEBUG=true
      ;;
    D)
      DOMAIN=$OPTARG
      ;;
    H)
      dockerHost=$OPTARG
      ;;
    K)
      KERB_REALM=$OPTARG
      ;;
    k)
      KERB=true
      SECURE=true
      KDCHN=$OPTARG
      ;;
    s)
      MAPRSEC=true
      SECURE=true
      ;;
    U)
      AWS_CFT_MAPR_URL=$OPTARG
      ;;
    v)
      VERBOSE=true
      ;;
    h)
      usage
      exit
      ;;
    *)
      usage "Invalid argument: $OPTARG"
      exit 1
      ;;
  esac
done

if $DEBUG; then
  set -x
fi

# Get script directory (absolute or relative) to this bash script
scriptDir=$(dirname $BASH_SOURCE)
[[ ! $scriptDir =~ ^/ ]] && scriptDir=$(pwd)/$scriptDir

if [[ -f $scriptDir/start-cluster.functions ]]; then
  . $scriptDir/start-cluster.functions
else
  echo "ERROR:  No $scriptDir/start-cluster.functions"
  exit
fi

$VERBOSE && echo "Running $0 $@"
setup_clush
setup_global_vars
configure_cluster
$KERB && setup_kdc
setup_security
configure_drill
start_cluster
install_license
wait_for_mapr_cluster
setup_credentials root
setup_credentials mapr
configure_monitoring
monitoring_stream_ttl_days 3
mount_clients

if [[ -f $scriptDir/start-cluster-other.sh ]]; then
  echo ""
  echo "Running additional MapR configuration and tests"
  . $scriptDir/start-cluster-other.sh
fi

if [[ -f $scriptDir/start-cluster-custom.sh ]]; then
  echo ""
  echo "Running custom configuration and tests"
  . $scriptDir/start-cluster-custom.sh
fi

