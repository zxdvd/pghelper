-- copied from https://github.com/digoal/blog/blob/362b84417ca8b7aaf1add31fe7689c347642bb9a/201807/20180725_04.md

create or replace function helper.exchange_table(
  nsp name,       -- schema name
  from_tab name,  -- 表名1
  to_tab name,    -- 表名2
  mid_tab name,   -- 中间表名（使用不存在的表）
  timeout_s int,  -- 锁超时时间（秒），建议设小一点，比如1秒
  retry int,      -- 重试几次
  kill boolean default false,  -- 是否执行terminate backend
  sleepts int default 1,  -- 重试前睡眠多少秒
  steps int default 1    -- 重试次数判断
) returns boolean as $$
declare
begin
  -- 检查中间表是否已存在，存在则报错
  perform 1 from pg_class where relname=mid_tab and relnamespace=(select oid from pg_namespace where nspname=nsp) limit 1;
  if found then
    raise notice 'you should use not exists table for exchange.';
    return false;
  end if;

  -- 如果重试次数达到，还没有切换成功，则返回切换不成功
  if steps >= retry then
    return false;
  end if;

  -- 设置锁超时
  execute format('set local lock_timeout=%L;', timeout_s||'s');

  if kill then
    -- 杀死持有 表1，表2 锁的会话
    -- 如果是普通用户，只能杀死同名用户下的其他会话，所以如果持锁的是其他用户，则需要使用超级用户才能杀死
    perform pg_terminate_backend(pid) from pg_stat_activity where
      pid in (select pid from pg_locks where
                database=(select oid from pg_database where datname=current_database())
                and relation in ((nsp||'.'||from_tab)::regclass, (nsp||'.'||to_tab)::regclass)
             )
      and pid<>pg_backend_pid();
  end if;

  -- 对表1，表2 加排他锁
  execute format('lock table %I.%I in ACCESS EXCLUSIVE mode;', nsp, from_tab);
  execute format('lock table %I.%I in ACCESS EXCLUSIVE mode;', nsp, to_tab);

  -- 切换表1，表2
  execute format('alter table %I.%I rename to %I;', nsp, to_tab, mid_tab);
  execute format('alter table %I.%I rename to %I;', nsp, from_tab, to_tab);
  execute format('alter table %I.%I rename to %I;', nsp, mid_tab, from_tab);

  -- 返回切换成功
  return true;

  -- 任何一步失败（比如锁超时异常），则重试
  exception when others then
    -- 重试次数显示
    raise notice 'retry: %', steps;

    -- 睡眠
    perform pg_sleep(sleepts);

    -- 如果重试次数达到，还没有切换成功，则返回切换不成功
    if steps >= retry then
      return false;
    else
      -- 递归调用，重试，传入参数重试次数+1.
      return helper.exchange_table(nsp, from_tab, to_tab, mid_tab, timeout_s, retry, kill, sleepts, steps+1);
    end if;
end;
$$ language plpgsql strict;
