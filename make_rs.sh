#!/bin/bash

set -e

BASE=$(dirname $0)
source "$BASE/source.sh"

mkdir -p "$DBDIR"
mkdir -p "$RSDIR"

set_resources_vars

# Generate IP pairs file
FILE=$RSDIR/$RS_IPS_FILE
if [ -f "$FILE" ]; then
    echo "File $FILE exists, resources have been already generated."
    exit 1
fi

echo -n "$FILE creating... "
for a in $(seq 0 255); do
    for b in $(seq 0 2 255); do
        echo "$IPPREFIX.$a.$b-$IPPREFIX.$a.$(($b+1))" >> $FILE
    done
done
echo "Done"

# Count IP pairs
COUNT=$(wc -l $FILE | awk '{print $1}')

# Generate IDs file
FILE=$RSDIR/$RS_IDS_FILE
rm -f $FILE
echo -n "$FILE creating... "
for ID in $(seq 1 $COUNT); do
    echo "$ID" >> $FILE
done
echo "Done"

# Generate PORTs file
FILE=$RSDIR/$RS_PORTS_FILE
rm -f $FILE
echo -n "$FILE creating... "
for ID in $(seq $START_PORT $COUNT); do
    echo "$ID" >> $FILE
done
echo "Done"

# Generate TABs file
FILE=$RSDIR/$RS_TABS_FILE
rm -f $FILE
echo -n "$FILE creating... "
for ID in $(seq $START_TAB $COUNT); do
    echo "$ID" >> $FILE
done
echo "Done"

# Generate PREFs file
FILE=$RSDIR/$RS_PREFS_FILE
rm -f $FILE
echo -n "$FILE creating... "
for ID in $(seq $START_PREF $COUNT); do
    echo "$ID" >> $FILE
done
echo "Done"
