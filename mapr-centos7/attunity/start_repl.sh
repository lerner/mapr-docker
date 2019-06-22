#Configure MapR client on Replicate Server

IMAGE=replicate_mapr
TAG=${1:-6.1.0-316_6.0.0_4.1.0}
LAUNCHDIR=/home/mapr/docker/mapr-centos7/launch-cluster
LICENSE_JSON=../attunity/license.json

CLUSTER=a2sec
#REPLDEV=/dev/sdk
REPLDEV=/dev/xvdj
#DEV=$REPLDEV; ./launch-container.sh -c $CLUSTER -i replicate:6.1 -t -v -w -p -O 5001:5001 -P 775 -V "$DEV:/data"
DEV=$REPLDEV; $LAUNCHDIR/launch-container.sh -c $CLUSTER -i $IMAGE:$TAG -m -t -v -w -a '--privileged -m 2g -P -e container=docker' -O 5001:5001 -P 775 -V "$DEV:/data"
REPLICATE_CNTR=$($LAUNCHDIR/container_info.sh "${CLUSTER}-" ${IMAGE}: | grep -v Hostname | tr -s ' ' | cut -f 3 -d ' ')
docker exec -u attunity $REPLICATE_CNTR repctl -d /data SETSERVERPASSWORD admin # Set replicate admin password to admin
## ./make_license_json.pl < license_exp2019-03-16_ser60009784.txt  | tr -d '^M' # Ctl-V Ctl-M
chown 5001:5001 ../attunity/license.json
docker cp ../attunity/license.json ${REPLICATE_CNTR}:/var/tmp
docker exec -u attunity $REPLICATE_CNTR repctl -d /data importlicense license_file=/var/tmp/license.json
docker exec -u attunity $REPLICATE_CNTR rm -f /var/tmp/license.json
docker exec -u attunity $REPLICATE_CNTR areplicate stop
docker exec -u attunity $REPLICATE_CNTR areplicate start

LAUNCHER_CNTR=$($LAUNCHDIR/container_info.sh "${CLUSTER}-" mapr_launcher_centos7: | grep -v Hostname | tr -s ' ' | cut -f 3 -d ' ')
REPLICATE_CNTR=$($LAUNCHDIR/container_info.sh "${CLUSTER}-" ${IMAGE}: | grep -v Hostname | tr -s ' ' | cut -f 3 -d ' ')
CONFIGURE_CMD=$(docker exec $LAUNCHER_CNTR grep server/configure.sh /opt/mapr/logs/configure.log | tail -1 | awk -F ':' '{print $NF}')

docker exec -u root $REPLICATE_CNTR $CONFIGURE_CMD
# Fix for locale warning on login
docker cp ${LAUNCHER_CNTR}:/usr/lib/locale/locale-archive /tmp/locale-archive
docker cp /tmp/locale-archive ${REPLICATE_CNTR}:/usr/lib/locale/locale-archive

