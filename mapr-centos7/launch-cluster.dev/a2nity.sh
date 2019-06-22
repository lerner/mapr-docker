. ../version.sh
export MAPR_CORE_VER=6.1.0
export MAPR_MEP_VER=6.0.0
#export DEBUG=true
if [[ ! -f ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh ]]; then
  echo Create version file ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh and re-run
  exit
fi
cp -f ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh ../version.sh
. ../version.sh
echo running with ${MAPR_CORE_VER}_${MAPR_MEP_VER}

[[ ! -f disklist.available ]] && ./create_disklist_file.sh disklist.available
if [[ ! -z $1 ]]; then
  NODES=$1
  head -$NODES disklist.available > disklist
  let nextLine=$NODES+1
  tail -n +$nextLine disklist.available > x
  mv x disklist.available
else
  mv disklist.available disklist
  touch disklist.available
  NODES=$(cat disklist | wc -l )
fi

clusterName=a2sec; SEC=" -s"
#clusterName=attn; SEC=""
mv disklist disklist.$clusterName

./launch-cluster.sh \
  -d disklist.$clusterName \
  $SEC \
  -c $clusterName \
  -H $clusterName \
  -D mapr.local \
  -m $(echo 9*1024*1024|bc) \
  -M $(echo 2*1024*1024|bc) \
  -v \
  -n $NODES \
  -p node3HA6.txt  \
  -i mapr_sparkhive_centos7 \
  -t ${MAPR_CORE_VER}_${MAPR_MEP_VER} \
  -l mapr_launcher_centos7:${MAPR_CORE_VER} \
  -N 0 \
  -P service_client.txt \
  -C ./sparkhive \
  -C ./base	# Overwrites start-cluster script in launcher image

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
