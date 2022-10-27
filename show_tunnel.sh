#!/bin/bash

set -e

BASE=$(dirname $0)
source "$BASE/source.sh"

LIST=$(check_and_get_id_list $@)

for ID in $LIST
do
    set_vars_files $ID
    vars_from_files

    echo -e "\n### Tunnel Interface"
    ip -4 address show $IFACE_LOCAL

    echo -e "\n### Tunnel route table"
    ip -4 route show table $TAB_LOCAL

    echo -e "\n### IP Rule"
    ip rule show pref $PREF_LOCAL

    echo -e "\n### Wireguard"
    $SUDO wg show $IFACE_LOCAL
done
