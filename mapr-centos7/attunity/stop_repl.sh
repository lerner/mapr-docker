#CLUSTER=attnsec; DEV=/dev/xvdo
CLUSTER=a2sec; DEV=/dev/sdj

docker rm -vf $(docker ps | grep $CLUSTER\- | grep -e 'replicate' | cut -f 1 -d ' ')
MNTPOINTS=$(mount | grep ${CLUSTER}'\.' | grep -e replicate | cut -f3 -d ' ')
for MNT in $MNTPOINTS; do echo $MNT; umount $MNT; sed -i -e "s:$MNT:XXXYYYZZZ:" /etc/fstab; sed -i -e "/XXXYYYZZZ/d" /etc/fstab; done

