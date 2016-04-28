--hiveconf = hiveconf provided when running the hive command
--${hiveconf:stage_db} = property specified in hiveconf.

DROP TABLE IF EXISTS ${hiveconf:db}.account_stage;

CREATE TABLE ${hiveconf:db}.account_stage(
	phone_num string,
	plan int,
	rec_date string,
	status int,
	balance bigint,
	IMEI string,
	region string,
	ingest_date date
)
STORED AS ORC;
