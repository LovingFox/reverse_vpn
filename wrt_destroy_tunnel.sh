#!/bin/bash

set -e

ID=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

source "$BASE/source.sh"
set_vars_files $ID
vars_from_files

cat << EOF
##############################################
##### openwrt REMOVE vpn tunnel commands #####
##############################################

uci del_list firewall.@zone[0].network="${IFACE_REMOTE}"
uci -q delete network.${IFACE_REMOTE}
uci -q delete network.wgserver

uci commit firewall
uci commit network

/etc/init.d/firewall restart
/etc/init.d/network restart
EOF
