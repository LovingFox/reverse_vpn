#!/bin/bash

set -e

ID=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

source "$BASE/source.sh"
set_vars_files $ID
vars_from_files

cat <<EOF
echo -n "Deleting $IFACE_LOCAL interface... "
if ! ip link show dev $IFACE_LOCAL > /dev/null 2>&1
then
    echo "$IFACE_LOCAL not found. Skip"
else
    ip link delete $IFACE_LOCAL
    echo "Done"
fi

echo -n "Removing ip rule with pref $PREF_LOCAL... "
if [[ ! \$(ip rule show pref $PREF_LOCAL) ]]
then
    echo "$PREF_LOCAL not found. Skip"
else
    ip rule del pref $TAB_LOCAL
    echo "Done"
fi
EOF
