#!/bin/bash

set -e

set -e

ID=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

source "$BASE/source.sh"
set_vars_files $ID
vars_from_files

wg show $IFACE_LOCAL dump | grep ":"
