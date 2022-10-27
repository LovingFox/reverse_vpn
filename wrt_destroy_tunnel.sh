#!/bin/bash

set -e

BASE=$(dirname $0)
source "$BASE/source.sh"

LIST=$(check_and_get_id_list $@)

for ID in $LIST
do
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
done
