#!/bin/bash
# Warning:  This will create repo using the latest patch release for MAPR_CORE_VER
#           if not previously packaged by this script in a local tgz file

MAPR_CORE_VER=$1

#mkdir -p ./public_html/releases/pub
#wget -P ./public_html/releases/pub/ http://package.mapr.com/releases/pub/maprgpg.key
#wget -P ./public_html/releases/pub/ http://package.mapr.com/releases/pub/gnugpg.key
mkdir -p ./public_html/patches/releases

if [[ -f ../../mapr-patch-${MAPR_CORE_VER}.rpm.tgz ]]; then
  tar xzvf ../../mapr-patch-${MAPR_CORE_VER}.rpm.tgz -C ./public_html/patches/releases
else
  wget -r -l1 -A.rpm http://package.mapr.com/patches/releases/v5.2.0/redhat/
  cd package.mapr.com/patches/releases/v5.2.0/redhat
  createrepo .
  cd -
  cd package.mapr.com/patches/releases
  tar czvf ../../mapr-patch-${MAPR_CORE_VER}.rpm.tgz .
  cd -
  mv ./package.mapr.com/*.tgz ../..
  mv ./package.mapr.com/patches/releases/* ./public_html/patches/releases/
  rm -rf ./package.mapr.com
fi
