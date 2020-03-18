#!/usr/bin/env bash
# -------------------------
# Generate monthly averages
# -------------------------

# 3h average directory
riopsDir=''
outDir=''
days="31 28 31 30 31 30 31 31 30 31 30 31"
daysleap="31 29 31 30 31 30 31 31 30 31 30 31"


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

    allFiles=`find ${outdir} -type f -name "*${dim}_ps5km60N.nc"`
    for file in $allFiles ; do
        fname=`filename $file`

        # index for month starting at 0
        month=$((${fname:4:2} - 1))
        year=${fname:0:4}
        
        if [ ! -e ${outDir}/${dim}/${fname::-21}.nc ]
        then
            # leapYear check
            date -d $year-02-29 &>/dev/null && monthDays=$daysleap || monthDays=$days
            thisMonth=`find ${outdir} -type f -name "${fname::-21}*_${dim}_ps5km60N.nc"`
            if [[ $(( monthDays[${month}] * 8 )) == ${#thisMonth[@]} ]] ; then
                ncra $thisMonth ${outDir}/${dim}/${fname:0:6}.nc
            fi
        fi
    done
done
