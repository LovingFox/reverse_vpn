#!/bin/bash

set -e

ID=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

source "$BASE/source.sh"
set_vars_files $ID
vars_from_files

printf "%-70s" "Deleting $IFACE_LOCAL interface... "
if ! ip link show dev $IFACE_LOCAL > /dev/null 2>&1
then
    echo "Skip, not found"
else
    $SUDO ip link delete $IFACE_LOCAL
    echo "Done"
fi

printf "%-70s" "Removing ip rule with pref $PREF_LOCAL... "
if [[ ! $(ip rule show pref $PREF_LOCAL) ]]
then
    echo "Skip, not found"
else
    $SUDO ip rule del pref $TAB_LOCAL
    echo "Done"
fi
