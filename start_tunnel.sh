#!/bin/bash

set -e

ID=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

source "$BASE/source.sh"
set_vars_files $ID
vars_from_files

cat <<EOF
ip link add dev $IFACE_LOCAL type wireguard
ip addr add $IP_LOCAL/31 dev $IFACE_LOCAL
wg set $IFACE_LOCAL listen-port $PORT_LOCAL private-key <(echo $KEY_LOCAL)
wg set $IFACE_LOCAL peer $PUB_REMOTE allowed-ips $IP_REMOTE,0.0.0.0/0
ip link set $IFACE_LOCAL up

ip route add default dev $IFACE_LOCAL table $TAB_LOCAL
ip rule add pref $PREF_LOCAL from $IP_LOCAL lookup $TAB_LOCAL
EOF

#./show_tunnel.sh $ID
