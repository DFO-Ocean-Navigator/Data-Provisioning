# Script to make a climatology from GLORYS 1/12 monthly averages
# Nancy Soontiens March 2020

SRC_DIR=/tank/data/cmems/GLOBAL_REANALYSIS_PHY_001_030/global-reanalysis-phy-001-030-monthly/
SAVE_DIR=/tank/data/climatology/glorys12/monthly

mkdir -p $SAVE_DIR

for month in {01..12}; do
    echo $month
    files=$SRC_DIR/*/*${month}.nc
    mkdir -p $SAVE_DIR/tmp${month}
    for f in $files; do
        basename=$(basename $f)
        ncks --mk_rec_dmn time $f $SAVE_DIR/tmp${month}/$basename
    done
    files=$SAVE_DIR/tmp${month}/*.nc
    echo $files
    outfile=$SAVE_DIR/mercatorglorys12v1_gl12_mean_${month}_1993-2018.nc
    ncra --cb  $files $outfile
done

