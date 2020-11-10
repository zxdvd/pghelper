
-- get table privilege of a specific user
create or replace function helper.priv_of_table(u text, tab regclass) returns text[] as $$
    select array_agg(priv) privs
    from (
        select
            case
                when has_table_privilege(u, tab, op) then op
                else null
            end as priv
        from unnest(ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES']) op
    ) t where priv is not null;
$$ language sql immutable strict;

-- get table privilege of all tables
create or replace function helper.priv_of_all_tables(u text)
returns table(tablename text, schema text, privs text[]) as $$
    select relname::text,relnamespace::regnamespace::text
        ,helper.priv_of_table(u, oid::regclass) as privs
    from pg_class where relkind in ('r', 'p')
$$ language sql immutable strict;
