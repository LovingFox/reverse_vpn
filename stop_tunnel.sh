#!/bin/bash

set -e

BASE=$(dirname $0)
source "$BASE/source.sh"

ID=$1 && shift

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
