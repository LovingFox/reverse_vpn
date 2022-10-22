#!/bin/bash

set -e

SERVER="debian.rtru.tk"
PREFIX="10.200.0.0/16"
NETWORK="10.200.0.0"
MASK="255.255.0.0"

ID=$1 && shift

ID5D=$(printf "%05d" $ID)
KEYFILE="${ID5D}_private.key"

[ ! -f "$KEYFILE" ] && echo "File $KEYFILE does no extst" && exit 1

PORT=$(cat ${ID5D}_port)
KEY_CLIENT=$(cat ${ID5D}_private_client.key)
PUB=$(cat ${ID5D}_public.key)
IP=$(cat ${ID5D}_ip)
IP_CLIENT=$(cat ${ID5D}_ip_client)
WG_IF="wg"

NETWORK_ESC=$(echo "$NETWORK" | sed 's/\./\\./g')

cat << EOF
######## ADD VPN TUNNEL

uci add_list firewall.@zone[0].network="${WG_IF}"

uci -q delete network.${WG_IF}
uci set network.${WG_IF}="interface"
uci set network.${WG_IF}.proto="wireguard"
uci set network.${WG_IF}.private_key="${KEY_CLIENT}"
uci add_list network.${WG_IF}.addresses="${IP_CLIENT}/31"

uci -q delete network.wgserver
uci set network.wgserver="wireguard_${WG_IF}"
uci set network.wgserver.public_key="${PUB}"
uci set network.wgserver.endpoint_host="${SERVER}"
uci set network.wgserver.endpoint_port="${PORT}"
uci set network.wgserver.route_allowed_ips="1"
uci set network.wgserver.persistent_keepalive="25"
uci add_list network.wgserver.allowed_ips="$IP,$PREFIX"

ROUTE=\$(uci add network route)
uci set network.\$ROUTE.interface="${WG_IF}"
uci set network.\$ROUTE.target="$NETWORK"
uci set network.\$ROUTE.netmask="$MASK"

uci commit network

/etc/init.d/firewall restart
/etc/init.d/network restart

######## DELETE VPN TUNNEL
uci add_list firewall.@zone[0].network="${WG_IF}"
uci -q delete network.${WG_IF}
uci -q delete network.wgserver
ROUTE=\$(uci show network | sed -n 's/network\\.\\(.*\\)\\.target=.*$NETWORK_ESC.*/\\1/p')
uci delete network.\$ROUTE

uci commit network

/etc/init.d/firewall restart
/etc/init.d/network restart

EOF
