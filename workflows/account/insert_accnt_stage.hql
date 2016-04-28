MSCK REPAIR TABLE cmhtestdb.account_temp;
INSERT OVERWRITE TABLE cmhstagedb.account_stage
SELECT
tmp.phone_num,
tmp.plan,
tmp.rec_date,
tmp.status,
tmp.balance,
tmp.imei,
tmp.region,
cast(tmp.ingest_date as date)
FROM cmhtestdb.account_temp tmp
WHERE ingest_date="2016-04-27";


