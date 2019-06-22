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

NODECOUNT=1
CLUSTER=single
disklistFile=disklist.$CLUSTER

if [[ ! -f $disklistFile ]] ; then
  ./create_disklist_file.sh  | head -$NODECOUNT > $disklistFile
fi

if [[ $(cat $disklistFile | wc -l) -lt $NODECOUNT ]] ; then
  echo "Not enough block devices specified for $NODECOUNT nodes.  Using Docker volumes for storage."
  diskParam="-L /data"
else
  diskParam="-d $disklistFile"
fi

SERVICESFILE=single-node.txt
cat <<- EOF > $SERVICESFILE
	0 fileserver 
	1 single-node collectd fileserver cldb nodemanager resourcemanager historyserver spark-historyserver webserver opentsdb zookeeper hivemetastore hiveserver2 kafka hbase drill
EOF
#	1 single-node 



./launch-cluster.sh \
  -c $CLUSTER \
  $diskParam \
  -s \
  -H mapr \
  -D mapr.local \
  -m $(echo 20*1024*1024|bc) \
  -v \
  -n $NODECOUNT \
  -p $SERVICESFILE \
  -i mapr_sparkhive_centos7 \
  -t ${MAPR_CORE_VER}_${MAPR_MEP_VER} \
  -l mapr_launcher_centos7:${MAPR_CORE_VER} \
  -C ./sparkhive \
  -C ./base  


