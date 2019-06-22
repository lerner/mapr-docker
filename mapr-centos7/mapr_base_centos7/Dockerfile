#FROM centos7:7.2.1511.systemd
FROM centos7:7.5.1804.systemd

# Ensure common mapr uid for all descendents, client and server.
# Provide root passwordless ssh between all descendents.
# "which" required by yarn-config.sh (see bug 26009)
RUN \
  yum install -y \
      epel-release \
      java-1.8.0-openjdk-devel \
      openssh-clients \
      openssh-server \
      openssl \
      file \
      which \
      net-tools \
      krb5-workstation \
      && \
  :
RUN \
  echo 'root:mapr' | chpasswd && \
  groupadd mapr --gid 5000 && \
  useradd mapr -m --uid 5000 -g mapr && \
  echo 'mapr:mapr' | chpasswd && \
  /usr/bin/ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa && \
  cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
  echo "StrictHostKeyChecking no" > /root/.ssh/config && \
  if systemctl is-enabled firewalld ; then systemctl disable firewalld ; fi && \
  echo 'mapr - nofile 1048576' >> /etc/security/limits.conf && \
  echo 'mapr - nproc unlimited' >> /etc/security/limits.conf && \
  echo 'session         required        pam_limits.so' >> /etc/pam.d/su && \
  :

# clustershell and jq require previous installation of epel
RUN \
  yum install -y \
      clustershell \
      jq \
      && :

# MapR HQ is in California
RUN \
  ln -f /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
  :

# Allow ssh login
RUN \
  sed -i 's/^UsePAM yes/#UsePAM yes/' /etc/ssh/sshd_config && \
  systemctl enable sshd 

EXPOSE 22
CMD ["/usr/sbin/init"]
