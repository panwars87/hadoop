#!/bin/bash
#
#HDFS Audit log clean up script.

if [ `whoami` != "root" ]; then
    echo "Please run as root user."
    exit 1
fi

var_location="/var/log/"
hdfs_location="hadoop/hdfs"
archive="/tmp/system-logs/hdfs-audit"
host=`hostname -s`
keytab_principal="hdfs-CMHDDATALAKE@EXPDEV.LOCAL"
keytab="/etc/security/keytabs/hdfs.headless.keytab"
tdate=`date +"%Y-%m-%d"`

printf "Generating hdfs kinit \n"
kinit -kt $keytab $keytab_principal

cd $var_location$hdfs_location

if [ ! -d "$archive" ]; then
    mkdir -p /tmp/system-logs/hdfs-audit
fi

find . -type f -name "hdfs-audit*" -mtime +0 -exec mv "{}" $archive \;
if [ $? -ne 0 ]; then
	echo "ERROR moving files from hdfs logs to archive location. Please check"
	exit 1;
fi

cd $archive
file_count=`find . -type f | wc -l`

if [ $file_count -gt 0 ]; then
	count=0
	for file in `ls`
	do
		if [ "${file##*.}" != "gz" ] && [ -s $file ]; then
			 (( count++ ))
			 tar -zvcf $file-$host.gz $file
			 rm $file
    		fi
	done

	echo "Archive file count is : $count"
	hdfs dfs -put $archive/*.gz /system-logs/hdfs-audit/.

	if [ $? -ne 0 ]; then
		echo "ERROR while copying audit logs to hdfs.Please verify."
		exit 1;
	fi

	cd $archive
	echo "Deleting files:"
	for file in `ls`
	do
		echo "Deleting $file"
		rm $file
	done
else
	echo "Archive directory ($archive) is empty for $tdate"
fi
