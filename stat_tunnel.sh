#!/bin/bash

set -e

BASE=$(dirname $0)
DBDIR="$BASE/db"

if [ $# -eq 0 ]
then
    [ -d "$DBDIR" ] || (echo "$DBDIR not found" && exit 1)
    LIST=$(ls -1 $DBDIR | sed 's/0\+\([0-9]*\)_.*/\1/' | sort -u)
else
    LIST=$@
fi

source "$BASE/source.sh"

for ID in $LIST
do
    set_vars_files $ID
    vars_from_files

    CURRENT=$(date +%s)
    while read -r LINE
    do
        read -r _ _ REMOTE _ LAST RECEIVED SENT<<< $LINE
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
            ONLINE="( )"
            DELTA="-"
            SEC=""
        fi
        printf "%s %s %15s  %22s  %s  %s %s\n" $ONLINE $IFACE_LOCAL $IP_LOCAL $REMOTE $PORT_LOCAL $DELTA $SEC
    done < <(wg show $IFACE_LOCAL dump | tail +2)
done
