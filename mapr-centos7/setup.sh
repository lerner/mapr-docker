#!/bin/bash

# Disable SELINUX
sed -i -e 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
setenforce 0

yum -y install wget screen createrepo bc epel-release jq
yum -y install sshpass

mkdir docker
mv docker-mapr-centos7.*.tgz docker
cd docker
tar xzvf docker-mapr-centos7.*.tgz

# Download desired MapR Core and MEP versions
# build_all_versions will build docker images for every combination of Core and MEP
curl -O http://package.mapr.com/releases/v5.2.1/redhat/mapr-v5.2.1GA.rpm.tgz
curl -O http://package.mapr.com/releases/v5.2.2/redhat/mapr-v5.2.2GA.rpm.tgz
curl -O http://package.mapr.com/releases/MEP/MEP-1.1.3/redhat/mapr-mep-v1.1.3.201708071547.rpm.tgz
curl -O http://package.mapr.com/releases/MEP/MEP-2.0.2/redhat/mapr-mep-v2.0.2.201708071538.rpm.tgz
curl -O http://package.mapr.com/releases/MEP/MEP-3.0.1/redhat/mapr-mep-v3.0.1.201708071527.rpm.tgz

cd mapr-centos7
rm -rf versions/*

yum -y install xauth

#SYSCTLFILE=/usr/lib/sysctl.d/60-aml-mapr-docker.conf
SYSCTLFILE=/etc/sysctl.conf
echo '# With more than mapr docker nodes, mfs.log-3 starts showing' >> $SYSCTLFILE
echo '# ERROR IOMgr iodispatch.cc:117 io-setup failed, -11' >> $SYSCTLFILE
echo '# Increment 8x from 256K to 2M' >> $SYSCTLFILE
echo 'fs.aio-max-nr = 2097152' >> $SYSCTLFILE
sudo sysctl -p $SYSCTLFILE

# AMI should have /dev/xvdz or /dev/sdz available for /var/lib/docker
# If docker volumes are used rather than block devices for docker instances, the 
# docker volumes will be in /var/lib/docker/...

BLOCKDEV=$(ls /dev/*dz)
if [[ -b $BLOCKDEV ]]; then
  mkfs -t xfs $BLOCKDEV
  mkdir /var/lib/docker
  bash -c "echo '$BLOCKDEV /var/lib/docker xfs defaults 0 0' >> /etc/fstab"
  mount -a
  chmod 755 /var/lib/docker 
fi

yum -y install docker
sed -i -e "s/^OPTIONS='--selinux-enabled /OPTIONS='/" /etc/sysconfig/docker
systemctl start docker
docker ps
systemctl enable docker
./build_all_versions.sh 2>&1 | tee build_all_versions.out

