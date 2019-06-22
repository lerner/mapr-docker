. ../version.sh
#export MAPR_CORE_VER=6.0.0
#export MAPR_MEP_VER=4.0.0
if [[ ! -f ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh ]]; then
  echo Create version file ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh and re-run
  exit
fi
cp -f ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh ../version.sh
. ../version.sh
echo running with ${MAPR_CORE_VER}_${MAPR_MEP_VER}

./create_disklist_file.sh disklist

./launch-cluster.sh \
  -d disklist \
  -c docker.cluster.com \
  -H mapr \
  -D mapr.local \
  -m $(echo 8*1024*1024|bc) \
  -M $(echo 2*1024*1024|bc) \
  -v \
  -n 6 \
  -p service_list6.txt \
  -i mapr_sparkhive_centos7 \
  -t ${MAPR_CORE_VER}_${MAPR_MEP_VER} \
  -l mapr_launcher_centos7:${MAPR_CORE_VER} \
  -N 2 \
  -P service_client.txt \
  -C ./sparkhive \
  -C ./base	# Overwrites start-clster in launcher image
