#!/bin/bash

set -e

BASE=$(dirname $0)
source "$BASE/source.sh"

set_resources_vars

ID=$(find_res $RSDIR/$RS_IDS_FILE)
if [ -z "$ID" ]; then
    echo "Cannot find ID resource..." >&2
    exit 1
fi

_IPS=$(find_res $RSDIR/$RS_IPS_FILE)
IP_LOCAL=$(echo $_IPS | awk -F '-' '{print $1}')
IP_REMOTE=$(echo $_IPS | awk -F '-' '{print $2}')
if [ -z "$IP_LOCAL" ] || [ -z "$IP_REMOTE" ]; then
    echo "Cannot find IP pair resource..." >&2
    exit 1
fi

PORT_LOCAL=$(find_res $RSDIR/$RS_PORTS_FILE)
if [ -z "$PORT_LOCAL" ]; then
    echo "Cannot find PORT resources..." >&2
    exit 1
fi

TAB_LOCAL=$(find_res $RSDIR/$RS_TABS_FILE)
if [ -z "$TAB_LOCAL" ]; then
    echo "Cannot find TAB resources..." >&2
    exit 1
fi

PREF_LOCAL=$(find_res $RSDIR/$RS_PREFS_FILE)
if [ -z "$PREF_LOCAL" ]; then
    echo "Cannot find PREF resources..." >&2
    exit 1
fi

get_res $RSDIR/$RS_IDS_FILE $ID > /dev/null
get_res $RSDIR/$RS_IPS_FILE $_IPS > /dev/null
get_res $RSDIR/$RS_PORTS_FILE $PORT_LOCAL > /dev/null
get_res $RSDIR/$RS_TABS_FILE $TAB_LOCAL > /dev/null
get_res $RSDIR/$RS_PREFS_FILE $PREF_LOCAL > /dev/null

set_vars_files $ID
var_to_files

echo "Files are created"
echo "ID: $ID"
echo "Tunnel:"
echo "  iface: $IFACE_LOCAL"
echo "  port: $PORT_LOCAL"
echo "  ip: $IP_LOCAL remote: $IP_REMOTE"
echo "Table: $TAB_LOCAL, Pref: $PREF_LOCAL"
