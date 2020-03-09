# -*- coding: ascii -*-
"""
<<DESCRIPTION OF SCRIPT>>
"""

__author__ = 'Gerard Noseworthy - LOOKNorth.'
__email__ = 'gerard.noseworthy@c-core.ca'


from datetime import datetime
from os.path import join
from netCDF4 import Dataset, date2num
from suds import Client
from gauge_trawler.utils import COMMA, cfg, timer


@timer
def monthly_tide_pooler(year=None, month=None, interval=12):
    """
    Request gc tidal data from CHS tidal webservice soap
    """
    today = datetime.now()
    if not year:
        year = today.year
    if not month:
        month = today.month-1

    out_dir = cfg.get('SETTINGS', 'OUT_ROOT')
    url = "https://ws-shc.qc.dfo-mpo.gc.ca/observations?wsdl"
    sc = Client(url)
    stations = sc.service.getMetadata()[0].value.split(COMMA)

    for station_id in stations:
        print(station_id)
        rootgrp = Dataset(
            join(out_dir, '{0}.nc'.format(station_id)),
            'w', format='NETCDF4')
        rootgrp.createDimension('time')
        rootgrp.createVariable("time", "f8", ("time",))
        height = rootgrp.createVariable('height', 'f4', ('time',))
        for day in range(1, 32):

            for hour in range(0, 24, interval):
                #note hour by hour result:
                start_time = r"{0}-{1}-{2} 00:00:00".format(year, str(month).zfill(2), str(day).zfill(2))

                endtime = r"{0}-{1}-{2} {3}:59:59".format(year, str(month).zfill(2),str(day).zfill(2), str(hour+interval-1).zfill(2))

                res = sc.service.search("wl", -90.0,  90.0, -180.0,  180.0,  0.0, 0.0, start_time , endtime,  1,  10000,  True ,"station_id={0}".format(station_id), "desc")
                if not res.data:
                    continue
                print(day)

                for sample in reversed(res.data):

                    if sample.boundaryDate.max.endswith('00:00'):

                        timestamp = datetime.strptime(sample.boundaryDate.max,'%Y-%m-%d %H:%M:%S')

                        height[date2num(timestamp, "hours since 0001-01-01 00:00:00.0")] = float(sample.value)
        rootgrp.close()
# End tidal_pooler


if __name__ == '__main__':
    monthly_tide_pooler(month=3)
