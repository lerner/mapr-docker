#!/bin/bash
MAPR_MEP_VER=$1
MAPR_MEP_BUILDDATE=$2

mkdir -p ./public_html/releases/pub
wget -P ./public_html/releases/pub/ http://package.mapr.com/releases/pub/maprgpg.key
wget -P ./public_html/releases/pub/ http://package.mapr.com/releases/pub/gnugpg.key

if [[ -f ../../mapr-mep-v$MAPR_MEP_VER.$MAPR_MEP_BUILDDATE.rpm.tgz ]]; then
  #cp ../../mapr-mep-v$MAPR_MEP_VER.$MAPR_MEP_BUILDDATE.rpm.tgz .
  ln -s ../../mapr-mep-v$MAPR_MEP_VER.$MAPR_MEP_BUILDDATE.rpm.tgz .
else
  wget http://package.mapr.com/releases/MEP/MEP-$MAPR_MEP_VER/redhat/mapr-mep-v$MAPR_MEP_VER.$MAPR_MEP_BUILDDATE.rpm.tgz 
fi
tar xzvf mapr-mep-v$MAPR_MEP_VER.$MAPR_MEP_BUILDDATE.rpm.tgz -C ./public_html/releases

# AML added for 4.0 Beta
  cd ./public_html/releases/MEP/MEP*/redhat
  createrepo .
  cd -

#rm -f mapr-mep-v$MAPR_MEP_VER.$MAPR_MEP_BUILDDATE.rpm.tgz
if [[ ! -f ../../mapr-mep-v$MAPR_MEP_VER.$MAPR_MEP_BUILDDATE.rpm.tgz ]]; then
  mv mapr-mep-v$MAPR_MEP_VER.$MAPR_MEP_BUILDDATE.rpm.tgz ../..
else
  rm -f mapr-mep-v$MAPR_MEP_VER.$MAPR_MEP_BUILDDATE.rpm.tgz 
fi
