--hiveconf = hiveconf provided when running the hive command
--${hiveconf:db} = property specified in hiveconf.

DROP TABLE IF EXISTS ${hiveconf:db}.account_temp;

CREATE EXTERNAL TABLE ${hiveconf:db}.account_temp(
	phone_num string,
	plan int,
	rec_date string,
	status int,
	balance bigint,
	IMEI string,
	region string)
PARTITIONED BY(ingest_date string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = "|"
)
LOCATION '/apps/cmhpcdw/source/incoming/newdataset'
TBLPROPERTIES("skip.header.line.count"="1");
