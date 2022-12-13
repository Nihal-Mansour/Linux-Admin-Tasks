#!/usr/bin/env bash
#Nihal Mansour Abd El-Bari

#function to get number of days according to the given month
getMonthDays () {
    if [ $1 -eq 2 ]
    then
        duration=28
    fi
    case $1 in
    4|6|9) duration=30 ;;
    esac
    case $1 in
    1|3|5|7|8|10|12) duration=31 ;;
    esac
}


#check whether folder reports existed or not
if [ ! -d ~/Reports ]
then 
    echo "Creating Reports Folder ..."
    mkdir ~/Reports
else 
    echo "Reports Folder Found ..."
fi

   
#check whether year folder existed or not 
if [ ! -d ~/Reports/$(date +%Y) ]
then
    echo "Creating Year Folder ..."
    mkdir ~/Reports/$(date +%Y)
else
    echo "Year Folder Found ..."
fi

for i in {1..12}
do
    #check whether month folder existed or not
    if [ ! -d ~/Reports/$(date +%Y)/$i ]
    then
        echo "Creating Month $i Folder ..."
        mkdir ~/Reports/$(date +%Y)/$i
    else
        echo "Month $i Folder Found ..."
    fi

    getMonthDays "$i"
    for j in $(seq 1 $duration)
    do
        #check whether day file existed or not
        if [ ! -e ~/Reports/$(date +%Y)/$i/$j.xls ]
        then
            echo "Creating Day $j File ..."
            touch ~/Reports/$(date +%Y)/$i/$j.xls
        else
            echo "Day $j File Found ..."
        fi
    done
done
            
#taking backup 
#check whether backup folder existed or not
if [ ! -d ~/Backups ]
then
    echo "Creating Backups Folder ..."
    mkdir ~/Backups
else
    echo "Backups Folder Found ..."
fi

#taking backup within 12am to 5am
if [ $(date +%I) -lt 5 ] || [ $(date +%I) -eq 12 ] && [ $(date +%P) = "am" ]
then
    echo "Taking Backups ..."
    cp -r ~/Reports ~/Backups
else
    echo "Backups will be from 12am to 5am only"
fi 

