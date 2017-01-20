#!/bin/bash
#

host=`hostname`;

nodetype=`chkconfig | tr ' ' '\n' | grep 'ambari'`
typearr=($nodetype)

for i in ${typearr[@]}
do
	echo "Stoping $i on $host";
	$i stop;
done;
