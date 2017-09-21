#
# A python script to fetch resource manager user jobs
#
# author: Shashant Panwar
# Only define methods in these packages

import json
import rm_logger
import app_stats as stats_api
import user_jobs as jobs_api

logger = rm_logger.logger


# Application statistics functions
def get_accepted_job_counts():
    logger.debug('Call app_stats api --> get_job_counts with param : accepted')
    return stats_api.get_job_counts("accepted")


def get_running_job_counts():
    logger.debug('Call app_stats api --> get_job_counts with param : running')
    return stats_api.get_job_counts("running")


def get_finish_job_counts():
    logger.debug('Call app_stats api --> get_job_counts with param : finished')
    return stats_api.get_job_counts("finished")


# User jobs details based on queue and states
def get_marketing_user_jobs():
    logger.debug('Call user_jobs api --> get_jobs_by_queue with param : running, marketing')
    return jobs_api.get_jobs_by_queue("running", "marketing")


def get_edw_user_jobs():
    logger.debug('Call user_jobs api --> get_jobs_by_queue with param : running, edw')
    return jobs_api.get_jobs_by_queue("running", "edw")


def get_cdh_user_jobs():
    logger.debug('Call user_jobs api --> get_jobs_by_queue with param : running, batchqueue')
    return jobs_api.get_jobs_by_queue("running", "batchqueue")


def set_logger(log_level):
    logger.setLevel(log_level.upper())


def main():
    logger.debug("Starting RM Parser main")
    set_logger("debug")

    cdh_data = get_marketing_user_jobs()
    logger.info('Data is : {0}'.format(cdh_data))


# Running Main
if __name__ == "__main__":
    main()