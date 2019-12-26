

-- urldecode, %3A => : %2F => /
create or replace function helper.urldecode(text) returns text as $$
select string_agg(y, '') from (
  select case length(x[1])
        when 3 then convert_from(decode(substring(x[1] from 2 for 2), 'hex'), 'utf8')
        else x[1]
      end as y
from regexp_matches($1, '%[0-9a-f][0-9a-f]|.', 'gi') as x) tmp

$$ language sql immutable strict;
