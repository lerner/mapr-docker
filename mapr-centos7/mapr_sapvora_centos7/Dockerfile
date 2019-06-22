FROM mapr_sparkhive_centos7:6.0.0_4.0.0
 
COPY REPOSITORY /home/mapr/REPOSITORY
COPY mapr_sapvora.repo /etc/yum.repos.d/

# Set up mapr repositories for install 
RUN \
  SAPVORA_REPO=$(grep -i sapvora /home/mapr/REPOSITORY | tr -s ' ' | cut -f 2 -d ' ') && \
  cp /etc/yum.repos.d/mapr_sapvora.repo /home/mapr/tmp/mapr_sapvora.repo && \
  sed -i -e "s^http://REPOSERVER^$SAPVORA_REPO^g" /etc/yum.repos.d/mapr_sapvora.repo && \
  :

#RUN \
#  CORE_REPO=$(grep -i core /tmp/REPOSITORY | tr -s ' ' | cut -f 2 -d ' ') && \
#  MEP_REPO=$(grep -i mep /tmp/REPOSITORY | tr -s ' ' | cut -f 2 -d ' ') && \
#  cp /etc/yum.repos.d/mapr_core.repo /tmp/mapr_core.repo && \
#  cp /etc/yum.repos.d/mapr_ecosystem.repo /tmp/mapr_ecosystem.repo && \
#  sed -i -e "s^http://package.mapr.com^$CORE_REPO^g" /etc/yum.repos.d/mapr_core.repo && \
#  sed -i -e "s^http://package.mapr.com^$MEP_REPO^g" /etc/yum.repos.d/mapr_ecosystem.repo && \
#  rpm --import $CORE_REPO/releases/pub/maprgpg.key && \
#  rpm --import $CORE_REPO/releases/pub/gnugpg.key && \
#  :

#  Should useradd and groupadd vora before install for post-install script on vora-base
RUN \
  yum install -y \
      libaio \
      libtool \
      libtool-ltdl \
      numactl \
      lsof \
      net-tools \
      vora-base \
      && :

RUN : && \
 echo 'vora - nofile 1000000' >> /etc/security/limits.conf && \
 echo 'vora - nproc unlimited' >> /etc/security/limits.conf && \
 echo 'mapr  ALL=(root) NOPASSWD: /opt/mapr/vora/' >> /etc/sudoers && \
 :

# Reset repos to package.mapr.com
RUN \
  cp /home/mapr/tmp/mapr_sapvora.repo /etc/yum.repos.d/mapr_sapvora.repo && \
  sed -i -e "s^http://REPOSERVER^http://mapr-sapvora-repo^g" /etc/yum.repos.d/mapr_sapvora.repo && \
  :

#RUN \
#  /bin/cp -f /tmp/mapr_core.repo /etc/yum.repos.d/mapr_core.repo && \
#  /bin/cp -f /tmp/mapr_ecosystem.repo /etc/yum.repos.d/mapr_ecosystem.repo && \
#  :

EXPOSE 22
CMD ["/usr/sbin/init"]
