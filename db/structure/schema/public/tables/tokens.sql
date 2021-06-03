create table if not exists tokens (
    ctime       timestamp not null default now(),
    username    varchar(64) not null,
    token       varchar(4096) not null primary key,
    tokendata   varchar(4096),
    expires     timestamptz,
    revoked     boolean not null default false
);


