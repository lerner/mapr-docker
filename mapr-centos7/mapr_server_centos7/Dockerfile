FROM mapr_base_centos7:6.1.0

# This file contains an alternative Yum repository for the build (see buildme.sh)
COPY REPOSITORY /home/mapr/REPOSITORY
COPY mapr_core.repo /etc/yum.repos.d/
COPY mapr_mep.repo.template /etc/yum.repos.d/

# Set up mapr repositories for install (only core is really needed here but keeping consistent w/ other images)
RUN \
  mkdir -p /home/mapr/tmp && \
  CORE_REPO=$(grep -i core /home/mapr/REPOSITORY | tr -s ' ' | cut -f 2 -d ' ') && \
  cp /etc/yum.repos.d/mapr_core.repo /home/mapr/tmp/mapr_core.repo && \
  sed -i -e "s^http://package.mapr.com^$CORE_REPO^g" /etc/yum.repos.d/mapr_core.repo && \
  rpm --import $CORE_REPO/releases/pub/maprgpg.key && \
  rpm --import $CORE_REPO/releases/pub/gnugpg.key && \
  :
# nc used to validate zookeeper running with "echo srvr | nc localhost 5181 | grep Mode"
# sudo required for default PAM authentication when logging in to https webserver or CLDB jetty.
RUN \
  yum install -y \
      mapr-core \
      mapr-collectd \
      nc \
      nfs-utils \
      sudo \
      bash \
      curl \
      rpcbind \
      dmidecode \
      glibc \
      hdparm \
      initscripts \
      iputils \
      irqbalance \
      libgcc \
      libstdc++ \
      nss \
      perl \
      redhat-lsb-core \
      rpm-libs \
      sdparm \
      shadow-utils \
      syslinux \
      unzip \
      zip \
      && :

COPY mapr-warden.service /etc/systemd/system/default.target.wants/mapr-warden.service
COPY mapr-warden.service /etc/systemd/system/mapr-warden.service
#COPY mapr-zookeeper.service /etc/systemd/system/default.target.wants/mapr-zookeeper.service
#COPY mapr-zookeeper.service /etc/systemd/system/mapr-zookeeper.service

RUN \
  sed -i 's!/proc/meminfo!/opt/mapr/conf/meminfofake!' /opt/mapr/server/initscripts-common.sh && \
  :

# Reset repos to package.mapr.com
# 
RUN \
  /bin/cp -f /home/mapr/tmp/mapr_core.repo /etc/yum.repos.d/mapr_core.repo && \
  :

ENV NODETYPE MapRServer
EXPOSE 22
CMD ["/usr/sbin/init"]

COPY core-site.xml /opt/mapr/hadoop/hadoop-2.7.0/etc/hadoop/core-site.xml
