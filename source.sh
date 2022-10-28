#!/bin/bash

export DBDIR="$BASE/db"

function init_db {
    mkdir -p "$DBDIR"
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
    export IP_REMOTE__FILE="${DBDIR}/${IDTEXT}_remote.ip"
}

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function check_and_get_id_list() {
    TEST_LIST=$@

    if [ ! -d "$DBDIR" ]
    then
        echo "$DBDIR not found" >&2
        return
    fi

    if [ -z "$TEST_LIST" ]
    then
        echo "Empty ID list" >&2
        return
    fi

    for ITEM in $TEST_LIST
    do
        if [ "$ITEM" = "all" ]
        then
            ls -1 $DBDIR | sed 's/_.*//; s/^0*//' | sort -n -u
            return
        fi

        if [[ "$ITEM" =~ ^[0-9]+$ ]]
        then
            ID=$ITEM
        elif [[ "$ITEM" =~ ^wg[0-9]{5}$ ]]
        then
            ID=$(echo $ITEM | sed 's/wg//; s/^0*//')
        elif valid_ip $ITEM
        then
            ID=$(grep -E "^${ITEM//./\\.}$" $DBDIR/*_{local,remote}.ip \
                | sed 's/_\(local\|remote\)\.ip.*//; s/.*\///; s/^0*//' \
                | sort -u | head -n 1)
            if [ -z "$ID" ]
            then
                echo "IP '$ITEM' not found" >&2
                continue
            fi
        else
            echo "Unknow item '$ITEM'" >&2
            continue
        fi

        if [ -z "$(ls -1 $DBDIR/ | grep $(printf '%05d' $ID))" ]
        then
            echo "ID '$ID' not found" >&2
        else
            echo $ID
        fi
    done
}

function var_to_files() {
    local FILES_ERROR=0
    for VAR in $(env | grep __FILE | sed 's/=.*//')
    do
        FILE=$(echo ${!VAR})
        [ -f "$FILE" ] && echo "File $FILE extsts" >&2 && FILES_ERROR=1
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
