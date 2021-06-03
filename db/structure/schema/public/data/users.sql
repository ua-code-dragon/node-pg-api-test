insert into users 
    ( username, display, email, roles, password )
values
    ( 'admin', 'Admin', 'admin@host.name', '{admin}', password_hash('xthtppf,jh') )
on conflict (username) do nothing    
;    
