# -*- coding: ascii -*-
"""
<<DESCRIPTION OF SCRIPT>>
"""
import urllib.request as urlrequest
import netCDF4 as nc
from gauge_trawler.utils import cfg



__author__ = 'Gerard Noseworthy - LOOKNorth.'
__email__ = 'gerard.noseworthy@c-core.ca'

UCOMMA = '%2C'
AMP = '&'
URL_ROOT = (r'https://opendap.co-ops.nos.noaa.gov/erddap/tabledap' +
            '/IOOS_Hourly_Height_Verified_Water_Level.nc?'
            )
OUT_VARS = UCOMMA.join(('STATION_ID', 'DATUM', 'BEGIN_DATE','END_DATE','WL_VALUE', 'time'))

#TODO: GET NOAA STATION IDS, we can request monthyl very easily...
#TODO: FIX the DATETIME CALCULATION...

def noa_tides(output_location, start_date, end_date):
    """
    NOA GET REQUEST
    see https://opendap.co-ops.nos.noaa.gov/erddap/tabledap/IOOS_Hourly_Height_Verified_Water_Level.html
    for valid values
    """
    station_id = '8423898'
    start_month = '01'
    start_year = '2019'
    end_month = '04'
    end_year =  '2019'
    datum = 'MLLW'




    start_date_param = 'BEGIN_DATE%3E=%22{0}{1}01%22'.format(start_year, start_month)
    end_date_param = 'END_DATE%3C=%22{0}{1}01%22'.format(end_year, end_month)
    station_id_param = 'STATION_ID=%22{0}%22'.format(station_id)
    datum_param = 'DATUM=%22MLLW%22'
    params = AMP.join((OUT_VARS, station_id_param, datum_param, start_date_param, end_date_param))
    url = URL_ROOT + params
    print(url)
    url_breakdown = (
        """
        https://opendap.co-ops.nos.noaa.gov/erddap/tabledap/IOOS_Hourly_Height_Verified_Water_Level.nc?
            STATION_ID%2C
            DATUM%2C
            BEGIN_DATE%2C
            END_DATE%2C
            WL_VALUE&STATION_ID=%228423898%22&
            DATUM=%22MLLW%22&
            BEGIN_DATE%3E=%2220170101%2012%3A00%22&
            END_DATE%3C=%2220170201%2012%3A00%22&
            time%3E=2017-02-26T00%3A00%3A00Z&orderBy(%22STATION_ID%22)
        
        """
    )

    result = "{0}/test{1}{2}.nc".format(output_location, end_month, end_year)
    urlrequest.urlretrieve(url, result)

# End noa_tides function

if __name__ == '__main__':
    out_loc = cfg.get('SETTINGS', 'OUT_ROOT')

    noa_tides(out_loc, 1, 1)
