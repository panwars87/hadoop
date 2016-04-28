--hiveconf = hiveconf provided when running the hive command
--${hiveconf:db} = property specified in hiveconf(this is prod db).

DROP TABLE IF EXISTS ${hiveconf:db}.account;

CREATE TABLE ${hiveconf:db}.account(
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
