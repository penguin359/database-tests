BEGIN TRANSACTION;

-- Load checkout_times SQL function
\i sql/checkout_times.sql
\i sql/holiday.sql

SELECT plan(8);

-- Checked out before 4 PM on Monday for one day, expected to check in at 4 PM on Tuesday
SELECT is((SELECT expire_time FROM checkout_times('2020-12-07T15:23:00'::timestamptz, '1 day'::interval)),
	  '2020-12-08T16:00:00'::timestamptz);

-- Checked out after 4 PM on Monday for one day, expected to check in at 4 PM on Wednesday
-- This ensures they get a full 24 hours for their checkout
SELECT is((SELECT expire_time FROM checkout_times('2020-12-07T16:07:00'::timestamptz, '1 day'::interval)),
	  '2020-12-09T16:00:00'::timestamptz);

-- Checked on Monday for 4 days should land on Friday
SELECT is((SELECT expire_time FROM checkout_times('2020-12-07T01:10:00'::timestamptz, '4 days'::interval)),
	  '2020-12-11T16:00:00'::timestamptz);

-- Checked on Monday for 5 days should land on week-end and be bumped to Monday
SELECT is((SELECT expire_time FROM checkout_times('2020-12-07T08:45:00'::timestamptz, '5 days'::interval)),
	  '2020-12-14T16:00:00'::timestamptz);

-- Checked on Monday for 6 days should land on week-end and be bumped to Monday
SELECT is((SELECT expire_time FROM checkout_times('2020-12-07T08:00:00'::timestamptz, '6 days'::interval)),
	  '2020-12-14T16:00:00'::timestamptz);

-- Checked on Monday for 7 days should land on Monday
SELECT is((SELECT expire_time FROM checkout_times('2020-12-07T15:23:00'::timestamptz, '7 days'::interval)),
	  '2020-12-14T16:00:00'::timestamptz);

-- If Monday is a holiday, a 5 day checkout should be extended to Tuesday

INSERT INTO holiday (holiday) VALUES ('2020-12-14'::date);
SELECT is((SELECT expire_time FROM checkout_times('2020-12-07T08:45:00'::timestamptz, '5 days'::interval)),
	  '2020-12-15T16:00:00'::timestamptz);

-- If Monday and Tuesday are holidays, a 5 day checkout should be extended to Wednesday
INSERT INTO holiday (holiday) VALUES ('2020-12-15'::date);
SELECT is((SELECT expire_time FROM checkout_times('2020-12-07T08:45:00'::timestamptz, '5 days'::interval)),
	  '2020-12-16T16:00:00'::timestamptz);

SELECT * FROM finish();

ROLLBACK TRANSACTION;
