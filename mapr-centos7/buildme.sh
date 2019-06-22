#!/bin/bash

PREVIEW=false
[[ $1 = -p ]] && PREVIEW=true
declare -A isbuilt

# MapR Repositories.  Version used in version.sh
REPOIMG="\
  mapr_core_repo \
  mapr_mep_repo \
"
#  mapr_patch_repo \

# Auxiliary images: Web proxy and Kerberos KDC
# MariaDB image used is official docker image so nothing to build
AUXIMG="\
  squid \
  krb5 \
"

MAPRIMG="\
        mapr_launcher_centos7 \
        mapr_sparkhive_centos7 \
        mapr_drill_centos7 \
        mapr_sparkhivedrill_centos7 \
"

get_dependency() {
  IMAGE=$1
  dockerFile=$IMAGE/Dockerfile.template
  if [[ ! -f $dockerFile ]]; then
    dockerFile=$IMAGE/Dockerfile
  fi
  if [[ -d $IMAGE ]] && [[ -f $dockerFile ]]; then
    parentImage=$(grep '^FROM ' $dockerFile | cut -f 2 -d ' ' | cut -f 1 -d ':')
    if [[ -d $parentImage ]] ; then
      echo $parentImage     
    fi
  fi
}

build_image() {
  IMAGE=$1
  echo "=== build_image $1 ==="
  if [[ ! -d $IMAGE ]]; then echo "ERROR: No directory $IMAGE.  Cannot continue."; exit; fi
  parentImage=$(get_dependency $1)
  if [[ ! -z $parentImage ]]; then 
    (build_image $parentImage)
  fi
  cd $IMAGE
  echo "$(date): Running buildme.sh in $(pwd)"
  ! $PREVIEW  && ./buildme.sh
  cd -
}

build_images() {
  IMAGE_DIRS="$1"
  for IMAGE in $IMAGE_DIRS
  do
    build_image $IMAGE
  done
}


build_images "$REPOIMG"
build_images "$AUXIMG"
build_images "$MAPRIMG"

# Get script directory (absolute or relative) to source version.custom.sh
scriptDir=$(dirname $BASH_SOURCE)
[[ ! $scriptDir =~ ^/ ]] && scriptDir=$(pwd)/$scriptDir

# Put build_images commands for thirdparty docker directories into buildme.custom.sh
# Each directory is expected to have a buildme.sh script to build its image

[[ -f $scriptDir/buildme.custom.sh ]] && . $scriptDir/buildme.custom.sh

# Docker images and sizes
# Image ancestry indicated by indents
# Tags for MapR images include MapR Core and MEP versions

# REPOSITORY                          TAG                   SIZE
# ----------------------------------  ------------------  ---------
# docker.io/centos                    7.2.1511            194.60 MB
#   centos7                           7.2.1511.systemd    194.60 MB
# 
#     mapr_base_centos7               5.1.0               506.30 MB
# 
#       mapr_client_centos7           5.1.0_1.1.0         955.30 MB
#         mapr_launcher_centos7       5.1.0_1.1.0           1.07 GB
#       mapr_server_centos7           5.1.0_1.1.0           2.06 GB
#         mapr_sparkhive_centos7      5.1.0_1.1.0           2.48 GB
# 
#       mapr_client_centos7           5.1.0_2.0.0         955.50 MB
#         mapr_launcher_centos7       5.1.0_2.0.0           1.07 GB
#       mapr_server_centos7           5.1.0_2.0.0           2.06 GB
#         mapr_sparkhive_centos7      5.1.0_2.0.0           2.38 GB
# 
#     mapr_base_centos7               5.2.0               506.30 MB
# 
#       mapr_client_centos7           5.2.0_1.1.0         959.70 MB
#         mapr_launcher_centos7       5.2.0_1.1.0           1.07 GB
#       mapr_server_centos7           5.2.0_1.1.0           2.08 GB
#         mapr_sparkhive_centos7      5.2.0_1.1.0           2.51 GB
# 
#       mapr_client_centos7           5.2.0_2.0.0         959.90 MB
#         mapr_launcher_centos7       5.2.0_2.0.0           1.07 GB
#       mapr_server_centos7           5.2.0_2.0.0           2.08 GB
#         mapr_sparkhive_centos7      5.2.0_2.0.0           2.41 GB
# 
# docker.io/mariadb                   5.5.53              277.50 MB
# 
# docker.io/centos                    6.7                 190.60 MB
#  krb5                               1.10.3              569.60 MB
#  squid                              3.1.23              542.00 MB
# 
# docker.io/httpd                     2.4                 175.30 MB
#  mapr_mep_repo                      1.1.0                 3.63 GB
#  mapr_mep_repo                      2.0.0                 3.94 GB
#  mapr_core_repo                     5.1.0                 1.03 GB
#  mapr_core_repo                     5.2.0                 1.27 GB
