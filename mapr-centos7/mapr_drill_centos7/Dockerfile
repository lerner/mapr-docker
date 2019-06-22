FROM mapr_server_centos7:6.1.0
 
COPY REPOSITORY /home/mapr/REPOSITORY
COPY mapr_mep.repo /etc/yum.repos.d/

# Set up mapr repositories for install 
#  sed -i -e "s/\/releases\/v.*\/redhat/\/releases\/v6.1.0\/redhat/" /etc/yum.repos.d/mapr_core.repo && \
#  sed -i -e "s/\/MEP\/MEP-.*\/redhat/\/MEP\/MEP-6.2.0\/redhat/" /etc/yum.repos.d/mapr_mep.repo && \
RUN \
  mkdir -p /home/mapr/tmp && \
  CORE_REPO=$(grep -i core /home/mapr/REPOSITORY | tr -s ' ' | cut -f 2 -d ' ') && \
  MEP_REPO=$(grep -i mep /home/mapr/REPOSITORY | tr -s ' ' | cut -f 2 -d ' ') && \
  cp /etc/yum.repos.d/mapr_core.repo /home/mapr/tmp/mapr_core.repo && \
  cp /etc/yum.repos.d/mapr_mep.repo /home/mapr/tmp/mapr_mep.repo && \
  sed -i -e "s^http://package.mapr.com^$CORE_REPO^g" /etc/yum.repos.d/mapr_core.repo && \
  sed -i -e "s^http://package.mapr.com^$MEP_REPO^g" /etc/yum.repos.d/mapr_mep.repo && \
  rpm --import $CORE_REPO/releases/pub/maprgpg.key && \
  rpm --import $CORE_REPO/releases/pub/gnugpg.key && \
  :

RUN \
  yum install -y \
      mapr-drill \
      && :

# Reset repos to package.mapr.com
RUN \
  /bin/cp -f /home/mapr/tmp/mapr_core.repo /etc/yum.repos.d/mapr_core.repo && \
  /bin/cp -f /home/mapr/tmp/mapr_mep.repo /etc/yum.repos.d/mapr_mep.repo && \
  :

EXPOSE 22
CMD ["/usr/sbin/init"]
