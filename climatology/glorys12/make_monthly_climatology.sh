#!/bin/bash
# Script to make a climatology from GLORYS 1/12 monthly averages
# Nancy Soontiens March 2020

SRC_DIR=/data/cmems/GLOBAL_REANALYSIS_PHY_001_030/global-reanalysis-phy-001-030-monthly/
SAVE_DIR=/data/climatology/glorys12/monthly

mkdir -p $SAVE_DIR

syr=1993
eyr=2018

for month in {01..12}; do
    echo $month
    files=$SRC_DIR/*/*${month}.nc
    mkdir -p $SAVE_DIR/tmp${month}
    for f in $files; do
        basename=$(basename $f)
        year=$(basename $(dirname $f))
	if [ "${year}" == "${syr}" ]; then
	    echo "pre-processing $f"
	    ncks --mk_rec_dmn time $f $SAVE_DIR/tmp${month}/$basename
	else
	    ln -s $f $SAVE_DIR/tmp${month}/$basename
	fi
    done
    files=$SAVE_DIR/tmp${month}/*.nc
    echo $files
    outfile=$SAVE_DIR/mercatorglorys12v1_gl12_mean_${month}_${syr}01-${eyr}12.nc
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
# Delete files
echo "Deleting tmp files and directories"
cd $SAVE_DIR
for month in {01..12}; do
    rm -rf tmp${month}
done
