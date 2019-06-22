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
export MAPR_CORE_VER=6.1.0
export MAPR_MEP_VER=6.2.0
export MAPR_MEP_BUILDDATE=201905272218
