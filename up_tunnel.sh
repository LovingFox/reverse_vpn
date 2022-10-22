#!/bin/bash

set -e

ID=$1 && shift

ID5D=$(printf "%05d" $ID)
KEYFILE="${ID5D}_private.key"

[ ! -f "$KEYFILE" ] && echo "File $KEYFILE does no extst" && exit 1

WGIFACE=$(cat ${ID5D}_iface)
TABLE=$(cat ${ID5D}_table)
PORT=$(cat ${ID5D}_port)
PUB_CLIENT=$(cat ${ID5D}_public_client.key)
IP=$(cat ${ID5D}_ip)
IP_CLIENT=$(cat ${ID5D}_ip_client)

ip link add dev $WGIFACE type wireguard
ip addr add $IP/31 dev $WGIFACE
wg set $WGIFACE listen-port $PORT private-key $KEYFILE
wg set $WGIFACE peer $PUB_CLIENT allowed-ips 0.0.0.0/0
ip link set $WGIFACE up
ip route add default dev $WGIFACE table $TABLE

ip -4 address show $WGIFACE
ip -4 route show table $TABLE
wg show $WGIFACE
