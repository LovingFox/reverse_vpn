#!/bin/bash

set -e

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
    ONLINE="*"
    [ $DELTA -le $STAT_MAXDELTA ] && ONLINE="."
    echo $(printf "%s  %s  %s  %s sec" $ONLINE $REMOTE $IPS $DELTA)
done < <(wg show $IFACE_LOCAL dump | grep ":")
