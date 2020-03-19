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
        month=$((${fname:4:2} - 1))
        year=${fname:0:4}
        
        if [ ! -e ${outDir}/${dim}/${fname:0:6}.nc ]
        then
            # leapYear check
            date -d $year-02-29 &>/dev/null && monthDays=$daysleap || monthDays=$days
            thisMonth=`find ${outdir} -type l,f -name "${fname:0:6}*${dim}_ps5km60N.nc"`
            count=`du -ch $thisMonth | tail -1 | cut -f 1`
            if [[ $(( ${monthDays[$month]} * 8 )) == $((${count} + 1)) ]]
            then
                ncra -o ${outDir}/${dim}/${fname:0:6}.nc $thisMonth

                # fix timestamp
                ncrename -v time,time_old ${outDir}/${dim}/${fname:0:6}.nc 2>> $logfile
                ncks -A -v time ${thisMonth[-1]} ${outDir}/${dim}/${fname:0:6}.nc 2>> $logfile
                ncks -O -x -v 'time_old' ${outDir}/${dim}/${fname:0:6}.nc ${outDir}/${dim}/${fname:0:6}.nc 2>> $logfile
            else
                echo "Files missing for ${fname:0:6}"
            fi
        fi
    done
done
