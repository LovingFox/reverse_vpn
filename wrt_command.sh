#!/bin/bash

set -e

SERVER="debian.rtru.tk"
NETWORK="10.200.0.0/16"
# sudo ip link add wgloop type dummy
# sudo ip address add 10.200.0.1/32 dev wgloop
# sudo ip link set wgloop up

ID=$1 && shift

ID5D=$(printf "%05d" $ID)
KEYFILE="${ID5D}_private.key"

[ ! -f "$KEYFILE" ] && echo "File $KEYFILE does no extst" && exit 1

PORT=$(cat ${ID5D}_port)
KEY_CLIENT=$(cat ${ID5D}_private_client.key)
PUB=$(cat ${ID5D}_public.key)
IP=$(cat ${ID5D}_ip)
IP_CLIENT=$(cat ${ID5D}_ip_client)
WG_IF="vpn"

cat << EOF
WG_SERV="${SERVER}"
WG_PORT="$PORT"
WG_ADDR="$IP_CLIENT/31"
WG_KEY="$KEY_CLIENT"
WG_PUB="$PUB"

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
uci add_list network.wgserver.allowed_ips="$IP,$NETWORK"
uci commit network
EOF
