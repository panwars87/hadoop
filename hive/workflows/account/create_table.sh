#!/bin/sh

if [ $# -ne 1 ]; then
    echo "Usage: /path/to/create_tables.sh <env name: dev|stage|prod>"
    exit 1
fi

database="cmhtestdb";
stage_db="cmhstagedb";
prod_db="cmhproddb";

if [ "$1" = "dev" ]; then
	hive --hiveconf db=$database -f create_accnt_temp.hql
	exit_code=$?
	echo $exit_code;
fi

if [ "$1" = "stage" ]; then
	hive --hiveconf db=$stage_db -f create_accnt_stage.hql
	exit_code=$?
	echo $exit_code;
fi

if [ "$1" = "prod" ]; then
	hive --hiveconf db=$prod_db -f create_accnt.hql
        exit_code=$?
	echo $exit_code;
fi
