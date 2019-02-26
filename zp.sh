#!/usr/bin/env bash


COLOURS=(
"\e[7;49;31m"
"\e[7;49;32m"
"\e[7;49;33m"
"\e[7;49;35m"
"\e[7;49;37m"
"\e[2;100;37m"
"\e[0;49;33m"
"\e[7;49;90m"
"\e[7;49;91m"
"\e[2;100;32m"
"\e[2;100;30m"
"\e[7;101;30m"
"\e[7;49;34m"
"\e[7;102;30m"
"\e[0;49;31m"
"\e[7;100;30m"
"\e[0;49;32m"
"\e[0;49;34m"
"\e[2;100;35m"
"\e[0;49;35m"
"\e[2;100;34m"
"\e[0;49;36m"
"\e[0;49;37m"
"\e[2;100;31m"
"\e[7;103;30m"
"\e[2;100;33m"
"\e[7;49;39m"
"\e[2;100;36m"
)

echo "JBOD count:"
read JBODS
echo "DRIVES in mirror:"
read MIRROR
echo "SPARE disks: (not in array)"
read SPARE
echo "ONE JBOD DISK COUNT:"
read JBOD_D_C
echo "ONE DRIVE TB:"
read DS

TOTAL=$(( JBOD_D_C * JBODS ))
COLOR_ARRAY[0]=1
echo ""
CUR=0

ACTIVE=$((TOTAL - SPARE))

while [ ! $(( (ACTIVE) % MIRROR)) -eq 0 ]; do
     ACTIVE=$((ACTIVE - 1))
done

STEP=$((ACTIVE/MIRROR))
echo "acct with $ACTIVE disks and step $STEP. Total size of array: $(( ACTIVE * DS / MIRROR ))TB, spare drives: $(( TOTAL - ACTIVE ))"
echo "Optimal mirrors for $MIRROR layout:"

for i in $( seq 1 $STEP ); do
    CUR_COLOR=${COLOURS[$i]}
    printf "$CUR_COLOR"
    COLOR_ARRAY[$i]=$CUR_COLOR
    echo -n "$i "
    for m in $( seq 1 $(( MIRROR - 1)) ); do
        echo -n "$(((STEP * m) + i)) "
        COLOR_ARRAY[$(((STEP * m) + i))]=$CUR_COLOR
    done
    printf "\e[0m\n"
done


echo ""
echo "COLORED:"
echo ""


CUR=1
DISK_IN_LINE=$(( $JBOD_D_C / $( echo "sqrt($JBOD_D_C) + 1" | bc )))
spaces="  "

while [ $CUR -le $ACTIVE ]; do
    for x in $(seq 1 $JBODS); do
        for z in $(seq 1 $DISK_IN_LINE); do
            for i in $( seq 1 $(( $JBOD_D_C / $DISK_IN_LINE ))); do
                printf "${COLOR_ARRAY[$CUR]}%s %s\e[0m" $CUR "${spaces:${#CUR}}"
                CUR=$(( CUR + 1 ))
            done
        printf "\n"
        done
    printf "\n"
    done
done


echo -n "zpool create -f -o ashift=12 STORAGE "; for i in $( seq 1 $STEP ); do echo -n " mirror  $i"; for m in $( seq 1 $(( MIRROR - 1)) ); do echo -n " $(((STEP * m) + i ))";  done; done; echo ""
