. ../version.sh
#export MAPR_CORE_VER=5.2.1
#export MAPR_MEP_VER=1.1.2
DEBUG=true

if [[ ! -f ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh ]]; then
  echo Create version file ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh and re-run
  exit
fi
cp -f ../versions/version_${MAPR_CORE_VER}_${MAPR_MEP_VER}.sh ../version.sh
. ../version.sh
echo running with ${MAPR_CORE_VER}_${MAPR_MEP_VER} and Vora version $SAP_VORA_VER

./create_disklist_file.sh disklist

./launch-cluster.sh \
  -d disklist \
  -A mapr_sapvora_repo:$SAP_VORA_VER \
  -c vora \
  -H vora \
  -D pal.sap.corp \
  -m $(echo 8*1024*1024|bc) \
  -v \
  -n 6 \
  -p service_list_vora.txt \
  -i mapr_sapvora_centos7 \
  -t ${MAPR_CORE_VER}_${MAPR_MEP_VER}_${SAP_VORA_VER} \
  -l mapr_launcher_centos7:${MAPR_CORE_VER} \
  -C ./sparkhive \
  -C ./sapvora \

#2> launch-vora.err | tee launch-vora.out 

#  -t 5.2.0_1.1.0_1.3.42 \
#  -t 5.2.1_1.1.2_1.3.66 \
#
#  -N 2 \
#  -P service_client.txt \
#
