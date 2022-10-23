#!/bin/bash

set_vars_files() {
    local ID=$1
    export IDTEXT=$(printf "%05d" $ID)

    export SERVER="debian.rtru.tk"

    export IFACE_LOCAL="wg$IDTEXT"
    export IFACE_REMOTE="wg$IDTEXT"

    export KEY_LOCAL__FILE="${DBDIR}/${IDTEXT}_local.key"
    export PUB_LOCAL__FILE="${DBDIR}/${IDTEXT}_local.pub"
    export IP_LOCAL__FILE="${DBDIR}/${IDTEXT}_ip_local"
    export TAB_LOCAL__FILE="${DBDIR}/${IDTEXT}_tab"
    export PREF_LOCAL__FILE="${DBDIR}/${IDTEXT}_pref"
    export PORT_LOCAL__FILE="${DBDIR}/${IDTEXT}_port"
    export IFACE_LOCAL__FILE="${DBDIR}/${IDTEXT}_iface"

    export KEY_REMOTE__FILE="${DBDIR}/${IDTEXT}_remote.key"
    export PUB_REMOTE__FILE="${DBDIR}/${IDTEXT}_local.key"
    export IP_REMOTE__FILE="${DBDIR}/${IDTEXT}_ip_remote"
}

var_to_files() {
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

vars_from_files() {
    FILES_ERROR=0
    for FILE_VARNAME in $(env | grep __FILE | sed 's/=.*//')
    do
       FILE_NAME=$(echo ${!FILE_VARNAME})
       if [ ! -f "$FILE_NAME" ]
       then
           echo >&2 "File $FILE_NAME does not extst"
           FILES_ERROR=1
       else
           VARNAME=$(echo $FILE_VARNAME | sed 's/__FILE//')
           read $VARNAME <<< $(cat $FILE_NAME)
           export $VARNAME
       fi
    done
    if [ "$FILES_ERROR" = "1" ]; then exit 1; fi 
}
