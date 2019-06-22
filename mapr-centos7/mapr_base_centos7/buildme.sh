#!/bin/bash

. ../version.sh

sed -e"s/CENTOS_VER/$CENTOS_VER/" \
    Dockerfile.template > Dockerfile

# Use this image as a base for creating either MapR client or server images.
# There is generally nothing MapR version specific in this image so technically
# it could be tagged with just the centos image tag, but future versions might
# need something MapR version specific from centos.  If identical, new MapR versions
# will result in an image that is identical but just tagged with a differing 
# MAPR_CORE_VER tag.

time docker build -t $(basename $(pwd)):${MAPR_CORE_VER} .
#time docker build -t mapr_base_centos7:$MAPR_CORE_VER .

# Start with --privileged so systemd can start sshd
# Sample:
#   docker run -d -P --privileged --name mapr_base mapr_base_centos7:5.2.0
