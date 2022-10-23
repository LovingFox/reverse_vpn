#!/bin/bash

set -e

ID=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

source "$BASE/source.sh"
set_vars_files $ID
vars_from_files

cat <<EOF
echo "Deleting $IFACE_LOCAL interface ..."
if ! ip link show dev $IFACE_LOCAL > /dev/null 2>&1
then
    echo "Interface $IFACE_LOCAL does not exist. Skip ..."
else
    ip link delete $IFACE_LOCAL
    echo "Done"
fi

echo "Removing ip rule with pref $PREF_LOCAL ..."
if [[ ! \$(ip rule show pref $PREF_LOCAL) ]]
then
    echo "IP rule $PREF_LOCAL does not exist. Skip ..."
else
    ip rule del pref $TAB_LOCAL
    echo "Done"
fi
EOF
