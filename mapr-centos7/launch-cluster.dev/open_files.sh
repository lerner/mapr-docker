#!/bin/bash
LIMIT=0
[[ ! -z $1 ]] && LIMIT=$1
let TOTAL=0
cd /proc
for PID in [0-9]*; do
  [[ -z $PID ]] && continue
  softNoFile=$(grep '^Max open files' $PID/limits 2>/dev/null| tr -s ' ' | cut -f 4 -d ' ')
  hardNoFile=$(grep '^Max open files' $PID/limits 2>/dev/null| tr -s ' ' | cut -f 5 -d ' ')
  [[ $softNoFile -eq 0 ]] && continue
  openFiles=$(ls $PID/fd | wc -l)
  let TOTAL+=$openFiles
  #lsofOpenFiles=$(lsof -p $PID 2> /dev/null| wc -l )
  cmdLine=$(cat /proc/$PID/cmdline  | tr '\0' ' ' | cut -f 1 -d ' ')
  let remaining=$softNoFile-$openFiles
  if [[ remaining -lt $LIMIT ]]; then
    printf "%6d %-36s (currently %4d open): Limits %5d/%5d\n" "$PID" "$cmdLine" "$openFiles" $softNoFile $hardNoFile
    #printf "%6d %-36s (currently %4d/%4d open): Limits %5d/%5d\n" "$PID" "$cmdLine" "$openFiles" $lsofOpenFiles $softNoFile $hardNoFile
  fi
done

echo "TOTAL: $TOTAL"

#cd /proc; for PID in [0-9]*; do printf "%-20s(%6d) %8d of %8d \n" "$(lsof -p $PID | tail -1 | cut -f1 -d ' ')" $PID $(ls $PID/fd | wc -l ) $(grep 'Max open' $PID/limits | tr -s ' ' | cut -f 4 -d ' '); done; cd -
