#
# Script to fetch resource manager application statistics data.
#
# author: Shashant Panwar
# Only define methods in these packages

import requests
import rm_logger
import common as capi

logger = rm_logger.logger


''' This method will create app statistics url based on state
    param: status : running, accepted, finished
    return: Complete app stats url
    exception: ConnectionException with return None 
'''
def get_appstats_urls(status):
    try:
        # raise exception if main url is None
        if capi.get_main_url() == "" or capi.get_main_url() is None: raise requests.ConnectionError
        if status == "accepted":
            return capi.get_main_url() + '/appstatistics?states=accepted'
        elif status == "running":
            return capi.get_main_url() + '/appstatistics?states=running'
        elif status == "finished":
            return capi.get_main_url() + '/appstatistics?states=finished'
        else:
            return None
    except requests.ConnectionException as ce:
        logger.error('Exception while getting app statistics url: {0}'.format(ce.message))
        raise ce


''' This method counts the no of jobs running in particular state
    param: response data
    return: count of jobs
    exception: base exception
'''
def get_state_counts(response):
    try:
        json_data_dump = capi.get_response_data(response)
        darr = json_data_dump['appStatInfo']['statItem']
        for key in darr:
            counts = key['count']
        return counts
    except Exception as e:
        logger.error('Exception while getting rm state counts : {0}'.format(e.message))


''' This method make the main request to fetch response from RM
    and call other methods to get counts.
    param: state : accepted, running, finished
    return: count of jobs
    exception: base exception
'''
def get_job_counts(user_param):
    try:
        state = user_param.lower()
        logger.debug('User param is : %s' % state)
        if get_appstats_urls(state) is not None:
            req_url = get_appstats_urls(state)
            logger.debug('Job url is %s' % req_url)
            response = capi.send_request(req_url)
            if response != "" and response.ok:
                return get_state_counts(response)
        else:
            logger.error('Something went wrong, app_stats url is empty.')
            raise Exception('Empty app_stats url')
    except Exception as e:
        logger.error('Exception from get_job_counts: {0}'.format(e.message))
