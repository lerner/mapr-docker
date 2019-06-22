FROM mapr_client_centos7:6.1.0

RUN : && \
 yum install -y \
   bc \
   curl \
   jq \
   nc \
   sshpass \
   mariadb \
   && :

COPY start-cluster* /home/mapr/

CMD ["/usr/sbin/init"]
EXPOSE 22
