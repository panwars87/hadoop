INSERT OVERWRITE TABLE cmhproddb.account
SELECT
stg.phone_num,
stg.plan,
stg.rec_date,
stg.status,
stg.balance,
stg.imei,
stg.region,
stg.ingest_date
FROM cmhstagedb.account_stage stg
WHERE stg.balance > 250;
