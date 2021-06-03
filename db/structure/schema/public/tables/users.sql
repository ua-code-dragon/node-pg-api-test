create table if not exists users (
    username varchar(64) not null primary key,
    display varchar(255),
    email varchar(64),
    password varchar(4096) not null,
    roles text[],
    enable boolean not null default true
);


