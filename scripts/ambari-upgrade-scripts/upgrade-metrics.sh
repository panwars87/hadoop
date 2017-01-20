#!/bin/bash
#
#Only need to upgrade Metrics Collector and Grafana's hostname
#
host=`hostname -s`
server_name=<hostname of the server where metrice collector and grafana are running. It is a good practise to run collector and grafana on sam machine to avoid network latency>

yum clean all

if [ "$host" == "$server_name" ]; then
	echo "On node $host, Running Metrics collector and Grafana upgrade";
	yum -y upgrade ambari-metrics-collector
	yum -y upgrade ambari-metrics-grafana
fi

yum -y upgrade ambari-metrics-monitor ambari-metrics-hadoop-sink

