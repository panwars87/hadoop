#!/bin/bash
#

host=`hostname`;

nodetype=`chkconfig | tr ' ' '\n' | grep 'ambari'`
typearr=($nodetype)

for i in ${typearr[@]}
do
	echo "Starting $i on $host";
	$i start;
done;
