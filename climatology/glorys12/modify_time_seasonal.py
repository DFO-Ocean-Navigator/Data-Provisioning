# Script to modify the time variable for climatologies
# Nancy Soontiens March 2020

import datetime
import glob
import os
import subprocess

import netCDF4 as nc
import xarray as xr

SRC_DIR='/data/climatology/glorys12/seasonal'

files = {'DJF': {'smonth': 12,
                 'mmonth': 1,
                 'emonth': 2,
                 'eday': 28},
         'MAM': {'smonth': 3,
                 'mmonth': 4,
                 'emonth': 5,
                 'eday': 31},
         'JJA': {'smonth': 6,
                 'mmonth': 7,
                 'emonth': 8,
                 'eday': 31},
         'SON': {'smonth': 9,
                 'mmonth': 10,
                 'emonth': 11,
                 'eday': 30}}

eyear=2018
myear=1994
for k in files:
    if k == 'DJF':
        syear=1993
    else:
        syear=1994
    sd=datetime.datetime(syear,files[k]['smonth'],1)
    ed=datetime.datetime(eyear,files[k]['emonth'],files[k]['eday'])
    md=datetime.datetime(myear,files[k]['mmonth'],16)
    f = glob.glob(
        os.path.join(SRC_DIR,'*_{}_*.nc'.format(k)))[0]
    print(f)
    d = nc.Dataset(f,mode='a')
    time = d.variables['time']
    time.long_name = 'Time (hours since 1993-01-01)'
    time.units='hours since 1993-01-01'
    time.climatology='climatology_bounds'
    nv = d.createDimension('nv',2)
    bounds = d.createVariable('climatology_bounds', 'f8',('time','nv'))
    bounds = d.variables['climatology_bounds']
    time[:] = nc.date2num(md, units=time.units)
    bounds.units='hours since 1993-01-01'
    bounds[0,:] = nc.date2num([sd, ed],units=time.units)

    d.close()
