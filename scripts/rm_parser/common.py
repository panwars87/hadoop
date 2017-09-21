#
# A python script to keep all common variables and functions
#
# author: Shashant Panwar

import json
import requests
import socket
import os
import ConfigParser
import rm_logger

logger = rm_logger.logger

main_url = ''
base_url = ''
prod_domain = 'expressco.com'


''' Method to check if env. is prod or dev 
    return : Boolean True/False
'''
def is_prod():
    hname = socket.getfqdn()
    logger.debug('running on host & domain : ' + hname)
    if prod_domain in hname:
        return True
    else:
        return False

''' Get the mail url for app stats 
    return: Main api url --> http://cmhlddlkemst02.expdev.local:8088/ws/v1/cluster
    exception: ConnectionError
'''
def get_main_url():
    logger.debug('Executing get_main_url')
    global main_url
    try:

        if main_url != "":
            logger.debug('Found main_url in cache, returning that : {0}'.format(main_url))
            return main_url

        main_url = get_config('mst01_url')
        logger.debug('Main URL : {0}'.format(main_url))
        return main_url
    except requests.ConnectionError as ce:
        logger.error('connection exception while getting main url: {0}'.format(ce.message))
        raise ce

''' Get the base url for user query 
    return: Main api url --> http://cmhlddlkemst01.expdev.local:8088
    exception: ConnectionError
'''
def get_base_url():
    logger.debug('Executing get_base_url')
    global base_url
    try:

        if base_url != "":
            logger.debug('Found base_url in cache, returning that : {0}'.format(base_url))
            return base_url

        base_url = get_config('rm02_base_url')
        logger.debug('Base URL : {0}'.format(base_url))
        return base_url
    except requests.ConnectionError as ce:
        logger.error('connection exception while getting base url: {0}'.format(ce.message))
        raise ce

''' Make a common api request, to make a api call use this method
    param: request uri
    return: response data
    exception: ConnectionError
'''
def send_request(request_url):
    logger.debug('Executing send_request')
    try:
        r = requests.get(request_url, timeout=10)
        logger.debug('request complete successfully, returning response.')
        return r
    except requests.ConnectionError as ce:
        logger.error('Error while executing request for url : {0}'.format(request_url))
        raise ce


''' Return a json object from response data
    param: response
    return: json object of response data
    exception: Exception
'''
def get_response_data(response):
    logger.debug('Executing get_response_data')
    try:
        return json.loads(response.content)
    except Exception as e:
        logger.error('Exception while fetching response data from get_response_data -- {0}'.format(e.message))
        raise e


''' Helper method to remove ' from json string '''
def get_json_data(data):
    if data != "" or data is not None:
        j = json.dumps(data)
        jstring = j.replace("\'", "\\\"")
        logger.debug("escaped jstring : "+ jstring)
        return jstring
    else:
        return ''

''' Method to get properties from env config file
    param: key_name
    return: key_value
    exception: Exception
'''
def get_config(key_name):
    logger.debug('Executing get_config')
    try:
        if is_prod() is True:
            logger.debug('Running in prod env, fetching prod properties')
            prop_section = 'prod.rm'
        else:
            logger.debug('Running in dev env, fetching dev properties')
            prop_section = 'dev.rm'

        loc = os.path.dirname(os.path.realpath(__file__))
        config = read_config([loc+'/env-config.properties'])
        if config is None:
            raise Exception("No config found to fetch properties, Please check.")

        return config.get(prop_section, key_name)
    except Exception as e:
        logger.error('Exception while reading config properties')
        print e

''' Method which reads config and return property value
    param: cfg_file
    return: config
    exception: Exception
'''
# a simple function to read an array of configuration files into a config object
def read_config(cfg_files):
    logger.debug('Executing read_config')
    if cfg_files is not None:
        config = ConfigParser.RawConfigParser()

        # merges all files into a single config
        for i, cfg_file in enumerate(cfg_files):
            if os.path.exists(cfg_file):
                config.read(cfg_file)

        return config
