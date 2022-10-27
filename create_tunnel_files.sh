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
