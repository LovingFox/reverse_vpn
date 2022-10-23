#!/bin/bash

set -e

set -e

ID=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

source "$BASE/source.sh"
set_vars_files $ID
vars_from_files

while read -r LINE
do
  read -r PUBKEY _ REMOTE IPS LAST RECEIVED SENT<<< $LINE
  DELTA=$(( $CURRENT - $LAST ))
  if [ $DELTA -le $MAXDELTA ]
  then
     echo peer: $PUBKEY
     echo "  remote: $REMOTE"
     echo "  ips: $IPS"
     echo "  last: $DELTA sec"
     echo ""
  fi
done < <(wg show $IFACE_LOCAL dump | grep ":")
