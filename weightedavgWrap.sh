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
                    # Create record dimension (required for ncra)
                    echo "ncks on ${direc}/${run}_000_${dim}_ps5km60N.nc" >> $logfile
                    ncks --mk_rec_dmn time ${direc}/${run}_000_${dim}_ps5km60N.nc /tmp/tmp${run}.nc 2>> $logfile

                    # Run weighted average
                    echo "ncra on /tmp/tmp${run}.nc ${direc}/${run}_001_${dim}_ps5km60N.nc ${direc}/${run}_002_${dim}_ps5km60N.nc ${direc}/${run}_003_${dim}_ps5km60N.nc" >> $logfile
                    ncra -w 0.5,1,1,0.5 -o ${outdir}/${dim}/${run::-4}/${run}_003_${dim}_ps5km60N.nc /tmp/tmp${run}.nc ${direc}/${run}_001_${dim}_ps5km60N.nc ${direc}/${run}_002_${dim}_ps5km60N.nc ${direc}/${run}_003_${dim}_ps5km60N.nc 2>> $logfile
                    rm /tmp/*.nc

                    # Set time value to last timestamp in average
                    echo "Fixing time on ${outdir}/${dim}/${run::-4}/${run}_003_${dim}_ps5km60N.nc" >> $logfile
                    ncrename -v time,time_old  ${outdir}/${dim}/${run::-4}/${run}_003_${dim}_ps5km60N.nc 2>> $logfile
                    ncks -A -v time ${direc}/${run}_003_${dim}_ps5km60N.nc  ${outdir}/${dim}/${run::-4}/${run}_003_${dim}_ps5km60N.nc 2>> $logfile
                    ncks -O -x -v 'time_old' ${outdir}/${dim}/${run::-4}/${run}_003_${dim}_ps5km60N.nc ${outdir}/${dim}/${run::-4}/${run}_003_${dim}_ps5km60N.nc 2>> $logfile
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
                    # Create record dimension (required for ncra)
                    echo "ncks on ${direc}/${run}_003_${dim}_ps5km60N.nc" >> $logfile
                    ncks --mk_rec_dmn time ${direc}/${run}_003_${dim}_ps5km60N.nc /tmp/tmp${run}.nc

                    # Run weighted average
                    echo "ncra on /tmp/tmp${run}.nc ${direc}/${run}_004_${dim}_ps5km60N.nc ${direc}/${run}_005_${dim}_ps5km60N.nc ${direc}/${run}_006_${dim}_ps5km60N.nc" >> $logfile
                    ncra -w 0.5,1,1,0.5 -o ${outdir}/${dim}/${run::-4}/${run}_006_${dim}_ps5km60N.nc /tmp/tmp${run}.nc ${direc}/${run}_004_${dim}_ps5km60N.nc ${direc}/${run}_005_${dim}_ps5km60N.nc ${direc}/${run}_006_${dim}_ps5km60N.nc 
                    rm /tmp/*.nc

                    # Set time value to last timestamp in average
                    ncrename -v time,time_old  ${outdir}/${dim}/${run::-4}/${run}_006_${dim}_ps5km60N.nc 2>> $logfile
                    ncks -A -v time ${direc}/${run}_006_${dim}_ps5km60N.nc  ${outdir}/${dim}/${run::-4}/${run}_006_${dim}_ps5km60N.nc 2>> $logfile
                    ncks -O -x -v 'time_old' ${outdir}/${dim}/${run::-4}/${run}_006_${dim}_ps5km60N.nc ${outdir}/${dim}/${run::-4}/${run}_003_${dim}_ps5km60N.nc 2>> $logfile
                else
                    echo "ln -s ${file::-17}06*.nc ${outdir}/${dim}/" >> $logfile
                    ln -s ${file::-17}06*.nc ${outdir}/${dim}/ 2>> $logfile
                fi
            fi
        done
        echo "" >> $logfile
    done
done
