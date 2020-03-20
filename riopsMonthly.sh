#!/usr/bin/env bash
# -------------------------
# Generate monthly averages
# -------------------------
logfile='riopsMonthly.log'

# 3h average directory
riopsDir='/home/buildadm/linkout'
outDir='/home/buildadm/monthlyout'
dims="2D 3D"
days=(31 28 31 30 31 30 31 31 30 31 30 31)
daysleap=(31 29 31 30 31 30 31 31 30 31 30 31)

if [ ! -d ${outDir} ]
then
    mkdir $outDir
fi

for dim in $dims ; do
    # Create subdirs if non-existing
    if [ ! -d ${outDir}/${dim}/ ]
    then
        mkdir ${outDir}/${dim}/
    fi

    allFiles=`find ${riopsDir} -type l,f -name "*${dim}_ps5km60N.nc"`
    for file in $allFiles ; do
        fname=`filename $file`

        # index for month starting at 0
        if [[ ${fname:4:1} == '0' ]]
        then
            month=$((${fname:5:1} - 1))
        else
            month=$((${fname:4:2} - 1))
        fi
        year=${fname:0:4}
        
        if [ ! -e ${outDir}/${dim}/${fname:0:6}.nc ]
        then
            # leapYear check
            date -d $year-02-29 &>/dev/null && monthDays=$daysleap || monthDays=$days
            thisMonth=`find ${riopsDir} -type l,f -name "${fname:0:6}*${dim}_ps5km60N.nc"`
            count=`du -ch $thisMonth | tail -1 | cut -f 1`
            if [[ $(( monthDays[$month] * 8 )) == ${count} ]]
            then
                ncra -o ${outDir}/${dim}/${fname:0:6}.nc $thisMonth
            else
                echo "Files missing for ${fname:0:6}"
            fi
        fi
    done
done
