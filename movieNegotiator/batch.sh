#!/usr/bin/env bash
afplay Let_It_Be.mp3 &
if [ $1 = "examples" ]
then
    for i in "1 2 3 4 5 6 7 8 9"
    do 
        for j in GP YP
        do echo $i $j 
            (yes | ./main.pl example$i.csv $j $2)
            tail -5 report/figures/example$i/$j.txt
        done
    done
elif [ $1 = "pairs" ]
then
    for i in $(seq 30) 
    do 
        for j in GP YP
        do echo $i $j 
            (yes | ./main.pl experiments/pairs/pair$i.csv $j $2)
            tail -5 report/figures/experiments/pairs/pair$i/$j.txt
        done
    done
elif [ $1 = "triples" ]
then
    for i in $(seq 120)
    do 
        for j in GP YP
        do echo $i $j 
            (yes | ./main.pl experiments/triples/triple$i.csv $j $2)
            tail -5 report/figures/experiments/triples/triple$i/$j.txt
        done
    done
else 
    echo "There are only \"triples, pairs, and examples\"!"
fi
killall afplay
