. ../version.sh
#export MAPR_CORE_VER=5.2.2
#export MAPR_MEP_VER=3.0.1
if [[ ! -f ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh ]]; then
  echo Create version file ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh and re-run
  exit
fi
cp -f ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh ../version.sh
. ../version.sh
echo running with ${MAPR_CORE_VER}_${MAPR_MEP_VER}

./create_disklist_file.sh disklist

./launch-cluster.sh \
  -s \
  -d disklist \
  -c compu \
  -H mapr \
  -D mapr.local \
  -m $(echo 6*1024*1024|bc) \
  -v \
  -n 9 \
  -p service_computeonly.txt \
  -i mapr_sparkhive_centos7 \
  -t ${MAPR_CORE_VER}_${MAPR_MEP_VER} \
  -l mapr_launcher_centos7:${MAPR_CORE_VER} \
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
