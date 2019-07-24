
-- concat array while group by (array_agg cannot concat array)
-- select department_id, array_cat_agg(role_ids) from staff group by department_id;

drop AGGREGATE if exists array_cat_agg(anyarray);

CREATE AGGREGATE array_cat_agg(anyarray) (
  SFUNC=array_cat,
  STYPE=anyarray
);
