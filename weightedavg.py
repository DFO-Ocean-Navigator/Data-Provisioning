#!/usr/env python

import numpy
import xarray
import sys

import re
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


anchor = xarray.open_dataset(fileNames[0])
print(anchor['polar_stereographic'].values)



for i in range(1,4):
    anchor = anchor.merge(xarray.open_dataset(fileNames[i]))
print(anchor)
print(anchor['polar_stereographic'].values)
singleTest = xarray.open_dataset(fileNames[0])

dataFiles = xarray.open_mfdataset(fileNames, data_vars='minimal')
timeAttrs = dataFiles['time'].attrs
finalTime = dataFiles['time'].values[-1]


newData = dataFiles.isel({'time': 0})
print(newData)

for var in dataFiles.variables:
    if re.match(r"xc|yc|lat|lon|depth|time|pol", var) is None:
        print(var)
        #if var not in "yc xc latitude longitude depth time polar_stereographic":
        oldAttrs = dataFiles[var].attrs
        avgd = numpy.average(dataFiles[var], 0, weights=weights)
        newData[var] = xarray.DataArray(avgd, [dataFiles['yc'], dataFiles['xc']])
        newData[var].attrs = oldAttrs


newData = newData.expand_dims({'time': finalTime})

newData['time'].attrs = timeAttrs
print(newData)
newData.to_netcdf("output.nc")