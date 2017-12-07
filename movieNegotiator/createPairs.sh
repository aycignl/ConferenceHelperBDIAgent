#!/usr/bin/env bash
USERS=$(find ./experiments/*txt)
i=1
for u1 in $USERS
do
    for u2 in $USERS
    do
        if [ $u1 != $u2 ]
        then
            paste $u1 $u2 | sed 's/	/,/g' > experiments/pairs/pair$i.csv
            i=$((i+1))
        fi
    done
done