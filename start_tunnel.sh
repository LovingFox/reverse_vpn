#!/bin/bash

set -e

BASE=$(dirname $0)
source "$BASE/source.sh"

LIST=$(check_and_get_id_list $@)

for ID in $LIST
do
    set_vars_files $ID
    vars_from_files

    printf "%-70s" "Creating $IFACE_LOCAL interface ($IP_LOCAL -> $IP_REMOTE, port $PORT_LOCAL)... "
    if ip link show dev $IFACE_LOCAL > /dev/null 2>&1
    then
        echo "Skip"
    else
        $SUDO ip link add dev $IFACE_LOCAL type wireguard
        $SUDO ip addr add $IP_LOCAL/31 dev $IFACE_LOCAL
        $SUDO bash -c "wg set $IFACE_LOCAL listen-port $PORT_LOCAL private-key <(echo $KEY_LOCAL)"
        $SUDO wg set $IFACE_LOCAL peer $PUB_REMOTE persistent-keepalive $KEEPALIVE allowed-ips $IP_REMOTE,0.0.0.0/0
        $SUDO ip link set $IFACE_LOCAL up
        echo "Done"
    fi

    printf "%-70s" "Adding default -> $IFACE_LOCAL in $TAB_LOCAL table... "
    if [[ $(ip route show table $TAB_LOCAL) ]]
    then
        echo "Skip"
    else
        $SUDO ip link set $IFACE_LOCAL up
        $SUDO ip route add default dev $IFACE_LOCAL table $TAB_LOCAL
        echo "Done"
    fi

    printf "%-70s" "Inserting ip rule from $IP_LOCAL with pref $PREF_LOCAL... "
    if [[ $(ip rule show pref $PREF_LOCAL) ]]
    then
        echo "Skip"
    else
        $SUDO ip rule add pref $PREF_LOCAL from $IP_LOCAL lookup $TAB_LOCAL
        echo "Done"
    fi
done
