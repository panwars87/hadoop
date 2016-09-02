#!/bin/bash
#
#Script to check Active namenode in HA enable cluster
#

if [ `whoami` != root ]; then
    echo "Please execute as root user."
    exit 1
fi

##Code to get ticket
##Only for Kerberos env....
khost=`klist -k /etc/security/keytabs/hdfs.headless.keytab | tail -n1 | grep -oE '[^ $]+$'`
kinit -kt /etc/security/keytabs/hdfs.headless.keytab $khost

clustername=`hdfs getconf -confKey dfs.nameservices`;
if [ "$clustername" == "" ]; then
    echo "No clustername found, seems like you are running the script in non-HA cluster";
    exit 1;
fi
echo "Cluster name: $clustername";

namenodes=`hdfs getconf -confKey dfs.ha.namenodes.$clustername`;
echo "Active name nodes are: $namenodes";
nnArr=`echo $namenodes | tr ',' ' '`;

for i in $nnArr
do
    status=`hdfs haadmin -getServiceState $i`;
    echo "NN-Status for $i is $status";
    if [ $status == "active" ]; then
        nnhost=`hdfs getconf -confKey dfs.namenode.rpc-address.$clustername.$i`;
        echo "hostname : $nnhost";
        break;
        fi
done
