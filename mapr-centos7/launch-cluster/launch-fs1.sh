#. ../version.sh
#export MAPR_CORE_VER=5.2.2
#export MAPR_MEP_VER=3.0.1
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

./launch-cluster.sh \
  -c fs1 \
  -H fs1 \
  -D mapr.local \
  -m $(echo 4*1024*1024|bc) \
  -v \
  -n 1 \
  -p service_list_fs1.txt \
  -i mapr_server_centos7 \
  -t ${MAPR_CORE_VER} \
  -l mapr_launcher_centos7:${MAPR_CORE_VER} \


#
#  -N 2 \
#  -P service_client.txt 

