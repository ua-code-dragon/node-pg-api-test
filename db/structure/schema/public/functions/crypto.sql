create or replace function password_hash( varchar ) returns varchar as $$
    select encode(sha256($1::bytea), 'hex');
$$ language sql immutable;

create or replace function password_verify ( varchar, varchar ) returns boolean as $$
    select $1 notnull and $2 notnull and ($1 = $2 or password_hash($1) = $2);
$$ language sql immutable;

