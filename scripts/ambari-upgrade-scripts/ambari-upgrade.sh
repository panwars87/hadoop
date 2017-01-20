#!/bin/bash
#
# Assumptions:
# Running this script on Edge node 1.
# Running as a root user. 

env=$1;
val=$2;

if [ "$val" == "" ]; then
	echo "Usage: script-path/name <DEV>, <PROD>, <STRPROD> and <START>, <STOP> , <METRICS>, <DOWNLOAD>, <RPMCHECK>";
	echo "START : To start all ambari agents and ambari server";
	echo "STOP: To stop all ambari agents and ambari server";
	echo "METRICS: To upgrade ambari metrics for all agents and server, This should be use only at the time of upgrade and ambari server should be running. Ambari Web, browse to Services > Ambari Metrics select Service Actions then choose Stop";
	exit 1;
fi

if [ "$env" == "" ]; then
    echo "Usage: script-path/name <DEV>, <PROD>, <STRPROD> and <START>, <STOP> , <METRICS>, <DOWNLOAD>, <RPMCHECK>";
fi

echo "**********************************";
echo "Logging into cluster one at a time";
echo "**********************************";

if [ "${env^^}" == "DEV" ]; then
    nodearr=();    
elif [ "${env^^}" == "STRPROD" ]; then
    nodearr=();
elif [ "${env^^}" == "PROD" ]; then
    nodearr=();
fi

echo "Running script for listed node : ${nodearr[@]}";

domain=`hostname -d`;

for i in ${nodearr[@]}
do
	if [ "${val^^}" == "START" ]; then
		echo "Running start-ambari.sh for $i";
		ssh -q $i.$domain 'bash -s' < start-ambari.sh;
	elif [ "${val^^}" == "STOP" ]; then
		echo "Running stop-ambari.sh for $i";
		ssh -q $i.$domain 'bash -s' < stop-ambari.sh;
	elif [ "${val^^}" == "METRICS" ]; then
		echo "Running upgrade-metrics.sh for $i";
		ssh -q $i.$domain 'bash -s' < upgrade-metrics.sh;
	elif [ "${val^^}" == "DOWNLOAD" ]; then
        echo "Downloading latest ambari-repo for $i";
        ssh -q $i.$domain 'bash -s' < download-ambari-repo.sh;
	elif [ "${val^^}" == "RPMCHECK" ]; then
	    echo "Checking latest ambari-repo for $i";
	    ssh -q $i.$domain 'bash -s' < checking-ambari-upgrade.sh;
	fi
	echo "**********************************";
done;
