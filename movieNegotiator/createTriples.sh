#!/usr/bin/env bash
USERS=$(find ./experiments/*txt)
i=1
for u1 in $USERS
do
    for u2 in $USERS
    do
        for u3 in $USERS
        do
            if [ $u1 != $u2 ] && [ $u2 != $u3 ] && [ $u1 != $u3 ]
            then
                paste $u1 $u2 $u3 | sed 's/	/,/g' > experiments/triples/triple$i.csv
                i=$((i+1))
            fi
        done
    done
done