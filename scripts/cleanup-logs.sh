#!/bin/bash
#
#Common script to clean up logs

if [ `whoami` != "root" ]; then
    echo "Please run as root user."
    exit 1
fi

var_location="/var/log/"
echo "Log name /var/log/<name>, do not include /var/log/";
echo "Script is configured to handle only hst logs for now";
location=$1;
	if [ "$location" == "" ]; then
		echo "Usage : ./cleanup-log.sh <log dir name> Eg: ./cleanup-log.sh hst"
		exit 1;
	fi
archive="/tmp/system-logs/logs"
host=`hostname -s`

if [ ! -d "$archive" ]; then
    mkdir -p $archive
fi

cd $var_location$location

case "$location" in 
	"hst" ) echo "Working on HST logs"
		find . -type f -name "hst-*" -size +80M -exec mv "{}" $archive \;
		if [ $? -ne 0 ]; then
			echo "ERROR moving files from $location logs to archive location. Please check"
			exit 1;
		fi
	;;
	* ) printf "Usage : ./cleanup-log.sh <log dir name> Eg: ./cleanup-log.sh hst\n"
	    exit 1;
	;;
esac


cd $archive
file_count=`find . -type f | wc -l`
echo "Archive file count is : $file_count"
printf "File Archived are :\n`ls`\n"

if [ $file_count -gt 0 ]; then
	for file in `ls`
	do
    		if [ -s $file ]; then
        		#tar -zvcf ${file%.*}-$host.gz $file
			 tar -zvcf $file-$host.gz $file
    		fi
	done

	su - sa-custdatahub -c "hdfs dfs -put $archive/*.gz /system-logs/logs/."

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
	echo "Archive directory ($archive) is empty"
fi
