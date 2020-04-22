
-- uniq an array [1,2,3,1,1,2] to [1,2,3]
create or replace function helper.array_uniq(arr anyarray) returns anyarray as $$
  return select array_agg(a) from (select unnest(arr) a group by a) tmp;
$$ language sql immutable strict;
