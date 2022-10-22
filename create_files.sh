#!/bin/bash

set -e

TABSHIFT=1000
PORTSHIFT=30000

ID=$1 && shift
IP=$1 && shift
IP_CLIENT=$1 && shift
IP_LOOP=$1 && shift

ID5D=$(printf "%05d" $ID)
WGIFACE="wg$ID5D"
TABLE=$(($ID + $TABSHIFT))
PORT=$(($ID + $PORTSHIFT))
KEYFILE="${ID5D}_private.key"
PUBFILE="${ID5D}_public.key"
KEYFILE_CLIENT="${ID5D}_private_client.key"
PUBFILE_CLIENT="${ID5D}_public_client.key"

[ -f "$KEYFILE" ] && echo "File $KEYFILE extsts" && exit 1

(umask 0077; wg genkey > $KEYFILE)
wg pubkey < $KEYFILE > $PUBFILE

(umask 0077; wg genkey > $KEYFILE_CLIENT)
wg pubkey < $KEYFILE_CLIENT > $PUBFILE_CLIENT

echo "$IP" > "${ID5D}_ip"
echo "$IP_CLIENT" > "${ID5D}_ip_client"
echo "$IP_LOOP" > "${ID5D}_ip_loop"
echo "$WGIFACE" > "${ID5D}_iface"
echo "$TABLE" > "${ID5D}_table"
echo "$PORT" > "${ID5D}_port"
