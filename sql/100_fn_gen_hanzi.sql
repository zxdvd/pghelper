-- copied from https://github.com/digoal/blog/blob/master/201711/20171107_14.md
-- 19968 == 4e00, 19968+20991 == 4fff, [4e00, 4fff] is the common used chinese unicode

create or replace function helper.gen_hanzi(int) returns text as $$
declare
  res text;
begin
  if $1 >=1 then
    select string_agg(chr(19968+(random()*20991)::int), '') into res from generate_series(1,$1);
    return res;
  end if;
  return null;
end;
$$ language plpgsql strict;
