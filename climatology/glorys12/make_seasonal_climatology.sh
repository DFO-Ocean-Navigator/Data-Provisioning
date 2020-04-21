#!/bin/bash
# Script to make a climatology from GLORYS 1/12 monthly averages
# Nancy Soontiens March 2020

SRC_DIR=/data/cmems/GLOBAL_REANALYSIS_PHY_001_030/global-reanalysis-phy-001-030-monthly/
SAVE_DIR=/data/climatology/glorys12/seasonal

mkdir -p $SAVE_DIR

for month in {01..12}; do
    # For a proper seasonal clim, Dec comes from year before
    if [ "${month}" == "12" ]; then
        syr=1993
	eyr=2017
    else
        syr=1994
	eyr=2018
    fi
    echo $month
    files=$SRC_DIR/*/*${month}.nc
    mkdir -p $SAVE_DIR/month/tmp${month}
    for f in $files; do
        basename=$(basename $f)
        year=$(basename $(dirname $f))
	if [ "${year}" == "${syr}" ]; then
	    echo "pre-processing $f"
	    ncks --mk_rec_dmn time $f $SAVE_DIR/month/tmp${month}/$basename
	else
	    if [ "${year}" -ge "${syr}" ] && [ "${year}" -le "${eyr}" ]; then
	        ln -s $f $SAVE_DIR/month/tmp${month}/$basename
	    fi
	fi
    done
    files=$SAVE_DIR/month/tmp${month}/*.nc
    echo $files
    outfile=$SAVE_DIR/month/mercatorglorys12v1_gl12_mean_${month}_${syr}01-${eyr}12.nc
    # Special treatment for February - leap years have more days
    if [ "${month}" == "02" ]; then
	febweights=""
	for year in $(seq ${syr} ${eyr}); do
	    date -d $year-02-29 &> /dev/null && neweight=29 || neweight=28
	    febweights=${febweights},$neweight
	done
	febweights="${febweights:1}"
        ncra --cb -w $febweights $files $outfile
    else
        ncra --cb $files $outfile
    fi
done
# Now create seasonals
cd $SAVE_DIR
# DJF
outfile=mercatorglorys12v1_gl12_mean_DJF_1994-2018.nc
ncra --cb -w 31,31,28 month/mercatorglorys12v1_gl12_mean_12_199301-201712.nc \
    month/mercatorglorys12v1_gl12_mean_01_199401-201812.nc \
    month/mercatorglorys12v1_gl12_mean_02_199401-201812.nc \
    $outfile
# MAM
outfile=mercatorglorys12v1_gl12_mean_MAM_1994-2018.nc
ncra --cb -w 31,30,31 month/mercatorglorys12v1_gl12_mean_03_199401-201812.nc \
    month/mercatorglorys12v1_gl12_mean_04_199401-201812.nc \
    month/mercatorglorys12v1_gl12_mean_05_199401-201812.nc \
    $outfile
# JJA
outfile=mercatorglorys12v1_gl12_mean_JJA_1994-2018.nc
ncra --cb -w 30,31,31 month/mercatorglorys12v1_gl12_mean_06_199401-201812.nc \
    month/mercatorglorys12v1_gl12_mean_07_199401-201812.nc \
    month/mercatorglorys12v1_gl12_mean_08_199401-201812.nc \
    $outfile
# SON
outfile=mercatorglorys12v1_gl12_mean_SON_1994-2018.nc
ncra --cb -w 30,31,30 month/mercatorglorys12v1_gl12_mean_09_199401-201812.nc \
    month/mercatorglorys12v1_gl12_mean_10_199401-201812.nc \
    month/mercatorglorys12v1_gl12_mean_11_199401-201812.nc \
    $outfile
 
# Delete files
echo "Deleting tmp files and directories"
rm -rf month/*
