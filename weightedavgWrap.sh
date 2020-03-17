#!/usr/bin/env bash

# list of directories that RIOPS files exist in, seperated by spaces
directories=''

workingDir=''
logfile='weightedavgWrap.log'
outdir=''
dims='2D 3D'


# Create output dir if not already created
if [ ! -d ${outdir} ]
then
    mkdir $outdir
fi

# Normalize data by creating 3h averages
for dim in $dims ; do
    # Create subfolder for 2D / 3D
    if [ ! -d ${outdir}/${dim}/ ]
    then
        mkdir ${outdir}/${dim}/
    fi

    # run though all files in listed directories
    for direc in $directories ; do
        allFiles=`find ${direc} -type f -name "*${dim}_ps5km60N.nc"`
        for file in $allFiles ; do
            name=`filename ${file}`
            run=${name::-19}

            # make folder for month
            if [ ! -d ${outdir}/${dim}/${run::-4} ]
            then
                mkdir ${outdir}/${dim}/${run::-4}
            fi

            # check if 3rd hour output already ..
            if [ ! -e ${outdir}/${dim}/${run::-4}/${run}_003_${dim}_ps5km60N.nc ]
            then

                # Generate average or create symbolic link to average
                if [ -e ${file::-17}02_${dim}_ps5km60N.nc ]
                then
                    ncks --mk_rec_dmn time ${run}_000_${dim}_ps5km60N.nc /tmp/tmp${run}.nc
                    ncra -w 0.5,1,1,0.5 ${workingDir}/tmp${run}.nc ${run}_001_${dim}_ps5km60N.nc ${run}_002_${dim}_ps5km60N.nc ${run}_003_${dim}_ps5km60N.nc ${outdir}/${run}_003_${dim}_ps5km60N
                    rm /tmp/*.nc
                else
                    echo "ln -s ${file::-17}03*.nc ${outdir}/${dim}/${run::-4}/" >> $logfile
                    ln -s ${file::-17}03*.nc ${outdir}/${dim}/${run::-4}/ 2>> $logfile
                fi
            fi

            # check if 6th hour output already ..
            if [ ! -e ${outdir}/${dim}/${run::-4}/${run}_006_${dim}_ps5km60N.nc ]
            then

                # Generate average or create symbolic link to average
                if [ -e ${file::-17}05_${dim}_ps5km60N.nc ]
                then
                    ncks --mk_rec_dmn time ${run}_003_${dim}_ps5km60N.nc /tmp/tmp${run}.nc
                    ncra -w 0.5,1,1,0.5 ${workingDir}/tmp${run}.nc ${run}_004_${dim}_ps5km60N.nc ${run}_005_${dim}_ps5km60N.nc ${run}_006_${dim}_ps5km60N.nc ${outdir}/${run}_006_${dim}_ps5km60N
                    rm /tmp/*.nc
                else
                    echo "ln -s ${file::-17}06*.nc ${outdir}/${dim}/" >> $logfile
                    ln -s ${file::-17}06*.nc ${outdir}/${dim}/ 2>> $logfile
                fi
            fi
        done
    done
done

# Generate monthly averages
days="31 28 31 30 31 30 31 31 30 31 30 31"
daysleap="31 29 31 30 31 30 31 31 30 31 30 31"
monthDir=''

if [ ! -d ${monthDir} ]
then
    mkdir $monthDir
fi

for dim in $dims ; do
    # Create subdirs if non-existing
    if [ ! -d ${monthDir}/${dim}/ ]
    then
        mkdir ${monthDir}/${dim}/
    fi

    allFiles=`find ${outdir} -type f -name "*${dim}_ps5km60N.nc"`
    for file in $allFiles ; do
        fname=`filename $file`

        # index for month starting at 0
        month=$((${fname:4:2} - 1))
        year=${fname:0:4}
        
        if [ ! -e ${monthDir}/${dim}/${fname::-21}.nc ]
        then
            # leapYear check
            date -d $year-02-29 &>/dev/null && monthDays=$daysleap || monthDays=$days
            thisMonth=`find ${outdir} -type f -name "${fname::-21}*_${dim}_ps5km60N.nc"`
            if [[ $(( monthDays[${month}] * 8 )) == ${#thisMonth[@]} ]] ; then
                ncra $thisMonth ${monthDir}/${dim}/${fname:0:6}.nc
            fi
        fi
    done
done
