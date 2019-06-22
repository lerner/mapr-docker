#!/bin/bash

. ../version.sh

sed -e"s/MAPR_CORE_VER/$MAPR_CORE_VER/" \
    -e"s/MAPR_MEP_VER/$MAPR_MEP_VER/" \
    -e"s/MAPR_HADOOP_VER/$MAPR_HADOOP_VER/" \
    -e"s/MAPR_MARIADBCLI_VER/$MAPR_MARIADBCLI_VER/g" \
    Dockerfile.template > Dockerfile

#time docker build -t $(basename $(pwd)):${MAPR_CORE_VER}_${MAPR_MEP_VER} .
time docker build -t $(basename $(pwd)):${MAPR_CORE_VER} .

# To run a container, use --privileged to allow systemd to start sshd
# Sample:
#   docker run -d -P --privileged --name mapr_launcher -h mapr_edge01.mapr.local mapr_launcher_centos7:5.2.0
