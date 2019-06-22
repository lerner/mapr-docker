#!/bin/bash
#. ../version.sh
export MAPR_CORE_VER=6.1.0
export MAPR_MEP_VER=6.1.0
#export MAPR_CORE_VER=6.0.1
#export MAPR_MEP_VER=5.0.2
if [[ -z $MAPR_MEP_VER ]] ; then
  VERSION_FILE=$(ls ../versions/version_${MAPR_CORE_VER}*.sh | tail -1)
else
  VERSION_FILE=../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh
fi
if [[ ! -f $VERSION_FILE ]]; then
  echo Create version file $VERSION_FILE and re-run
  exit
fi
cp -f $VERSION_FILE ../version.sh
. ../version.sh
echo running with ${MAPR_CORE_VER} ${MAPR_MEP_VER}

Z=eu
NODECOUNT=6
CLUSTER=c360.$Z.xyz.com

disklistFile=disklist.${CLUSTER//./-}

if [[ ! -f $disklistFile ]] ; then
  ./create_disklist_file.sh  | head -$NODECOUNT > $disklistFile
fi

if [[ $(cat $disklistFile | wc -l) -lt $NODECOUNT ]] ; then
  echo "Not enough block devices specified for $NODECOUNT nodes.  Using Docker volumes for storage."
  diskParam="-L /data"
else
  diskParam="-d $disklistFile"
fi

SERVICESFILE=services.$Z.xyz.txt
cat <<- EOF > $SERVICESFILE
	0 mastgateway fileserver drill nodemanager gateway
	1 fileserver drill nodemanager cldb webserver
	2 fileserver drill nodemanager cldb webserver spark-historyserver
	3 mastgateway fileserver drill nodemanager zookeeper resourcemanager historyserver
	4 fileserver drill nodemanager zookeeper hivemetastore gateway
	5 fileserver drill nodemanager zookeeper hiveserver2 gateway
EOF
#	1 single-node 
#	4 collectd fileserver nodemanager zookeeper hivemetastore opentsdb 
#	5 collectd fileserver nodemanager zookeeper hiveserver2 opentsdb 



./launch-cluster.sh \
  -c $CLUSTER \
  $diskParam \
  -s \
  -H mapr \
  -D $Z.xyz.com \
  -m $(echo 14*1024*1024|bc) \
  -v \
  -n $NODECOUNT \
  -p $SERVICESFILE \
  -N 1 \
  -P service_client.txt \
  -i mapr_sparkhivedrill_centos7 \
  -t ${MAPR_CORE_VER}_${MAPR_MEP_VER} \
  -l mapr_launcher_centos7:${MAPR_CORE_VER} \
  -C ./sparkhive \
  -C ./base  

