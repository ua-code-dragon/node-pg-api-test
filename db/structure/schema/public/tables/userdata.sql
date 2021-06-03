create table if not exists userdata (
    id bigint not null generated by default as identity,
    username varchar(64) not null,
    moment timestamptz not null default now(),
    x float8,
    y float8,
    z float8
);