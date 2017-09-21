#!/bin/bash
# Reference: https://github.com/karthikhw/ambari/blob/master/bin/compare.sh
# author: Shashant Panwar
# Todo: Store the comparision in another file along with storing the configs.
#

usage () {
  echo "Usage: script-name <ambari-userId> <ambari-password> <ambari_host> <ambari_port> <cluster_name> <is_ambari_secure (y/n)>;"
  echo "";
  echo "       <ambari-userId>: Ambari user id. Default is 'admin'.";
  echo "       <ambari-password>: Ambari password. This is a required field.";
  echo "       <ambari_host>: Server external host name";
  echo "       <ambari_port>: Optional port number for Ambari server. Default is '8080'. Provide empty string to not use port.";
  echo "       <cluster_name>: Name given to cluster. Ex: 'CMHDDATALAKE'"
  echo "       <is_ambari_secure>: Is ambari secure (y/n). This is to make sure whether to user http or https.";
  exit 1;
}


if [ $# != 6 ]; then
    usage
    exit 1
fi

user_id="$1"
password="$2"
host="$3"
port="$4"
cluster_name="$5"
is_secure="$6"

GREEN='\033[0;32m'
ORANGE='\033[38;5;166m'
YELLOW='\033[0;93m'
RED='\033[0;31m'
NC='\033[0m' # No Color

time=`date +%FT%H%M%S`
script_home="/hadoop/tools/scripts/cluster-compare"
script_data_dir="$script_home/data/$cluster_name"
mkdir -p "$script_data_dir"
cluster_service_file="$script_data_dir/$cluster_name.txt"

# removing files if already exists
if [ -f "$cluster_service_file" ]; then
    echo -e "${YELLOW} Removing old file : $cluster_service_file"
    rm -f "$cluster_service_file"
fi

echo -e "${GREEN}Getting cluster services ${NC}"
echo -e "${GREEN} URL: https://$host:$port/api/v1/clusters/$cluster_name?fields=Clusters/desired_configs, uname: $user_id, pwd: $password"
if [ "${is_secure,,}" == "y" ]; then
    curl -k -s -S -u $user_id:$password "https://$host:$port/api/v1/clusters/$cluster_name?fields=Clusters/desired_configs" > $cluster_service_file
else
    curl -k -s -S -u $user_id:$password "http://$host:$port/api/v1/clusters/$cluster_name?fields=Clusters/desired_configs" > $cluster_service_file
fi

returncode=$?
isfail=`cat $cluster_service_file | wc -l`

if [ $returncode != 0 ];then
    echo -e "${RED}Failed to download component list from $hostname ${NC}"
    exit 1
elif [ "$isfail" -le 5 ];then
    echo -e "${RED}Unable to download cluster config.Please check logfile under $_staging/cluster-service${NC}"
    exit 1
fi

## get the configs for each service
echo -e "${GREEN}\nDownloading component configuration for $host:$port/api/v1/clusters/$cluster_name .. ${NC}\n"
for i in `cat  $cluster_service_file | grep -i tag -B1 | grep "{" | awk  '{print $1}' | sed -e 's/^"//'  -e 's/"$//'`
do
    cluster_name_components_configs="$script_data_dir/$cluster_name-$i.txt"
    if [ -f "$cluster_name_components_configs" ]; then
        echo -e "${YELLOW} Removing old file : $cluster_name_components_configs"
        rm -f "$cluster_name_components_configs"
    fi
    echo -e "${GREEN} Generating config file for : $i"
    if [ "${is_secure,,}" == "y" ]; then
        /var/lib/ambari-server/resources/scripts/configs.sh -u $user_id -p $password -port $port -s get $host $cluster_name $i | egrep -iv "USERID|PASSWORD" > $cluster_name_components_configs
        returncode=`echo $?`
    else
        /var/lib/ambari-server/resources/scripts/configs.sh -u $user_id -p $password get $host $cluster_name $i | egrep -iv "USERID|PASSWORD" > $cluster_name_components_configs
        returncode=`echo $?`
    fi
    if [ $returncode != 0 ];then
        echo -e "${RED}Failed getting service list dump $i. ${NC}"
        exit 1
    fi
done

echo -e "${GREEN}\nPlease review the files under $script_data_dir for cluster config.${NC}"


