#
# A python script to fetch resource manager user jobs
#
# author: Shashant Panwar
# Only define methods in these packages

import rm_logger
import traceback
import requests
import common as capi
from bs4 import BeautifulSoup

logger = rm_logger.logger

''' Main method which will check for jobs and get their details
    param: state and queue name
    return: a list of json object with job details
    exception: Exception
'''
def get_jobs_by_queue(state, queue):
    logger.debug('Executing get_jobs_by_queue with params : {0} & {1}'.format(state, queue))
    try:
        req_url = get_jobs_by_all(state, '', queue)
        logger.debug('Job url is %s' % req_url)
        response = capi.send_request(req_url)
        if response != "" and response.ok:
            data = get_job_details(response)
            if data is None or not data:
                logger.debug('Looks like no job is running for state: {0}, queue: {1}'.format(state, queue))
                return None
            else:
                return capi.get_json_data(data)
        else:
            logger.error('Something went wrong, unable to fetch jobs for queue : {0}'.format(queue))
    except Exception as e:
        logger.error('Exception from get_jobs_by_queue: {0}'.format(e.message))
        tb = traceback.format_exc()
        logger.error('error trace: %s ' % tb)
        raise e


''' Method to get custom urls based on user_name or queue. 
    param: state ,user_name and queue name
    return: url
    exception: Exception
'''
def get_jobs_by_all(state, user_name, queue):
    logger.debug('Executing get_jobs_by_all with params : {0} , {1} & {2}'.format(state, user_name, queue))
    try:
        url = capi.get_main_url()
        if url == '':
            raise requests.ConnectionError('Empty main resource manager url')
        else:
            url = url + '/apps?states=' + state
            if user_name != "":
                url = url + '&user=' + user_name
            if queue != '':
                url = url + '&queue=' + queue
            return url
    except requests.ConnectionError as ce:
        logger.error('Exception from get_jobs_by_all method: {0}'.format(ce.message))
        raise ce


''' Method takes response object and parse necessary details and build the output data list
    This method will only return jobs running more than 60 mins(configure in env properties)
    param: response data
    return: a list of json object with job details
    exception: Exception, return: None
'''
def get_job_details(response):
    logger.debug('Executing get_job_details')
    try:
        json_data_dump = capi.get_response_data(response)
        if json_data_dump['apps'] is None: return None
        data_arr = json_data_dump['apps']['app']
        job_count = 0
        data_list = list()
        for key in data_arr:
            logger.debug('complete application response %s:  ' % key)
            if key.get('elapsedTime') > int(capi.get_config('check_interval')):
                logger.debug('A query is running more than an hour, fetching info. Elapsed time: {0}'.format(key.get('elapsedTime')))
                job_count += 1
                user_query = get_user_query(key.get('trackingUrl', ''))
                if user_query == '' or user_query is None:
                    user_query = key['name']
                
                data = {"appId": key['id'], "allocatedMB": key['allocatedMB'], "user": key['user'], "jobCounts": job_count,
                        "trackingUrl": key['trackingUrl'], "startedTime": key['startedTime'], "userQuery": user_query,
                        "elapsedTime": key['elapsedTime']};
                data_list.append(data)
        return data_list
    except Exception as e:
        logger.error('Exception from get_job_details'.format(e.message))
        raise e

''' Method to fetch job query
    This is little convoluted but only way I can find to parse query from job tracker
    Step1: This methods make call to job_tracker and look for config, line: 113
    Step2: Again make a call to config to fetch config details, line: 119
    Step3: Parse the config using BeautifulSoup and get the query using 'hive.query.string'
    param: job tracker url
    return: user_query
    exception: Exception, return: None
'''
def get_user_query(job_tracker_url):
    logger.debug('Executing get_user_query with params : {0}'.format(job_tracker_url))
    try:
        user_query = None
        if job_tracker_url == '':
            return user_query
        else:
            jtr = requests.get(job_tracker_url)
            jtr_content = BeautifulSoup(jtr.text, 'html.parser')
            for jtr_link in jtr_content.find_all('a'):
                l = str(jtr_link.get('href'))
                if l.__contains__('job'):
                    nl = l.replace('/job/', '/conf/')
                    conf_url = capi.get_base_url()+nl
                    logger.debug('pulling job configs from hdfs-conf link : {0}'.format(conf_url))
                    jr = requests.get(conf_url)
                    sp = BeautifulSoup(jr.text, "html.parser")
                    all_td = sp.find('td', {"class": "content"}).find_all('td')
                    logger.debug('td array length from hdfs configs : {0}'.format(len(all_td)))
                    for td in all_td:
                        s = td.get_text()
                        if s.strip() == "hive.query.string":
                            user_query = td.findNextSibling().get_text().replace('\n',' ')
                            logger.debug('Found user query from job tracker : {0}'.format(user_query))
                            return user_query
    except requests.ConnectionError as ce:
        logger.error('Connection exception from get_user_query, Error is: {0}'.format(ce.message))
        raise ce
    except Exception as e:
        logger.error('Exception from get_user_query, Error is: {0}'.format(e.message))
        raise e
