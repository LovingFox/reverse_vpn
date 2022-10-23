#!/bin/bash

set -e

set -e

ID=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

source "$BASE/source.sh"
set_vars_files $ID
vars_from_files

echo -e "\n### Tunnel Interface"
ip -4 address show $IFACE_LOCAL

echo -e "\n### Tunnel route table"
ip -4 route show table $TAB_LOCAL

echo -e "\n### IP Rule"
ip rule show pref $PREF_LOCAL

echo -e "\n### Wireguard"
wg show $IFACE_LOCAL
