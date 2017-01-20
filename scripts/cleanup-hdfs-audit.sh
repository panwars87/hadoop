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

        su - <user-name> -c "hdfs dfs -put $archive/*.gz /system-logs/hdfs-audit/."

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
