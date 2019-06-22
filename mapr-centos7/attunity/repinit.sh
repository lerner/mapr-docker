#! /bin/bash
#
# Usage: repinit.sh  <attunity_home> <data_directory>
#

exec >  ~/repinit.out                                                                     
exec 2>&1

set -x



echo "***** repinit.sh $1 $2 *****"


if [ $# -eq 2 ]
then
	ATTUNITY_HOME=$1
	DATADIR=$2
elif [ $# -eq 1 ]
then
	ATTUNITY_HOME=$1
	DATADIR=$ATTUNITY_HOME/data
elif [ $# -eq 0 ]
then 
	ATTUNITY_HOME=/opt/attunity/replicate
	DATADIR=$ATTUNITY_HOME/data
else
	echo "Error: Too many arguments"
	echo "Usage: repinit.sh <attunity_home> <data_directory>"
	exit 1
fi

ATTUNITY_DATA=$ATTUNITY_HOME/data

if [ "$ATTUNITY_DATA" = "$DATADIR" ]
then
	# if the directories are the same, then we are not
	# moving the data directory, so do nothing.
	echo ""
elif [ -d $ATTUNITY_DATA ]
then
	# if the original data directory is still there,
	# move the content. However, 
	# we need to seed the /data directory *after* 
	# the /data volume is mounted which is why we are
	# doing it here rather than in the Dockerfile. If we do 
	# it before the files will be overwritten each time we restart. 
	# If the directory is not there, then we know we don't
	# need to do this again.
	mv -n $ATTUNITY_HOME/data/* $DATADIR
	rm -rf $ATTUNITY_HOME/data
	cd $ATTUNITY_HOME/bin
	echo "export AREP_DATA=$DATADIR" > site_arep_login.sh
	chmod 775 site_arep_login.sh
	#chown attunity:attunity site_arep_login.sh
fi

cd $ATTUNITY_HOME/bin
./arep.ctl start 


exit 0

