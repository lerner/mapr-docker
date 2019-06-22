FROM mapr_server_centos7:5.2.0_1.1.0
 
COPY REPOSITORY /home/mapr/REPOSITORY
COPY mapr_patch.repo /etc/yum.repos.d/

# Set up mapr repositories for install 
#  sed -i -e "s/\/releases\/v.*\/redhat/\/releases\/v5.2.0\/redhat/" /etc/yum.repos.d/mapr_core.repo && \
#  sed -i -e "s/\/MEP\/MEP-.*\/redhat/\/MEP\/MEP-1.1.0\/redhat/" /etc/yum.repos.d/mapr_ecosystem.repo && \
RUN \
  CORE_REPO=$(grep -i core /home/mapr/REPOSITORY | tr -s ' ' | cut -f 2 -d ' ') && \
  MEP_REPO=$(grep -i mep /home/mapr/REPOSITORY | tr -s ' ' | cut -f 2 -d ' ') && \
  PATCH_REPO=$(grep -i patch /home/mapr/REPOSITORY | tr -s ' ' | cut -f 2 -d ' ') && \
  cp /etc/yum.repos.d/mapr_core.repo /tmp/mapr_core.repo && \
  cp /etc/yum.repos.d/mapr_ecosystem.repo /tmp/mapr_ecosystem.repo && \
  cp /etc/yum.repos.d/mapr_patch.repo /tmp/mapr_core.repo && \
  sed -i -e "s^http://package.mapr.com^$CORE_REPO^g" /etc/yum.repos.d/mapr_core.repo && \
  sed -i -e "s^http://package.mapr.com^$MEP_REPO^g" /etc/yum.repos.d/mapr_ecosystem.repo && \
  sed -i -e "s^http://package.mapr.com^$PATCH_REPO^g" /etc/yum.repos.d/mapr_ecosystem.repo && \
  rpm --import $CORE_REPO/releases/pub/maprgpg.key && \
  rpm --import $CORE_REPO/releases/pub/gnugpg.key && \
  :

RUN \
  yum install -y \
      mapr-hive \
      mapr-spark \
      mapr-patch && \
      rm -rf /opt/mapr/.patch \
      && :

# Reset repos to package.mapr.com.  But not patch repo since there is none at package.mapr.com
RUN \
  /bin/cp -f /tmp/mapr_core.repo /etc/yum.repos.d/mapr_core.repo && \
  /bin/cp -f /tmp/mapr_ecosystem.repo /etc/yum.repos.d/mapr_ecosystem.repo && \
  :


EXPOSE 22
CMD ["/usr/sbin/init"]
