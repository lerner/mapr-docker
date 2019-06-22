#!/bin/bash

# Package a cleaned up version of the environment

doNotDeleteDirsArr=( $@ )
echo doNotDelete=${doNotDeleteDirsArr[@]}

# Delete dirs array
# This is the directories under mapr-centos7 that we do not want included for building images, etc
deleteDirsArr=( \
  attunity \
  baseball_mysql \
  maprpatch \
  mapr_patch_repo \
  mapr_sapvora_centos7 \
  mapr_sapvora_repo \
  mapr_sparkhive_patched_centos7 \
  launch-cluster.dev \
  mxnet_face_id \
  postgres \
  )

myDir=$PWD

TS=$(date +%Y%m%d)
find . -name public_html -exec rm -rf {} \;

# For 3rd party software, we delete the software from build directory after building the image
# to keep from distributing the software
# But we need the software to be available (typically in a docker repo or just in the Docker build directory)
# This code block copies the software to the Docker build directory.  It will be deleted after the first build
# For multiple versions, this might be an issue.  Doing this for attunity build.
for dir in ${doNotDeleteDirsArr[@]}; do
  cd mapr-centos7/$dir
  [[ -x ./buildme.sh ]] && ./buildme.sh getSoftwareOnly
  cd -
done

# Copy required files to launch-cluster leaving debug stuff in launch-cluster.dev
rm -rf mapr-centos7/launch-cluster/*
cd mapr-centos7/launch-cluster.dev
for LAUNCHFILE in \
  base \
  cluster.sh \
  container_info.sh \
  create_disklist_file.sh \
  docker-functions.sh \
  launch-cluster.sh \
  launch-container.sh \
  launch-fs1.sh \
  login_info.sh \
  sparkhive \
  volumecntrs.py \
  launch-five.sh \
  launch-single.sh \
  launch-xyz.eu.sh \
  WELCOME \
  ; do
    cp -pr $LAUNCHFILE ../launch-cluster/
done
cd -

rm -f $myDir/docker-mapr-*${TS}.tgz
tar czvf $myDir/docker-mapr-centos7.${TS}.tgz ./mapr-centos7
#tar hczvf docker-mapr-sapvora-centos7.${TS}.tgz ./mapr-centos7/launch-cluster/sapvora
#cp -f $myDir/docker-mapr-*${TS}.tgz /selfhosting/home/alerner/docker/
rm -rf $myDir/mapr-centos7-build/*

# Now clean up stuff for neater package
[[ ! -d $myDir/mapr-centos7-build ]] && mkdir $myDir/mapr-centos7-build
cd $myDir/mapr-centos7-build
tar xzvf $myDir/docker-mapr-*${TS}.tgz
cd $myDir/mapr-centos7-build/mapr-centos7
for file in versions/*; do
  deleteDirsArr+=( $file )
done
deleteDirsStr=" ${deleteDirsArr[*]} "
for dir in ${doNotDeleteDirsArr[@]}; do
  deleteDirsStr=${deleteDirsStr/ ${dir} / }
done
#rm -rf maprpatch mapr_patch_repo mapr_sapvora_centos7 mapr_sapvora_repo mapr_sparkhive_patched_centos7 versions/*
echo rm -rf ${deleteDirsStr}
rm -rf ${deleteDirsStr}
cd $myDir/mapr-centos7-build
tar czvf $myDir/mapr-centos7-build/docker-mapr-centos7.${TS}.tgz ./mapr-centos7
ls -l $myDir/mapr-centos7-build/docker-mapr-centos7.${TS}.tgz $myDir/docker-mapr-centos7.${TS}.tgz 

# Replace full tgz with cleaned up tgz (presume no changes to be archived in cleaned up directories)
cp -f $myDir/mapr-centos7-build/docker-mapr-centos7.${TS}.tgz $myDir/docker-mapr-centos7.${TS}.tgz 
