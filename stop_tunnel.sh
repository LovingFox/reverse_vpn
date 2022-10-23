#!/bin/bash

set -e

ID=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

source "$BASE/source.sh"
set_vars_files $ID
vars_from_files

cat <<EOF
ip link delete $IFACE_LOCAL
ip rule del pref $TAB_LOCAL
EOF
