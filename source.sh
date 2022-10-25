#!/bin/bash

export DBDIR="$BASE/db"
export RSDIR="$BASE/rs"

function set_resources_vars() {
    export IPPREFIX="10.10"
    export START_PORT=3001
    export START_TAB=1001
    export START_PREF=1001
    export RS_IDS_FILE="rs_ids"
    export RS_IPS_FILE="rs_ips"
    export RS_PORTS_FILE="rs_ports"
    export RS_TABS_FILE="rs_tabs"
    export RS_PREFS_FILE="rs_prefs"
}

function set_vars_files() {
    local ID=$1
    export IDTEXT=$(printf "%05d" $ID)

    #export SUDO=""
    export SUDO="sudo -u root"
    export SERVER="${SERVER:-172.16.96.3}"
    export STAT_MAXDELTA1=120
    export STAT_MAXDELTA2=600

    export IFACE_LOCAL="wg$IDTEXT"
    export IFACE_REMOTE="wg$IDTEXT"

    export KEY_LOCAL__FILE="${DBDIR}/${IDTEXT}_local.key"
    export PUB_LOCAL__FILE="${DBDIR}/${IDTEXT}_local.pub"
    export IP_LOCAL__FILE="${DBDIR}/${IDTEXT}_local.ip"
    export TAB_LOCAL__FILE="${DBDIR}/${IDTEXT}_local.tab"
    export PREF_LOCAL__FILE="${DBDIR}/${IDTEXT}_local.pref"
    export PORT_LOCAL__FILE="${DBDIR}/${IDTEXT}_local.port"
    export IFACE_LOCAL__FILE="${DBDIR}/${IDTEXT}_local.iface"

    export KEY_REMOTE__FILE="${DBDIR}/${IDTEXT}_remote.key"
    export PUB_REMOTE__FILE="${DBDIR}/${IDTEXT}_remote.pub"
    export IP_REMOTE__FILE="${DBDIR}/${IDTEXT}_remote_ip"
}

function var_to_files() {
    FILES_ERROR=0
    for VAR in $(env | grep __FILE | sed 's/=.*//')
    do
        FILE=$(echo ${!VAR})
        [ -f "$FILE" ] && >&2 echo "File $FILE extsts" && FILES_ERROR=1
    done
    if [ "$FILES_ERROR" = "1" ]; then exit 1; fi

    (umask 0077; wg genkey > $KEY_LOCAL__FILE)
    wg pubkey < $KEY_LOCAL__FILE > $PUB_LOCAL__FILE

    (umask 0077; wg genkey > $KEY_REMOTE__FILE)
    wg pubkey < $KEY_REMOTE__FILE > $PUB_REMOTE__FILE

    echo "$IP_LOCAL" > $IP_LOCAL__FILE
    echo "$IP_REMOTE" > $IP_REMOTE__FILE
    echo "$IFACE_LOCAL" > $IFACE_LOCAL__FILE
    echo "$TAB_LOCAL" > $TAB_LOCAL__FILE
    echo "$PREF_LOCAL" > $PREF_LOCAL__FILE
    echo "$PORT_LOCAL" > $PORT_LOCAL__FILE
}

function vars_from_files() {
    for FILE_VARNAME in $(env | grep __FILE | sed 's/=.*//')
    do
       FILE_NAME=$(echo ${!FILE_VARNAME})
       if [ ! -f "$FILE_NAME" ]
       then
           echo >&2 "ERROR: File $FILE_NAME does not extst"
           exit 1
       else
           VARNAME=$(echo $FILE_VARNAME | sed 's/__FILE//')
           read $VARNAME <<< $(cat $FILE_NAME)
           export $VARNAME
       fi
    done
}

# Find resource
function find_res() {
  local FILE=$1; shift
  local RESOURCE=$1; shift

  if [ -z "$FILE" ]
  then
    echo "File name is empty" >&2
    return
  fi

  if [ -z "$RESOURCE" ]
  then
    RESOURCE=$(head -n 1 $FILE) || return
  else
    RESOURCE=$(sed -n '/^'$RESOURCE'$/p' $FILE) || return
  fi

  [ -z "$RESOURCE" ] || echo $RESOURCE
}

# Take resource (remove it from the resource file)
function get_res() {
  local FILE=$1; shift
  local RESOURCE=$1; shift

  if [ -z "$FILE" ]
  then
    echo "File name is empty" >&2
    return
  fi

  if [ -z "$RESOURCE" ]
  then
    echo "Resource field is empty" >&2
  else
    RESOURCE_CHECK=$(find_res $FILE $RESOURCE)
    if [ -z "$RESOURCE_CHECK" ]
    then
      echo "Resource $RESOURCE does not exist in $FILE" >&2
      return
    else
      sed -i '/^'$RESOURCE'$/d' $FILE || return
    fi
  fi

  echo $RESOURCE
}

# Return resource (add it to the end of the resource file)
function set_res() {
  local FILE=$1; shift
  local RESOURCE=$1; shift

  if [ -z "$FILE" ]
  then
    echo "File name is empty" >&2
    return
  fi

  if [ -z "$RESOURCE" ]
  then
    echo "Resource field is empty" >&2
  else
    RESOURCE_CHECK=$(find_res $FILE $RESOURCE)
    if [ -z "$RESOURCE_CHECK" ]
    then
      echo "$RESOURCE" | tee -a $FILE
    else
      echo "Resource $RESOURCE is already set in $FILE" >&2
    fi
  fi
}
