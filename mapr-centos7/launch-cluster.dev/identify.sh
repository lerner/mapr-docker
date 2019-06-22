XAUTHORITY=/root/.Xauthority
DEMODIR=/root/face-recognition
FILENAME=${1:-frances.jpg}

#  -e MAPR_MEMORY=0  \
#  -e MAPR_TZ=America/Los_Angeles  \
#  -e MAPR_CONTAINER_PASSWORD=mapr  \
#  -e DISPLAY=$DISPLAY \
#  -v /tmp/.X11-unix:/tmp/.X11-unix \
#  -v $XAUTHORITY:/home/mapr/.Xauthority \

docker run -it \
  --privileged \
  --cap-add SYS_ADMIN  \
  --cap-add SYS_RESOURCE  \
  --device /dev/fuse  \
  -e MAPR_CLUSTER=mapr.lis.ciscodemo.int \
  -e MAPR_MOUNT_PATH=/mapr  \
  -e MAPR_CONTAINER_USER=mapr  \
  -e MAPR_CONTAINER_UID=3000 \
  -e MAPR_CONTAINER_GROUP=mapr  \
  -e MAPR_CONTAINER_GID=3000 \
  -e MAPR_CLDB_HOSTS=10.90.83.100,10.90.83.101 \
  -e GROUPID=$(uuidgen) \
  -e GPUID=-1 \
  -e READSTREAM=/tmp/processedvideostream \
  -e WRITESTREAM=/tmp/identifiedstream \
  -e THRESHOLD=0.3 \
  -e WRITETOSTREAM=1 \
  -e WRITETOPIC=frances \
  -e READTOPIC=topic1 \
  -e TIMEOUT=0.1 \
  -e PORT=5014 \
  -e FILENAME=$FILENAME \
  -e MAPR_TICKETFILE_LOCATION=/tmp/maprticket  \
  -v /tmp/maprticket_3000:/tmp/maprticket:ro  \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro  \
  --security-opt apparmor:unconfined  \
  -p 5014:5014  \
  -v $DEMODIR/mapr-streams-mxnet-face:/tmp/mapr-streams-mxnet-face:ro  \
  mengdong/mapr-pacc-mxnet:new_person_identifier
