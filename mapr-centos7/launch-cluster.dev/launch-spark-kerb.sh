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

./launch-cluster.sh \
  -k \
  -c hanastore \
  -H sapmapr \
  -D wdf.sap.corp \
  -m $(echo 8*1024*1024|bc) \
  -M $(echo 2*1024*1024|bc) \
  -v \
  -n 3 \
  -p node3HA.txt \
  -i mapr_sparkhive_centos7 \
  -t ${MAPR_CORE_VER}_${MAPR_MEP_VER} \
  -l mapr_launcher_centos7:${MAPR_CORE_VER} \
  -N 2 \
  -P service_client.txt \
  -C ./sparkhive \
  -C ./base	# Overwrites start-clster in launcher image

#  -C ./sparkhive/start-cluster.functions \	# Overwrites version in launcher image
#  -C ./sparkhive/start-cluster.sh \		# Overwrites version in launcher image

#  -N 2 \
#  -P service_client.txt \
#
