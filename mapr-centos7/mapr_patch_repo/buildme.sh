#!/bin/bash
. ../version.sh
if [[ ! -d ./public_html ]]; then
  ./get_packages.sh $MAPR_CORE_VER
elif [[ ! -d ./public_html/patches/releases/v$MAPR_CORE_VER ]]; then
  rm -rf ./public_html
  ./get_packages.sh $MAPR_CORE_VER
fi
#time docker build -t mapr_patch_repo:$MAPR_CORE_VER .
time docker build -t $(basename $(pwd)):${MAPR_CORE_VER} .

#rm -rf ./public_html  # Optionally clean up after building image to save disk space
                        # But subsequent builds will re-download tgz

# Sample:
#   docker run -d -p 8088:80 --name mapr-patch-repo -h mapr-patch-repo.mapr.local mapr_patch_repo:5.2.0
#
# WARNING:  Installing patch may overwrite initscripts-common.sh.  Be sure to fix for docker images before starting warden:
#      clush -Bg fileserver "sed -i 's!/proc/meminfo!/opt/mapr/conf/meminfofake!' /opt/mapr/server/initscripts-common.sh"
