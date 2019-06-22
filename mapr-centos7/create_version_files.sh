#!/bin/bash

# Before running, be sure to update supportedVersArr() with valid MapR version and MEP version combinations (format is CoreVersion_MEPVersion)
# Version combinations not in this list will not be built (see https://mapr.com/docs/61/InteropMatrix/r_mep_support_core_version.html)

coreVersArr=()
mepVersArr=()
mepBuildDateArr=()

supportedVersArr=( \
  6.0.0 \
  6.0.0_4.0.0 \
  6.0.0_4.1.0 \
  6.0.0_4.1.1 \
  6.0.0_4.1.2 \
  6.0.0_4.1.3 \
  6.0.1 \
  6.0.1_5.0.0 \
  6.0.1_5.0.1 \
  6.0.1_5.0.2 \
  6.0.1_5.0.3 \
  6.1.0 \
  6.1.0_6.0.0 \
  6.1.0_6.0.1 \
  6.1.0_6.0.2 \
  6.1.0_6.1.0 \
  6.1.0_6.1.1 \
  6.1.0_6.2.0 \
  )

remove_unsupported_versions() {
pwd
  for VERSIONFILE in ./versions/version_* ; do
    for SUPPORTED_VERSION in ${supportedVersArr[@]} ; do
      [[ $(basename $VERSIONFILE) =~ version_${SUPPORTED_VERSION}.sh ]] && continue 2
    done
    rm -f $VERSIONFILE
  done
}

create_version_files() {
  cat <<- 'EOF' > /tmp/version.sh
	#!/bin/bash
	# Set versions here.
	# Put custom or third party software versions in this directory in version.custom.sh
	
	# Get script directory (absolute or relative) to source version.custom.sh
	versionScriptDir=$(dirname $BASH_SOURCE)
	[[ ! $versionScriptDir =~ ^/ ]] && versionScriptDir=$(pwd)/$versionScriptDir
	
	# Put thirdparty or other version info in version.custom.sh
	[[ -f $versionScriptDir/version.custom.sh ]] && . $versionScriptDir/version.custom.sh
	
	#export CENTOS_VER=7.2.1511
	#export CENTOS_VER=7.3.1611
	#export CENTOS_VER=7.4.1708
	export CENTOS_VER=7.5.1804
	export MAPR_HADOOP_VER=2.7.0
	export MAPR_MARIADBCLI_VER=1.5.5
	EOF

  #archiveDir=/home/mapr/docker
  #cd $archiveDir
  cd ..
  for file in mapr-v*GA.rpm.tgz; do
    [[ ! -f $file ]] && break
    coreVers=${file#mapr-v}
    coreVers=${coreVers%GA.rpm.tgz}
    coreVersArr+=($coreVers)
  done
  for file in mapr-mep-v*.rpm.tgz; do 
    [[ ! -f $file ]] && break
    mepVers=${file#mapr-mep-v}
    mepVers=${mepVers%.[0-9]*.rpm.tgz}
    mepVersArr+=($mepVers)

    mepBuildDate=${file%.rpm.tgz}
    mepBuildDate=${mepBuildDate##*.}
    mepBuildDateArr+=($mepBuildDate)
  done

  # Get rid of old version files
  rm -rf ./mapr-centos7/versions/*.sh

  # Create new version files
  for coreVers in ${coreVersArr[@]}; do
    if [[ -z $mepVersArr ]]; then
      versionFile=./mapr-centos7/versions/version_${coreVers}.sh
      cp /tmp/version.sh $versionFile
      echo "export MAPR_CORE_VER=$coreVers" >> $versionFile
      chmod +x $versionFile
      continue
    fi
    mepIdx=0
    while [[ $mepIdx -lt ${#mepVersArr[@]} ]]; do
      mepVers=${mepVersArr[$mepIdx]}
      mepBuildDate=${mepBuildDateArr[$mepIdx]}
      versionFile=./mapr-centos7/versions/version_${coreVers}_${mepVers}.sh
      cp /tmp/version.sh $versionFile
      echo "export MAPR_CORE_VER=$coreVers" >> $versionFile
      echo "export MAPR_MEP_VER=$mepVers" >> $versionFile
      echo "export MAPR_MEP_BUILDDATE=$mepBuildDate" >> $versionFile
      chmod +x $versionFile
      let mepIdx++
    done
  done
  cd -
}


create_version_files
remove_unsupported_versions
