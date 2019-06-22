FROM maprcore:5.2.0

COPY mapr_patch.repo /etc/yum.repos.d/

RUN yum install -y \
    mapr-patch \
    ;

COPY init-script /usr/bin/init-script
ENTRYPOINT /usr/bin/init-script
EXPOSE 22
