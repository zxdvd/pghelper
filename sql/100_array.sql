
-- uniq an array [1,2,3,1,1,2] to [1,2,3]
create or replace function helper.array_uniq(arr anyarray) returns anyarray as $$
  select array_agg(a) from (select unnest(arr) a group by a) tmp;
$$ language sql immutable strict;

-- unnest an array with index ['a', 'b', 'c'] to [(1, 'a'), (2, 'b'), (3, 'c')]
create or replace function helper.unnest_with_index(arr anyarray) returns table(key int, value anyelement)  as $$
    select generate_series(1, array_length(arr, 1)), unnest(arr);
$$ language sql immutable strict;
