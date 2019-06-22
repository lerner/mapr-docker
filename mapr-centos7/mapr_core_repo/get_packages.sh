#!/bin/bash
MAPR_CORE_VER=$1

mkdir -p ./public_html/releases/pub
wget -P ./public_html/releases/pub/ http://package.mapr.com/releases/pub/maprgpg.key
wget -P ./public_html/releases/pub/ http://package.mapr.com/releases/pub/gnugpg.key

if [[ -f ../../mapr-v${MAPR_CORE_VER}GA.rpm.tgz ]]; then
  #cp ../../mapr-v${MAPR_CORE_VER}GA.rpm.tgz .
  ln -s ../../mapr-v${MAPR_CORE_VER}GA.rpm.tgz .
else
  wget http://package.mapr.com/releases/v$MAPR_CORE_VER/redhat/mapr-v${MAPR_CORE_VER}GA.rpm.tgz
fi

if [[ "$MAPR_CORE_VER" = "5.1.0" ]]; then
  mkdir -p ./public_html/releases/v5.1.0/redhat
  tar xzvf mapr-v${MAPR_CORE_VER}GA.rpm.tgz -C ./public_html/releases/v5.1.0/redhat
  cd ./public_html/releases/v5.1.0/redhat
  createrepo .
  cd -
elif [[ "$MAPR_CORE_VER" = "5.2.1" ]]; then
  tar xzvf mapr-v${MAPR_CORE_VER}GA.rpm.tgz -C ./public_html/releases
  mv ./public_html/releases/5.2.1 ./public_html/releases/v5.2.1
  cd ./public_html/releases/v5.2.1/redhat
  createrepo .
  cd -
else
  tar xzvf mapr-v${MAPR_CORE_VER}GA.rpm.tgz -C ./public_html/releases
  cd ./public_html/releases/v*/redhat
  createrepo .
  cd -
fi

#rm -f mapr-v${MAPR_CORE_VER}GA.rpm.tgz
if [[ ! -f ../../mapr-v${MAPR_CORE_VER}GA.rpm.tgz ]]; then
  mv mapr-v${MAPR_CORE_VER}GA.rpm.tgz ../..
else
  rm -f mapr-v${MAPR_CORE_VER}GA.rpm.tgz 
fi
