create or replace function api_user_set (idata jsonb, out errcode integer, out errmsg varchar, out result jsonb) as $$
begin
    errcode := 0;
    errmsg := '';
    if idata ->> 'username' isnull then
        errcode := 2;
        errmsg := 'No userename';
        return;
    end if;        
    insert into users (
        username,
        display,
        email,
        password,
        roles,
        enabled
    ) values (
        idata ->> 'username',
        idata ->> 'display',
        idata ->> 'email',
        idata -> 'roles',
        password_hash(idata ->> 'password'),
        coalesce( (idata ->> 'enable')::boolean, true)
    ) on conflict ( username )
    do update set
        users.display = coalesce(idata ->> 'display', users.display),
        users.email = coalesce(idata ->> 'email', users.email),
        users.roles = coalesce(idata -> 'roles', users.roles),
        users.password = coalesce(password_hash(idata ->> 'password'), users.password),
        users.enable = coalesce((idata ->> 'enable')::boolean, users.enable)
    ;
exception when others then
    errcode := -10;
    errmsg := format('%s: %s',SQLSTATE,to_jsonb(SQLERRM));
end;
$$ language plpgsql;


create or replace function api_user_get (idata jsonb, out errcode integer, out errmsg varchar, out result jsonb) as $$
declare
    _username varchar;
begin
    errcode := 0;
    errmsg := '';
    _username := idata ->> 'username';
    select into result jsonb_agg (row_to_json(r)) from (
        select  
            username, display, email, roles
        from users
        where 
            enabled and
            case when _username isnull or _username = '*' then true else username = _username end
    ) r ;
exception when others then
    errcode := -10;
    errmsg := format('%s: %s',SQLSTATE,to_jsonb(SQLERRM));
end;
$$ language plpgsql;


create or replace function api_user_auth (idata jsonb, out errcode integer, out errmsg varchar, out result jsonb) as $$
declare
    _username varchar;
    _password varchar;
begin
    errcode := 0;
    errmsg := '';
    _username := idata ->> 'username';
    _password := idata ->> 'password';
    if _username isnull then
        return;
    end if;        
    select into result jsonb_agg (row_to_json(r)) from (
        select  
             username, display, email, roles
        from users
        where 
            username = _username and password_verify(_password, password)
    ) r ;
exception when others then
    errcode := -10;
    errmsg := format('%s: %s',SQLSTATE,to_jsonb(SQLERRM));
end;
$$ language plpgsql;

