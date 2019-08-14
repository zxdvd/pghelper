
create or replace function helper.to_int(s text) returns int as $$
begin
        return s::int;
exception when others then
        return null;
end
$$ language plpgsql immutable;

create or replace function helper.to_float(s text) returns float as $$
begin
        return s::float;
exception when others then
        return null;
end
$$ language plpgsql immutable;
