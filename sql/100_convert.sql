
create or replace function helper.to_int(s anyelement) returns int as $$
begin
        return s::int;
exception when others then
        return null;
end
$$ language plpgsql immutable;

create or replace function helper.to_float(s anyelement) returns float as $$
begin
        return s::float;
exception when others then
        return null;
end
$$ language plpgsql immutable;

-- convert text like '[1,2,3]' to pg array
-- select '1' = any(helper.text_to_array('[1,2,3]'))
create or replace function helper.text_to_array(s text) returns text[] as $$
        select array_agg(x)  from  json_array_elements_text(s::json) x;
$$ language sql immutable;
