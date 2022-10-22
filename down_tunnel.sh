#!/bin/bash

set -e

ID=$1 && shift

ID5D=$(printf "%05d" $ID)
WGIFACE=$(cat ${ID5D}_iface)

ip link delete $WGIFACE
ip rule del pref $TABLE
