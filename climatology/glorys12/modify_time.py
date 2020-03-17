# Script to modify the time variable for climatologies
# Nancy Soontiens March 2020

import datetime
import glob
import os
import subprocess

import netCDF4 as nc
import xarray as xr

months=[4,6,9,11]
for month in months:
    sd=datetime.datetime(1993,month,1)
    ed=datetime.datetime(2018,month,30)
    md=datetime.datetime(1993,month,16)
    f = glob.glob('monthly/*_{0:02d}_*.nc'.format(month))[0]
    print(f)
    d = nc.Dataset(f,mode='a')
    time = d.variables['time']
    time.long_name = 'Time (hours since 1993-01-01)'
    time.units='hours since 1993-01-01'
    time.climatology='climatology_bounds'
    #nv = d.createDimension('nv',2)
    #bounds = d.createVariable('climatology_bounds', 'f8',('time','nv'))
    bounds = d.variables['climatology_bounds']
    time[:] = nc.date2num(md, units=time.units)
    bounds.units='hours since 1993-01-01'
    bounds[0,:] = nc.date2num([sd, ed],units=time.units)

    d.close()
