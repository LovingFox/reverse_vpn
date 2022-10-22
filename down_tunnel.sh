#!/bin/bash

set -e

ID=$1 && shift

ID5D=$(printf "%05d" $ID)
WGIFACE=$(cat ${ID5D}_iface)
TABLE=$(cat ${ID5D}_table)
IP_LOOP=$(cat ${ID5D}_ip_loop)

ip link delete $WGIFACE
ip rule del pref $TABLE
ip address delete $IP_LOOP/32 dev wgloop
