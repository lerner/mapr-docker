. ../version.sh
export MAPR_CORE_VER=6.0.0
export MAPR_MEP_VER=4.1.0
if [[ ! -f ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh ]]; then
  echo Create version file ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh and re-run
  exit
fi
cp -f ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh ../version.sh
. ../version.sh
echo running with ${MAPR_CORE_VER}_${MAPR_MEP_VER}

nodeCount=6
disklistFile=disklist.${nodeCount}b

if [[ ! -f $disklistFile ]] ; then
  ./create_disklist_file.sh  | head -$nodeCount > $disklistFile
fi

if [[ $(cat $disklistFile | wc -l) -lt $nodeCount ]] ; then
  echo "Not enough block devices specified for $nodeCount nodes.  Using Docker volumes for storage."
  diskParam="-L /data"
else
  diskParam="-d $disklistFile"
fi

./launch-cluster.sh \
  $diskParam \
  -c attunity \
  -H mapr \
  -D mapr.local \
  -m $(echo 10*1024*1024|bc) \
  -M $(echo 1*1024*1024|bc) \
  -v \
  -n 6 \
  -p service_list_drill.txt \
  -i mapr_sparkhivedrill_centos7 \
  -t ${MAPR_CORE_VER}_${MAPR_MEP_VER} \
  -l mapr_launcher_centos7:${MAPR_CORE_VER} \
  -N 0 \
  -P service_client.txt \
  -C ./sparkhive \
  -C ./base	# Overwrites start-clster in launcher image

#  -D mapr.local \
#  -C ./sparkhive/start-cluster.functions \	# Overwrites version in launcher image
#  -C ./sparkhive/start-cluster.sh \		# Overwrites version in launcher image
#  -d disklist.12 \
#  -d disklist.6b.hw \
#  -p service_list.txt \
#  -p node3HA.txt \


#  -N 2 \
#  -P service_client.txt \
#
