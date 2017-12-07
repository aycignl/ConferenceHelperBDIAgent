#!/usr/bin/env bash
GP_SUM_OFFERS=0
YP_SUM_OFFERS=0
GP_MAX_OFFER=0
YP_MAX_OFFER=0
GP_MIN_OFFER=1000
YP_MIN_OFFER=1000
GP_COUNT_CONFLICTS=0
YP_COUNT_CONFLICTS=0
GP_SUM_U1=0
GP_SUM_U2=0
GP_SUM_U3=0
GP_UTOTAL=0
YP_SUM_U1=0
YP_SUM_U2=0
YP_SUM_U3=0
YP_UTOTAL=0
for i in $(seq 120)
do
    for j in GP YP
    do
        RESULTS=$(tail -5 report/figures/experiments/triples/triple$i/$j.txt)
        echo "Triple $i with protocol $j"
        RESULT=$(echo $RESULTS | grep '#offers')
        OFFER=$(echo $RESULT | perl -e '$_ = <STDIN>;$_ =~ /offers = ([0-9]+)/;print "$1\n"')
        if [ $j = "GP" ]
        then
            GP_SUM_OFFERS=$((GP_SUM_OFFERS + OFFER))
            if [[ $RESULT =~ "alone" ]]
            then
                echo "GP Alone"
                GP_COUNT_CONFLICTS=$((GP_COUNT_CONFLICTS+1))
            else
                U1=$(echo $RESULT | perl -e '$_ = <STDIN>;$_ =~ /FINAL UTILITIES [0-9]+ = ([0-9]+) [0-9]+ = [0-9]+ [0-9]+ = [0-9]+/;print "$1\n"')
                U2=$(echo $RESULT | perl -e '$_ = <STDIN>;$_ =~ /FINAL UTILITIES [0-9]+ = [0-9]+ [0-9]+ = ([0-9]+) [0-9]+ = [0-9]+/;print "$1\n"')
                U3=$(echo $RESULT | perl -e '$_ = <STDIN>;$_ =~ /FINAL UTILITIES [0-9]+ = [0-9]+ [0-9]+ = [0-9]+ [0-9]+ = ([0-9]+)/;print "$1\n"')
                GP_SUM_U1=$((GP_SUM_U1+U1))
                GP_SUM_U2=$((GP_SUM_U2+U2))
                GP_SUM_U3=$((GP_SUM_U3+U3))
            fi
            if [ $OFFER -gt $GP_MAX_OFFER ]
            then
                GP_MAX_OFFER=$OFFER
            fi
            if [ $OFFER -lt $GP_MIN_OFFER ]
            then
                GP_MIN_OFFER=$OFFER
            fi
        else
            YP_SUM_OFFERS=$((YP_SUM_OFFERS + OFFER))
            if [[ $RESULT =~ "alone" ]]
            then
                echo "YP Alone"
                YP_COUNT_CONFLICTS=$((YP_COUNT_CONFLICTS+1))
            else
                U1=$(echo $RESULT | perl -e '$_ = <STDIN>;$_ =~ /FINAL UTILITIES [0-9]+ = ([0-9]+) [0-9]+ = [0-9]+ [0-9]+ = [0-9]+/;print "$1\n"')
                U2=$(echo $RESULT | perl -e '$_ = <STDIN>;$_ =~ /FINAL UTILITIES [0-9]+ = [0-9]+ [0-9]+ = ([0-9]+) [0-9]+ = [0-9]+/;print "$1\n"')
                U3=$(echo $RESULT | perl -e '$_ = <STDIN>;$_ =~ /FINAL UTILITIES [0-9]+ = [0-9]+ [0-9]+ = [0-9]+ [0-9]+ = ([0-9]+)/;print "$1\n"')
                YP_SUM_U1=$((YP_SUM_U1+U1))
                YP_SUM_U2=$((YP_SUM_U2+U2))
                YP_SUM_U3=$((YP_SUM_U3+U3))
            fi
            if [ $OFFER -gt $YP_MAX_OFFER ]
            then
                YP_MAX_OFFER=$OFFER
            fi
            if [ $OFFER -lt $YP_MIN_OFFER ]
            then
                YP_MIN_OFFER=$OFFER
            fi
        fi
    done
done
GP_AVG_OFFERS=$(echo "scale=2;$GP_SUM_OFFERS/120" | bc)
YP_AVG_OFFERS=$(echo "scale=2;$YP_SUM_OFFERS/120" | bc)
echo "GP_AVG_OFFERS = $GP_AVG_OFFERS"
echo "YP_AVG_OFFERS = $YP_AVG_OFFERS"
echo ""
echo "GP_MAX_OFFER = $GP_MAX_OFFER"
echo "YP_MAX_OFFER = $YP_MAX_OFFER"
echo ""
echo "GP_MIN_OFFER = $GP_MIN_OFFER"
echo "YP_MIN_OFFER = $YP_MIN_OFFER"
echo ""
echo "GP_COUNT_CONFLICTS = $GP_COUNT_CONFLICTS"
echo "YP_COUNT_CONFLICTS = $YP_COUNT_CONFLICTS"
echo ""
GP_AVG_U1=$(echo "scale=2;$GP_SUM_U1/120" | bc)
YP_AVG_U1=$(echo "scale=2;$YP_SUM_U1/120" | bc)
echo "GP_AVG_U1 = $GP_AVG_U1"
echo "YP_AVG_U1 = $YP_AVG_U1"
echo ""
GP_AVG_U2=$(echo "scale=2;$GP_SUM_U2/120" | bc)
YP_AVG_U2=$(echo "scale=2;$YP_SUM_U2/120" | bc)
echo "GP_AVG_U2 = $GP_AVG_U2"
echo "YP_AVG_U2 = $YP_AVG_U2"
echo ""
GP_AVG_U3=$(echo "scale=2;$GP_SUM_U3/120" | bc)
YP_AVG_U3=$(echo "scale=2;$YP_SUM_U3/120" | bc)
echo "GP_AVG_U3 = $GP_AVG_U3"
echo "YP_AVG_U3 = $YP_AVG_U3"
echo ""
GP_UTOTAL=$((GP_SUM_U1 + GP_SUM_U2 + GP_SUM_U3))
YP_UTOTAL=$((YP_SUM_U1 + YP_SUM_U2 + YP_SUM_U3))
GP_AVG_UTOTAL=$(echo "scale=2;$GP_UTOTAL/120" | bc)
YP_AVG_UTOTAL=$(echo "scale=2;$YP_UTOTAL/120" | bc)
echo "GP_AVG_UTOTAL = $GP_AVG_UTOTAL"
echo "YP_AVG_UTOTAL = $YP_AVG_UTOTAL"