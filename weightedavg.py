#!/usr/env python

import numpy
import xarray
import sys

# Required Arguments:
#  finalHour    int     Last file to be processed 
#  Run          str     Fully Qualified path up until run hour
#  outDir       str     Base output directory
#  dim          str     Dimmensions (2D or 3D)

if len(sys.argv) != 5:
    print("Too few or too many arguments")
    print("""

Required Arguments:
    finalHour    int     Last file to be processed 
    Run          str     Fully Qualified path up until run hour
    outDir       str     Base output directory
    dim          str     Dimmensions (2D or 3D)

            """)
    sys.exit()

finalHour = int(sys.argv[1])
run = sys.argv[2]
outDir = sys.argv[3]
dim = sys.argv[4]

weights = [1/6, 1/3, 1/3, 1/6]

fileNames = []
for i in range(finalHour - 3, finalHour + 1):
    fileNames.append(f"{run}_00{i}_{dim}_ps5km60N.nc")

dataFiles = xarray.open_mfdataset(fileNames)
finalTime = dataFiles['time'].values[-1]

newData = dataFiles.isel({'time': 0})

count = 0

for var in dataFiles.variables:
    if count > 5:
        avgd = numpy.average(dataFiles[var], 0, weights=weights)
        newData[var] = xarray.DataArray(avgd, [dataFiles['yc'], dataFiles['xc']])
    count += 1

newData = newData.expand_dims({'time': finalTime})
newData.to_netcdf("output.nc")