#!/bin/bash

set -e

ID=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

source "$BASE/source.sh"
set_vars_files
vars_from_files

cat << EOF
######## ADD VPN TUNNEL

uci add_list firewall.@zone[0].network="${IFACE_REMOTE}"

uci -q delete network.${IFACE_REMOTE}
uci set network.${IFACE_REMOTE}="interface"
uci set network.${IFACE_REMOTE}.proto="wireguard"
uci set network.${IFACE_REMOTE}.private_key="${KEY_REMOTE}"
uci add_list network.${IFACE_REMOTE}.addresses="${IP_REMOTE}/31"

uci -q delete network.wgserver
uci set network.wgserver="wireguard_${IFACE_REMOTE}"
uci set network.wgserver.public_key="${PUB_LOCAL}"
uci set network.wgserver.endpoint_host="${SERVER}"
uci set network.wgserver.endpoint_port="${PORT_LOCAL}"
uci set network.wgserver.route_allowed_ips="1"
uci set network.wgserver.persistent_keepalive="25"
uci add_list network.wgserver.allowed_ips="$IP_LOCAL"

uci commit network

/etc/init.d/firewall restart
/etc/init.d/network restart

######## DELETE VPN TUNNEL
uci add_list firewall.@zone[0].network="${IFACE_REMOTE}"
uci -q delete network.${IFACE_REMOTE}
uci -q delete network.wgserver

uci commit network

/etc/init.d/firewall restart
/etc/init.d/network restart

EOF
