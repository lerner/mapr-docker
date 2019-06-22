#!/bin/bash
# Creates version files based on MapR software tgz files in parent directory
# Builds images based on versions

. ./create_version_files.sh

build_versions_old() {
  for CORE in ${coreVersArr[@]}; do
    if [[ -z $mepVersArr ]]; then
      /usr/bin/cp -f versions/version_${CORE}.sh version.sh
      ls -l versions/version_${CORE}.sh
      ./buildme.sh # -p
      continue
    fi
    for MEP in ${mepVersArr[@]}; do
      /usr/bin/cp -f versions/version_${CORE}_${MEP}.sh version.sh
      ls -l versions/version_${CORE}_${MEP}.sh
      ./buildme.sh # -p
    done
  done
}

build_versions() {
  for VERSION_FILE in versions/version_* ; do
      /usr/bin/cp -f $VERSION_FILE version.sh
      ./buildme.sh
  done
}

#create_version_files
build_versions
