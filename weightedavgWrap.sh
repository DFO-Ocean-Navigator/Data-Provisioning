#!/usr/bin/env bash

# list of directories that RIOPS files exist in, seperated by spaces
directories=''

logfile='weightedavgWrap.log'
outdir=''
dims='2D 3D'

# Create output dir if not already created
if [ ! -d ${outdir} ]
then
    mkdir $outdir
fi

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
                    echo "python weightedavg.py 3 ${file::-19} ${outdir} ${dim}" >> $logfile
                    python weightedavg.py 3 ${file::-19} ${outdir} ${dim} 2>> $logfile
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
                    echo "python weightedavg.py 6 ${file::-19} ${outdir} ${dim}" >> $logfile
                    python weightedavg.py 6 ${file::-19} ${outdir} ${dim} 2>> $logfile
                else
                    echo "ln -s ${file::-17}06*.nc ${outdir}/${dim}/" >> $logfile
                    ln -s ${file::-17}06*.nc ${outdir}/${dim}/ 2>> $logfile
                fi
            fi
        done
    done
done