
-- like describe in mysql, this will extract the create table sql of existed table
-- TODO: index support, partition support

create or replace function helper.describe_table(text) returns text as $$
        with attrs as (
                select quote_ident(attname)
                        || '  '
                        || format_type(atttypid, atttypmod)
                        || '  '
                        || case when attnotnull then 'NOT NULL' else 'NULL' end as col
                from pg_attribute
                where attrelid = $1::regclass
                        and attnum > 0     -- filter junk attrs(xmax, xmin)
                        and not attisdropped       -- filter dropped columns
                order by attnum
        ),
        constraints as (
                select 'CONSTRAINT  ' || quote_ident(conname) || '  ' || pg_get_constraintdef(oid)
                from pg_constraint
                where conrelid = $1::regclass
        ),
        all_rows (row) as (
                select * from attrs union all select * from constraints
        )
        select 'create table ' || quote_ident($1) || E' (\n'
                || array_to_string(array_agg(row), E',\n')
                || E'\n)'
        from all_rows
$$ language sql immutable;

