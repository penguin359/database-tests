BEGIN TRANSACTION;

-- Load checkout_times SQL function
\i sql/checkout_times.sql

SELECT plan(2);

-- Checked out before 4 PM on Monday for one day, expected to check in at 4 PM on Tuesday
SELECT is((SELECT expire_time FROM checkout_times('2020-12-07T15:23:00'::timestamptz, '1 day'::interval)),
	  '2020-12-08T16:00:00'::timestamptz);

-- Checked on Monday for 4 days should land on Friday
SELECT is((SELECT expire_time FROM checkout_times('2020-12-07T15:23:00'::timestamptz, '4 days'::interval)),
	  '2020-12-11T16:00:00'::timestamptz);

SELECT * FROM finish();

ROLLBACK TRANSACTION;
