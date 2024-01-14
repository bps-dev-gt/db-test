create domain fd."SalesArmsLevel" as smallint
    check (value > 0 and value < 4);

drop table if exists fd."SalesArms";

create table fd."SalesArms"
(
    "salesArmUID"       uuid default gen_random_uuid() not null
        constraint "pkSalesArms"
            primary key,
    "salesArmName"      varchar(64)                    not null,
    "salesArmLevel"     fd."SalesArmsLevel"            not null,
    "salesArmParentUID" uuid,
    check ("salesArmName" !~ '^\s+' and "salesArmName" !~ '\s+$' and
           (case
                when "salesArmLevel" = 1 and "salesArmParentUID" is null
                    then true
                when "salesArmLevel" > 1 and "salesArmParentUID" is not null
                    then true
                else false end)
        )
);

alter table fd."SalesArms"
    owner to postgres;

create or replace function fd."onValidateSalesArmsAddUpdate"()
    returns trigger
    language plpgsql
as
$trg$
begin
    if new."salesArmLevel" = 2 and (select count(*)
                                    from fd."SalesArms" sa
                                    where sa."salesArmLevel" = 1
                                      and sa."salesArmUID" = new."salesArmParentUID") = 0 then
        raise exception 'Invalid parent for given level. Level 1 is required.';
    end if;
    if new."salesArmLevel" = 3 and (select count(*)
                                    from fd."SalesArms" sa
                                    where sa."salesArmLevel" = 2
                                      and sa."salesArmUID" = new."salesArmParentUID") = 0 then
        raise exception 'Invalid parent for given level. Level 2 parent is required.';
    end if;
    return new;
end
$trg$;

create or replace function fd."onValidateSalesArmsDelete"()
    returns trigger
    language plpgsql
as
$trg$
begin
    if old."salesArmLevel" <= 2 and (select count(*)
                                     from fd."SalesArms" sa
                                     where sa."salesArmParentUID" = old."salesArmUID") > 0 then
        raise exception 'Cannot delete item which has child items.';
    end if;
    return old;
end
$trg$;

create trigger "validateSalesArmsAddUpdate"
    before insert or update
    on fd."SalesArms"
    for each row
execute function fd."onValidateSalesArmsAddUpdate"();

create trigger "validateSalesArmsDelete"
    before delete
    on fd."SalesArms"
    for each row
execute function fd."onValidateSalesArmsDelete"();

-- Add some test data
--- Top level
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Hunting', 1, null);
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Garden', 1, null);
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Bicycling', 1, null);
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Hiking', 1, null);
--- Second level
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Traps', 2, (select "salesArmUID" from fd."SalesArms" where "salesArmName" = 'Hunting'));
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Guns', 2, (select "salesArmUID" from fd."SalesArms" where "salesArmName" = 'Hunting'));
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Backpacks', 2, (select "salesArmUID" from fd."SalesArms" where "salesArmName" = 'Hiking'));
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Hiking clothes', 2, (select "salesArmUID" from fd."SalesArms" where "salesArmName" = 'Hiking'));
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Sleeping bags', 2, (select "salesArmUID" from fd."SalesArms" where "salesArmName" = 'Hiking'));
-- Third level
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Bullets', 3, (select "salesArmUID" from fd."SalesArms" where "salesArmName" = 'Guns'));
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Gun cases', 3, (select "salesArmUID" from fd."SalesArms" where "salesArmName" = 'Guns'));
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Backpack accessories', 3, (select "salesArmUID" from fd."SalesArms" where "salesArmName" = 'Backpacks'));
insert into fd."SalesArms"("salesArmName", "salesArmLevel", "salesArmParentUID")
values ('Hiking underwear', 3, (select "salesArmUID" from fd."SalesArms" where "salesArmName" = 'Hiking clothes'));

-- SalesArms as JSON tree
with "SalesArms" as (--
    select --
           sa1."salesArmUID",
           sa1."salesArmName",
           coalesce(lv2."salesArmDivisions", '[]'::jsonb) as "salesArmDivisions"
    from fd."SalesArms" sa1
             left join (--
        select --
               sa2."salesArmParentUID"             as "salesArmUID",
               coalesce(jsonb_agg(jsonb_build_object(--
                       'salesArmUID', sa2."salesArmUID",
                       'salesArmName', sa2."salesArmName",
                       'salesArmDivisions', coalesce(lv3."salesArmDivisions", '[]'::jsonb)
                                  )), '[]'::jsonb) as "salesArmDivisions"
        from fd."SalesArms" sa2
                 left join (--
            select --
                   sa3."salesArmParentUID"                    as "salesArmUID",
                   coalesce(jsonb_agg(jsonb_build_object(--
                           'salesArmUID', sa3."salesArmUID", 'salesArmName',
                           sa3."salesArmName")), '[]'::jsonb) as "salesArmDivisions"
            from fd."SalesArms" sa3
            where "salesArmLevel" = 3
            group by sa3."salesArmUID") lv3
                           on lv3."salesArmUID" = sa2."salesArmUID"
        where "salesArmLevel" = 2
        group by sa2."salesArmParentUID") lv2 on lv2."salesArmUID" = sa1."salesArmUID"
    where "salesArmLevel" = 1
--
)
select jsonb_agg(sa) as "SalesArms"
from "SalesArms" sa
