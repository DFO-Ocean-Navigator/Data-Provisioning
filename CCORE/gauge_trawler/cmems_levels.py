# -*- coding: ascii -*-
"""
<<DESCRIPTION OF SCRIPT>>
"""

__author__ = 'Gerard Noseworthy - LOOKNorth.'
__email__ = 'gerard.noseworthy@c-core.ca'


from gauge_trawler.utils import cfg
from os import system


def cmem_parser(start_date, end_date):
    """
    Parser for CMEM Data
    """
    arg_list = (
        'python {6}/motuclient.py',
        '--user "{0}"',
        '--pwd "{1}"',
        '--motu http://nrt.cmems-du.eu/motu-web/Motu',
        '--service-id SEALEVEL_GLO_PHY_L4_NRT_OBSERVATIONS_008_046-TDS',
        '--product-id dataset-duacs-nrt-global-merged-allsat-phy-l4',
         '--longitude-min -180',
         '--longitude-max 179.9166717529297', '--latitude-min -80', '--latitude-max 90',
        '--date-min "{3} 00:00:00"', '--date-max "{4} 23:59:59"',
         '--variable sla', '--variable adt', '--variable ugos', '--variable vgos', '--variable ugosa', '--variable vgosa', '--variable err',
        '--out-dir {2}', '--out-name {5}'
    )
    # comm = (
    #
    #     """
    #     python {6}/motuclient.py --user '{0}' --pwd '{1}' --motu http://nrt.cmems-du.eu/motu-web/Motu  --service-id GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS
    #     --product-id global-analysis-forecast-phy-001-024 --longitude-min -180 --longitude-max 179.9166717529297 --latitude-min -80 --latitude-max 90
    #     --date-min "{3} 00:00:00" --date-max "{4} 23:59:59"
    #     --variable thetao --variable bottomT --variable so --variable zos --variable uo --variable vo
    #     --variable mlotst --variable siconc --variable sithick --variable usi
    #     --variable vsi --out-dir {2} --out-name {5}
    #     """)
    comm = ' '.join(arg_list)
    user = cfg.get('SETTINGS', 'COPERNICUS_ACCT')
    pw = cfg.get('SETTINGS', 'COPERNICUS_PW')
    out_dir = cfg.get('SETTINGS', 'OUT_ROOT')
    motu = cfg.get('SETTINGS', 'MOTU_PATH')

    out_path = 'cmems_parse_{0}_{1}.nc'.format(start_date, end_date)

    system(comm.format(
        user, pw, out_dir, start_date, end_date, out_path, motu))
# End cmem_parser function

if __name__ == '__main__':
    cmem_parser('2019-01-01', '2019-01-31')
