CREATE OR REPLACE FUNCTION checkout_times(
	IN start_time TIMESTAMP WITH TIME ZONE,
	IN checkout_length INTERVAL,
	OUT expire_time timestamptz,
	OUT final_time timestamptz) RETURNS record AS $function$
BEGIN
	expire_time := date_trunc('day', start_time) + '16:00:00'::interval;
	IF expire_time < start_time THEN
		expire_time := expire_time + '1 day'::interval;
	END IF;
	expire_time := expire_time + checkout_length;
END;
$function$
LANGUAGE plpgsql;
