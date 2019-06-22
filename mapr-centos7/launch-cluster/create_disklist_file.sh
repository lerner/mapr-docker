#!/bin/bash

OUTFILE=$1

has_filesystem() {
  DEVICE=$1	# from lsblk, the device file (without /dev/)
  # if lsblk has a slash in the line for that device, it has a filesystem
  if [[  -n $(lsblk | grep "^$DEVICE " | grep /) ]]  ; then return 0; fi

  # Check to see if a partition has the slash.  
  # Partitions for xvdX and sdX devices have a trailing digit ${DEVICE}[0-9]
  # Partitions for nvme devices have trailing "p" with a digit  ${DEVICE}p[0-9]
  if [[ $DEVICE =~ ^sd[a-z] ]] || [[ $DEVICE =~ ^xvd[a-z] ]] ; then
    [[  -n $(lsblk | grep "${DEVICE}[0-9]" | grep /) ]]  && return 0
    return 1
  fi
  if [[ $DEVICE =~ ^nvme[0-9]+n[0-9]+ ]] ; then
    [[ -n $(lsblk | grep "${DEVICE}p[0-9]" | grep /) ]] && return 0
    return 1
  fi
}

# Remove these drives from the list that already have a filesystem on them
#lsblk | grep / | grep -v lvm | cut -f 1 -d ' ' | sed -e 's/[^a-z]//g'

#for DEV in $(lsblk | grep '^[sx]' | cut -f 1 -d ' ') ; do 
#for DEV in $(lsblk -d | grep ' disk ' | grep '^[sx]' | cut -f 1 -d ' ') ; do 

# Get list of all /dev/sdX, /dev/xvdX, /dev/nvmeN devices
for DEV in $(lsblk -d | grep ' disk ' | grep -e '^sd[a-z]' -e '^xvd[a-z]' -e '^nvme[0-9]' | cut -f 1 -d ' ') ; do
  # don't include devices that already have a file system on them
  has_filesystem $DEV && continue
  echo /dev/$DEV
done > /tmp/disklist

# Remove devices that already have a file system on them (or one of their partitions)
#for FSDEV in $(lsblk | grep / | grep -v lvm | cut -f 1 -d ' ' | sed -e 's/[^a-z]//g'); do
#  grep -v "^/dev/${FSDEV}$" /tmp/disklist > /tmp/disklist.0
#  mv /tmp/disklist.0 /tmp/disklist
#done

# Remove any entries that are in disklist.<clustername> files
for CLUSTER in $(docker ps -a | grep '\-s1$' | sed -e 's/^.* //' | sed -e 's/-s1$//') ; do
  for DEVFILE in $(cat disklist.$CLUSTER); do
    sed -i -e "\:^$DEVFILE\$:d" /tmp/disklist 
  done
done

if [[ -z $OUTFILE ]]; then
  #mv /tmp/disklist ./disklist.$(cat /tmp/disklist | wc -l)
  cat /tmp/disklist
else
  mv /tmp/disklist $OUTFILE
fi


