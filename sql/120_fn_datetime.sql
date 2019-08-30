
-- get days of a month
-- select helper.get_days_of_month(now()), helper.get_days_of_month('2019-02-01')
create or replace function helper.get_days_of_month(d timestamptz) returns integer as $$
        select extract(day from date_trunc('month', d) + interval '1 month' - interval '1 day')::integer;
$$ language sql immutable;
