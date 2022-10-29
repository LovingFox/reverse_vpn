#!/bin/bash

set -e

BASE=$(dirname $0)
source "$BASE/source.sh"

LIST=$(check_and_get_id_list $@)

for ID in $LIST
do
    set_vars_files $ID
    vars_from_files

    if ! ip link show dev $IFACE_LOCAL > /dev/null 2>&1
    then
        printf "   |       %s %5s %15s  %22s\n" $IFACE_LOCAL $PORT_LOCAL $IP_LOCAL "(no_iface)"
        continue
    fi

    STATUS=" UP "
    if [ -n "$(ip link show dev $IFACE_LOCAL | grep DOWN)" ]
    then
        STATUS="down"
    fi

    CURRENT=$(date +%s)
    while read -r LINE
    do
        read -r _ _ REMOTE _ LAST RECEIVED SENT<<< $LINE
        DELTA=$(( $CURRENT - $LAST ))
        ONLINE="***|"
        if [ $DELTA -gt $STAT_MAXDELTA1 ]
        then
            if [ $DELTA -le $STAT_MAXDELTA2 ]; then
                ONLINE=" **|"
            else
                ONLINE="  o|"
            fi
        fi
        if [ $LAST -eq 0 ]
        then
            ONLINE="  -|"
            DELTA="-"
        fi
        printf "%s %s  %s %5s %15s  %22s  %s\n" "$ONLINE" "$STATUS" $IFACE_LOCAL $PORT_LOCAL $IP_LOCAL $REMOTE $DELTA
    done < <($SUDO wg show $IFACE_LOCAL dump | tail +2)
done
