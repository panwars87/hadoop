#!/bin/bash
#

host=`hostname`;
nodetype=`chkconfig | tr ' ' '\n' | grep 'ambari'`
typearr=($nodetype)

for i in ${typearr[@]}
do
   	if [[ "$i" == *"server"* ]]; then
       	rpm -qa | grep $i;
    else
       	rpm -qa | grep $i;
	fi
done;
