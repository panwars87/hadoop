#!/bin/bash/
#
#Script to download amabri repo in yum.repos.d folder.
#Before running ./ambari-upgrade.sh DOWNLOAD - please update repo-url in this script.

repo_url="http://public-repo-1.hortonworks.com/ambari/centos6/2.x/updates/2.4.2.0/ambari.repo";
repo_name="ambari.repo";
today_date=`date +%m-%d`;
repo_yum="/etc/yum.repos.d/ambari.repo";

host=`hostname`;

echo "Downloading repo from url : $repo_url";

if [ -f "$repo_yum" ]; then 
    echo "Repo already exists, Backing up repo";
    mv $repo_yum $repo_yum.bak.$today_date;
    if [ $? != 0 ]; then
        echo "Error while backing up current repo";
        exit 1;
    else
        wget -nv $repo_url -O $repo_yum;
        yum clean all;
    fi
fi

