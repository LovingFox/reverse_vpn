#!/bin/bash

set -e

ID=$1 && shift

ID5D=$(printf "%05d" $ID)
KEYFILE="${ID5D}_private.key"

[ ! -f "$KEYFILE" ] && echo "File $KEYFILE does no extst" && exit 1

WGIFACE=$(cat ${ID5D}_iface)
TABLE=$(cat ${ID5D}_table)
IP_LOOP=$(cat ${ID5D}_ip_loop)

echo -e "\n== Tunnel Interface"
ip -4 address show $WGIFACE

echo -e "\n== Loop Interface"
ip -4 address show wgloop | grep -E "$IP_LOOP|wgloop:"

echo -e "\n== Tunnel route"
ip -4 route show table $TABLE

echo -e "\n== Wireguard"
wg show $WGIFACE
