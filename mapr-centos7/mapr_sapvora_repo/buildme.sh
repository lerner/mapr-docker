#!/bin/bash
set -x
. ../version.sh

# Unlike other images, mapr_repo images are expected to be unchanged
# for a given tag (version).  
# IF THIS IS NOT TRUE, BE SURE TO REMOVE THE EXISTING REPO IMAGE 
# BEFORE BUILDING.
# Check for the exisiting repo image and exit if it already exists
# rather than copying all the files to public_html and rebuilding!

docker inspect --type=image $(basename $(pwd)):${SAP_VORA_VER} > /dev/null 2>&1  && echo "$(basename $(pwd)):${SAP_VORA_VER} already exists.  Skipping repo build."

if [[ ! -d ./public_html ]]; then
  ./get_packages.sh $SAP_VORA_VER
fi
#time docker build -t mapr_sapvora_repo:$SAP_VORA_VER .
time docker build -t $(basename $(pwd)):$SAP_VORA_VER .

# rm -rf ./public_html  # Optionally clean up after building image to save disk space
                        # But subsequent builds will re-download tgz

# Sample:
#   docker run -d -p 8080:80 --name mapr_core_repo -h mapr_core_repo.mapr.local mapr_core_repo:5.2.0
