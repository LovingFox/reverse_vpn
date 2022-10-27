#!/bin/bash

set -e

BASE=$(dirname $0)
source "$BASE/source.sh"

init_db

ID=$1 && shift
IP_LOCAL=$1 && shift
IP_REMOTE=$1 && shift
PORT_LOCAL=$1 && shift
TAB_LOCAL=$1 && shift
PREF_LOCAL=$1 && shift

set_vars_files $ID
var_to_files

echo "Files are created"
echo "ID: $ID"
echo "Tunnel:"
echo "  iface: $IFACE_LOCAL"
echo "  port: $PORT_LOCAL"
echo "  ip: $IP_LOCAL remote: $IP_REMOTE"
echo "Table: $TAB_LOCAL, Pref: $PREF_LOCAL"
