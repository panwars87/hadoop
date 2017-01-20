#!/bin/bash
#
# Script require to run before Ambari & HDP upgrade to check disk space on each node of the cluser.

env=$1;

if [ "$env" == "" ]; then
   echo "Usage: script-path/name <DEV>, <PROD>, <STRPROD>";
   exit 1;
fi

echo "**********************************";
echo "Logging into cluster one at a time";
echo "**********************************";

if [ "${env^^}" == "DEV" ]; then
    nodearr=();
    #nodearr=(cmhlddlkedat07);
elif [ "${env^^}" == "STRPROD" ]; then
    nodearr=();
elif [ "${env^^}" == "PROD" ]; then
    nodearr=();
fi

domain=`hostname -d`;

for i in ${nodearr[@]}
do
	echo "Reading /usr/hdp/ space from $i";
        ssh -q -t $i.$domain 'df -h /usr/hdp/;';
        echo "**********************************";
done;
