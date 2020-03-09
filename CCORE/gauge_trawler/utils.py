# -*- coding: ascii -*-
"""
<<DESCRIPTION OF SCRIPT>>
"""
from os.path import join, dirname
from configparser import ConfigParser
import timeit
import logging


__author__ = 'Gerard Noseworthy - LOOKNorth.'
__email__ = 'gerard.noseworthy@c-core.ca'


cfg = ConfigParser()
cfg.read(join(dirname(__file__), 'settings.ini'))

COMMA = ','

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)

def timer(function):
    """
    Log function process time
    :param function:
    :return:
    """
    def function_wrapper(*args, **kwargs):
        log.info(f"Beginning '{function.__name__}'")
        start_time = timeit.default_timer()
        result = function(*args, **kwargs)
        elapsed = timeit.default_timer() - start_time
        log.info(f"Function '{function.__name__}' took {elapsed} seconds to complete.")

        return result
    return function_wrapper


if __name__ == '__main__':
    pass
