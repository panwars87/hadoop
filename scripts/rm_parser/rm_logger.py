# A custom logger for rm parser, Please do not change this file.
# override rm_parser.set_logger to define log level for your app
#
# Shashant Panwar
#

import logging

# create logger
logger = logging.getLogger('rm-parser')

logger.setLevel(logging.INFO)

# create console handlers and set level to debug
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)

# create formatter
formatter = logging.Formatter('%(asctime)s - %(filename)s:%(lineno)s - %(funcName)s() - %(levelname)s - %(message)s')

# add formatter to ch
ch.setFormatter(formatter)

# add ch to logger
logger.addHandler(ch)
