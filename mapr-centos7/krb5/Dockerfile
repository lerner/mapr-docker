FROM centos:6.7

RUN echo 'root:mapr' | chpasswd 
#RUN chkconfig iptables off && \
RUN ln -f /usr/share/zoneinfo/America/Los_Angeles /etc/localtime 

RUN yum install -y \
                openssh-server \
                openssh-clients \
		krb5-workstation \
		krb5-libs \
		krb5-server 

COPY init-script /usr/bin/init-script
ENTRYPOINT /usr/bin/init-script
EXPOSE 88 464 749
RUN sed -i 's/^UsePAM yes/#UsePAM yes/' /etc/ssh/sshd_config
