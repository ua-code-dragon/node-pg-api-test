create or replace function api_user_data (idata jsonb, out errcode integer, out errmsg varchar, out result jsonb) as $$
declare
    _username varchar;
    _after bigint;
    _limit integer;
begin
    errcode := 0;
    errmsg := '';
    _username := idata ->> 'username';
    _after := coalesce( (idata ->> 'after')::bigint, 0);
    _limit := coalesce( (idata ->> 'limit')::integer, 32);
    select into result jsonb_agg (row_to_json(r)) from (
        select  
            id, moment, x, y, z
        from userdata
        where 
            username = _username
            and id > _after 
        order by id 
        limit _limit                
    ) r ;
exception when others then
    errcode := -10;
    errmsg := format('%s: %s',SQLSTATE,to_jsonb(SQLERRM));
end;
$$ language plpgsql;


