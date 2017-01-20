#!/bin/bash
#
#Script to automate kick of ambari service check
#

if [ `whoami` != "root" ]; then
    echo "Please run as root user";
    exit 1;
fi

if [ "$1" == "" ] || [ "$2" == "" ]; then
    echo "Usage : <script> <username> <password>"
    exit 1;
fi

uname=$1
pwd=$2
hostname=<hostname>
port="8080"
clustername=<clustername>

curl -ivk -H "X-Requested-By: ambari" -u $uname:$pwd -X POST -d @payload http://$hostname:$port/api/v1/clusters/$clustername/request_schedules
