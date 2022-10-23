#!/bin/bash

set -e

ID=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

source "$BASE/source.sh"
set_vars_files $ID
vars_from_files

cat <<EOF
echo -n "Creating $IFACE_LOCAL interface ($IP_LOCAL -> $IP_REMOTE, port $PORT_LOCAL)... "
if ip link show dev $IFACE_LOCAL > /dev/null 2>&1
then
    echo "$IFACE_LOCAL exists. Skip"
else
    ip link add dev $IFACE_LOCAL type wireguard
    ip addr add $IP_LOCAL/31 dev $IFACE_LOCAL
    wg set $IFACE_LOCAL listen-port $PORT_LOCAL private-key <(echo $KEY_LOCAL)
    wg set $IFACE_LOCAL peer $PUB_REMOTE allowed-ips $IP_REMOTE,0.0.0.0/0
    ip link set $IFACE_LOCAL up
    echo "Done"
fi

echo -n "Adding default -> $IFACE_LOCAL in $TAB_LOCAL table... "
if [[ \$(ip route show table $TAB_LOCAL) ]]
then
    echo "$TAB_LOCAL not empty. Skip"
else
    ip route add default dev $IFACE_LOCAL table $TAB_LOCAL
    echo "Done"
fi

echo -n "Inserting ip rule from $IP_LOCAL with pref $PREF_LOCAL... "
if [[ \$(ip rule show pref $PREF_LOCAL) ]]
then
    echo "$PREF_LOCAL exists. Skip"
else
    ip rule add pref $PREF_LOCAL from $IP_LOCAL lookup $TAB_LOCAL
    echo "Done"
fi
EOF
