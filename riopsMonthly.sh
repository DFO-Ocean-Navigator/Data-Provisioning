#!/usr/bin/env bash
# -------------------------
# Generate monthly averages
# -------------------------
logfile='riopsMonthly.log'

# 3h average directory
riopsDir='/data/RIOPS/riopsf'
outDir='/home/buildadm/monthlyout'
dims="2D 3D"

attempt=()

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

        if ([ ! -e ${outDir}/${dim}/${fname:0:6}.nc ] && [[ ! " ${attempt[@]} " =~ " ${fname:0:6}${dim} " ]])
        then
            attempt=(${attempt[@]} "${fname:0:6}${dim}")
            # leapYear check
            date -d $year-02-29 &>/dev/null && monthDays=(31 29 31 30 31 30 31 31 30 31 30 31) || monthDays=(31 29 31 30 31 30 31 31 30 31 30 31)

            arr=()
            thisMonth=`find ${riopsDir} -type l,f -name "${fname:0:6}*${dim}_ps5km60N.nc"`
            count=`echo $thisMonth | tr " " "\n" | wc -l`
            for names in $thisMonth ; do
                arr=(${arr[@]} "$names")
            done

            echo "${count} files found for ${fname:0:6} ${dim}" | tee -a riopsMonthly.log
            echo "Expected: $(( monthDays[$month] * 8 ))"  | tee -a riopsMonthly.log

            if [[ $(( monthDays[$month] * 8 )) == ${count} ]]
            then
                echo "Starting average for ${fname:0:6} ${dim}.. " | tee -a riopsMonthly.log
                ncks --mk_rec_dmn time ${arr[0]} /tmp/tmp${fname:0:6}${dim}.nc
                arr[0]=/tmp/tmp${fname:0:6}${dim}.nc
                ncra -o ${outDir}/${dim}/${fname:0:6}.nc ${arr[@]}
                echo "Done."
                rm /tmp/*.nc
                echo ''
            else
                echo "Files missing for ${fname:0:6} ${dim}" | tee -a riopsMonthly.log
                echo ''
            fi
        fi
    done
done