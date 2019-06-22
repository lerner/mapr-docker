FROM centos:6.7

#COPY mapr_*.repo /etc/yum.repos.d/
RUN yum install -y squid openssh-server openssh-clients

RUN : && \
 echo 'root:mapr' | chpasswd && \
 chkconfig iptables off && \
 :

RUN : && \
 ln -f /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
 :
RUN sed -i -e "/INSERT YOUR OWN RULE/a http_access allow to_docker_net" \
           -e "/INSERT YOUR OWN RULE/a http_access allow to_mapr" \
           -e"/acl to_localhost/a acl to_docker_net dst 172.16.0.0/12" \
           -e"/acl to_localhost/a acl to_mapr dstdomain mapr.com" \
           -e"/acl SSL_ports port 443/a acl SSL_ports port 1025-65535" \
           /etc/squid/squid.conf
COPY init-script /usr/bin/init-script
ENTRYPOINT /usr/bin/init-script
EXPOSE 3128
RUN sed -i 's/^UsePAM yes/#UsePAM yes/' /etc/ssh/sshd_config
