#!/bin/bash

set_vars_files() {
    local ID=$1
    export IDTEXT=$(printf "%05d" $ID)

    export SERVER="debian.rtru.tk"
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
