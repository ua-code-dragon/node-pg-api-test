do language plpgsql $$
begin

if not exists (select 1 from pg_type where typname = 'geodata') then
        create type geodata as (
                latitude        float8,
                longitude       float8,
                altitude        float8,
                roll            float8,
                yaw             float8,
                pitch           float8,
                speed           float8
        );
end if;

if not exists (select 1 from pg_type where typname = 'transform2') then
        create type transform2 as (
                "a" float8, -- scale x
                "b" float8, -- skew x
                "c" float8, -- skew y
                "d" float8, -- scale y
                "x" float8, -- shift x
                "y" float8  -- shift y
        );
end if;

end;
$$;
