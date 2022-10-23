#!/bin/bash

set -e

ID=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

source "$BASE/source.sh"
set_vars_files $ID
vars_from_files

CURRENT=$(date +%s)
while read -r LINE
do
    read -r _ _ REMOTE IPS LAST RECEIVED SENT<<< $LINE
    DELTA=$(( $CURRENT - $LAST ))
    ONLINE="(*)"
    if [ $DELTA -gt $STAT_MAXDELTA1 ]
    then
        if [ $DELTA -le $STAT_MAXDELTA2 ]
        then
            ONLINE="(o)"
        else
            ONLINE="(.)"
        fi
    fi
    SEC="sec"
    if [ $LAST -eq 0 ]
    then
        DELTA="-"
        SEC=""
    fi
    printf "%s %s %22s  %s  %s  %s %s\n" $ONLINE $IFACE_LOCAL $REMOTE $PORT_LOCAL $IPS $DELTA $SEC
done < <(wg show $IFACE_LOCAL dump | tail +2)
