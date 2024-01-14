create schema if not exists dsr;

alter schema dsr owner to postgres;

/**
  Sales Arms
 */

do
$$
    begin
        perform 'dsr."SalesArmsLevel"'::regtype;
    exception
        when undefined_object then
            create domain dsr."SalesArmsLevel" as smallint
                check (value > 0 and value < 4);
    end
$$;

drop table if exists dsr."SalesArms" cascade;

create table if not exists dsr."SalesArms"
(
    "salesArmIHI"       varchar(6)           not null
        constraint "pkSalesArms"
            primary key,
    "salesArmName"      varchar(64)          not null,
    "salesArmLevel"     dsr."SalesArmsLevel" not null,
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

alter table dsr."SalesArms"
    owner to postgres;

create or replace function dsr."onValidateSalesArmsAddUpdate"()
    returns trigger
    language plpgsql
as
$trg$
begin
    if new."salesArmLevel" = 2 and (select count(*)
                                    from dsr."SalesArms" sa
                                    where sa."salesArmLevel" = 1
                                      and sa."salesArmIHI" = new."salesArmParentUID") = 0 then
        raise exception 'Invalid parent for given level. Level 1 is required.';
    end if;
    if new."salesArmLevel" = 3 and (select count(*)
                                    from dsr."SalesArms" sa
                                    where sa."salesArmLevel" = 2
                                      and sa."salesArmIHI" = new."salesArmParentUID") = 0 then
        raise exception 'Invalid parent for given level. Level 2 parent is required.';
    end if;
    return new;
end
$trg$;

create or replace function dsr."onValidateSalesArmsDelete"()
    returns trigger
    language plpgsql
as
$trg$
begin
    if old."salesArmLevel" <= 2 and (select count(*)
                                     from dsr."SalesArms" sa
                                     where sa."salesArmParentUID" = old."salesArmIHI") > 0 then
        raise exception 'Cannot delete item which has child items.';
    end if;
    return old;
end
$trg$;

create trigger "validateSalesArmsAddUpdate"
    before insert or update
    on dsr."SalesArms"
    for each row
execute function dsr."onValidateSalesArmsAddUpdate"();

create trigger "validateSalesArmsDelete"
    before delete
    on dsr."SalesArms"
    for each row
execute function dsr."onValidateSalesArmsDelete"();

create or replace function dsr."getSalesArmsTree"()
    returns jsonb
    language plpgsql
    security definer
as
$body$
declare
    frs jsonb;
begin
    with "SalesArms" as (--
        select --
               sa1."salesArmIHI",
               sa1."salesArmName",
               coalesce(lv2."salesArmDivisions", '[]'::jsonb) as "salesArmDivisions"
        from dsr."SalesArms" sa1
                 left join (--
            select --
                   sa2."salesArmParentUID"             as "salesArmIHI",
                   coalesce(jsonb_agg(jsonb_build_object(--
                           'salesArmIHI', sa2."salesArmIHI",
                           'salesArmName', sa2."salesArmName",
                           'salesArmDivisions', coalesce(lv3."salesArmDivisions", '[]'::jsonb)
                                      )), '[]'::jsonb) as "salesArmDivisions"
            from dsr."SalesArms" sa2
                     left join (--
                select --
                       sa3."salesArmParentUID"                    as "salesArmIHI",
                       coalesce(jsonb_agg(jsonb_build_object(--
                               'salesArmIHI', sa3."salesArmIHI", 'salesArmName',
                               sa3."salesArmName")), '[]'::jsonb) as "salesArmDivisions"
                from dsr."SalesArms" sa3
                where "salesArmLevel" = 3
                group by sa3."salesArmIHI") lv3
                               on lv3."salesArmIHI" = sa2."salesArmIHI"
            where "salesArmLevel" = 2
            group by sa2."salesArmParentUID") lv2 on lv2."salesArmIHI" = sa1."salesArmIHI"
        where "salesArmLevel" = 1
--
    )
    select jsonb_agg(sa)
    into frs
    from "SalesArms" sa;
    return frs;
end
$body$;

/**
  Product Categories
 */

drop table if exists dsr."ProductCategories" cascade;

create table if not exists dsr."ProductCategories"
(
    "productCategoryIHI"  varchar(5)   not null
        constraint "pkProductCategories"
            primary key,
    "productCategoryName" varchar(120) not null,
    check ("productCategoryIHI" !~ '^\s+'
        and "productCategoryIHI" !~ '\s+$'
        and "productCategoryName" !~ '^\s+'
        and "productCategoryName" !~ '\s+$')
);

alter table dsr."ProductCategories"
    owner to postgres;

/**
  Products
 */

drop table if exists dsr."Products" cascade;

create table dsr."Products"
(
    "productIHI"         varchar(9)   not null
        constraint "pkProducts"
            primary key,
    "productName"        varchar(120) not null,
    "productCategoryIHI" varchar(5)   not null,
    "productSKU"         varchar(25),
    "productUPC"         bigint,
    check ("productCategoryIHI" !~ '^\s+'
        and "productCategoryIHI" !~ '\s+$'
        and "productName" !~ '^\s+'
        and "productName" !~ '\s+$')
);

alter table dsr."Products"
    owner to postgres;

alter table dsr."Products"
    add constraint "fkProductCategoriesInProducts"
        foreign key ("productCategoryIHI") references dsr."ProductCategories";

/**
  Sales Arms of Products
 */

drop table if exists dsr."SalesArmsOfProducts" cascade;

create table dsr."SalesArmsOfProducts"
(
    "productSalesArmRefUID" uuid default gen_random_uuid() not null
        constraint "pkSalesArmsOfProducts"
            primary key,
    "productIHI"            varchar(9)                     not null,
    "salesArmIHI"           varchar(6)                     not null
);

alter table dsr."SalesArmsOfProducts"
    owner to postgres;

alter table dsr."SalesArmsOfProducts"
    add constraint "fkProductsInSalesArmsOfProducts"
        foreign key ("productIHI") references dsr."Products";

alter table dsr."SalesArmsOfProducts"
    add constraint "fkSalesArmsInSalesArmsOfProducts"
        foreign key ("salesArmIHI") references dsr."SalesArms";

alter table dsr."SalesArmsOfProducts"
    add constraint "ukSalesArmsOfProducts1"
        unique ("productIHI", "salesArmIHI");

/**
  Sales Arms of Product Categories
 */

drop table if exists dsr."SalesArmsOfProductCategories" cascade;

create table dsr."SalesArmsOfProductCategories"
(
    "productCategorySalesArmRefUID" uuid default gen_random_uuid() not null
        constraint "pkSalesArmsOfProductCategories"
            primary key,
    "productCategoryIHI"            varchar(5)                     not null,
    "salesArmIHI"                   varchar(6)                     not null
);

alter table dsr."SalesArmsOfProductCategories"
    owner to postgres;

alter table dsr."SalesArmsOfProductCategories"
    add constraint "fkProductCategoriesInSalesArmsOfProducts"
        foreign key ("productCategoryIHI") references dsr."ProductCategories";

alter table dsr."SalesArmsOfProductCategories"
    add constraint "fkSalesArmsInSalesArmsOfProductCategories"
        foreign key ("salesArmIHI") references dsr."SalesArms";

alter table dsr."SalesArmsOfProductCategories"
    add constraint "ukSalesArmsOfProductCategories1"
        unique ("productCategoryIHI", "salesArmIHI");