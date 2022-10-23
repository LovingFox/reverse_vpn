#!/bin/bash

set -e

ID=$1 && shift
IP_LOCAL=$1 && shift
IP_REMOTE=$1 && shift
PORT_LOCAL=$1 && shift
TAB_LOCAL=$1 && shift
PREF_LOCAL=$1 && shift

BASE=$(dirname $0)
DBDIR="$BASE/db"

mkdir -p "$DBDIR"
source "$BASE/source.sh"

set_vars_files
var_to_files

echo "Files are created"
