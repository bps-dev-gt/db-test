create schema if not exists fd;
alter schema fd owner to postgres;

drop table if exists fd."ProductSales" cascade;
drop table if exists fd."PurchasePricesOfSupplierProducts" cascade;
drop table if exists fd."StockOfProducts" cascade;
drop table if exists fd."SupplierProducts" cascade;
drop table if exists fd."Customers" cascade;
drop table if exists fd."ProductCategories" cascade;
drop table if exists fd."Products" cascade;

/**
  fd."Customers"
 */
select --
       cus."customerUID",
       cus.asiakasnimi::varchar(120) as "customerName",
       cus.email::varchar(120)       as "customerContactEmail",
       case
           when cus.asiakasnimi ilike 'HENKI%' then
               true
           else false end            as "isCustomerNaturalPerson",
       cus.aikaleima                 as "tsCustomerUpdted"
into fd."Customers"
from sanitized.san_tst_asiakas as cus;
alter table fd."Customers"
    alter column "customerName" set not null;

alter table fd."Customers"
    alter column "isCustomerNaturalPerson" set not null;

alter table fd."Customers"
    alter column "isCustomerNaturalPerson" set default false;

alter table fd."Customers"
    alter column "tsCustomerUpdted" set not null;

alter table fd."Customers"
    alter column "tsCustomerUpdted" set default current_timestamp;

alter table fd."Customers"
    add constraint "pkCustomers"
        primary key ("customerUID");

/**
  fd."ProductCategories"
 */
select --
       cat."productCategoryUID",
       cat.tuoteryhmanimi::varchar(120) as "productCategoryName"
into fd."ProductCategories"
from sanitized.san_tst_tuoteryhma cat;

alter table fd."ProductCategories"
    alter column "productCategoryName" set not null;

alter table fd."ProductCategories"
    add constraint "pkProductCategories"
        primary key ("productCategoryUID");

/**
  fd."Products"
 */
select --
       prd."productUID",
       prd."productCategoryUID",
       prd.koodi::varchar(25) as "productSKU",
       null::bigint           as "productUPC",
       now()::timestamp       as "tsProductAdded"
into fd."Products"
from sanitized.san_tst_tuote prd;

alter table fd."Products"
    alter column "productCategoryUID" set not null;

alter table fd."Products"
    alter column "tsProductAdded" set not null;

alter table fd."Products"
    alter column "tsProductAdded" set default current_timestamp;

alter table fd."Products"
    add constraint "pkProducts"
        primary key ("productUID");

/**
  fd."StockOfProducts"
 */
select --
       bal."stockOfProductUID",
       bal."productUID",
       bal.saldo        as "productStockLevel",
       now()::timestamp as "tsProductStockLevelUpdated"
into fd."StockOfProducts"
from sanitized.san_tst_saldo bal;

alter table fd."StockOfProducts"
    alter column "productUID" set not null;

alter table fd."StockOfProducts"
    alter column "productStockLevel" set not null;

alter table fd."StockOfProducts"
    alter column "productStockLevel" set default 0;

alter table fd."StockOfProducts"
    add constraint "pkStockOfProducts"
        primary key ("stockOfProductUID");

alter table fd."StockOfProducts"
    add constraint "fkProductsInStockOfProducts"
        foreign key ("productUID") references fd."Products";

alter table fd."StockOfProducts"
    add constraint "ukProductInStockOfProducts"
        unique ("productUID");

/**
  fd."SupplierProducts"
 */
select --
       sprd."supplierProductUID",
       sprd."productUID",
       sprd.toimittajatuotekoodi::varchar(20)          as "supplierProductSKU",
       coalesce(sprd.oletustoimittaja, false)::boolean as "isPrimarySupplierProduct",
       now()::timestamp                                as "tsSupplierProductAddedd"
into fd."SupplierProducts"
from sanitized.san_tst_toimittajatuote sprd;

alter table fd."SupplierProducts"
    alter column "productUID" set not null;

alter table fd."SupplierProducts"
    alter column "isPrimarySupplierProduct" set not null;

alter table fd."SupplierProducts"
    alter column "isPrimarySupplierProduct" set default false;

alter table fd."SupplierProducts"
    alter column "tsSupplierProductAddedd" set not null;

alter table fd."SupplierProducts"
    alter column "tsSupplierProductAddedd" set default current_timestamp;

alter table fd."SupplierProducts"
    add constraint "pkSupplierProducts"
        primary key ("supplierProductUID");

alter table fd."SupplierProducts"
    add constraint "fkProductInSupplierProducts"
        foreign key ("productUID") references fd."Products";

/**
  fd."PurchasePricesOfSupplierProducts"
 */
select --
       pup."spPurchasePriceUID",
       pup."supplierProductUID",
       pup.hinta as "spPurchasePrice",
       pup.pvm   as "datePurchasePriceEffective"
into fd."PurchasePricesOfSupplierProducts"
from sanitized.san_tst_ostohinta pup;

alter table fd."PurchasePricesOfSupplierProducts"
    alter column "supplierProductUID" set not null;

alter table fd."PurchasePricesOfSupplierProducts"
    alter column "spPurchasePrice" set not null;

alter table fd."PurchasePricesOfSupplierProducts"
    alter column "spPurchasePrice" set default 0;

alter table fd."PurchasePricesOfSupplierProducts"
    alter column "datePurchasePriceEffective" set not null;

alter table fd."PurchasePricesOfSupplierProducts"
    alter column "datePurchasePriceEffective" set default now()::date;

alter table fd."PurchasePricesOfSupplierProducts"
    add constraint "pkPurchasePricesOfSupplierProducts"
        primary key ("spPurchasePriceUID");

alter table fd."PurchasePricesOfSupplierProducts"
    add constraint "fkSupplierProductInPurchasePricesOfSupplierProducts"
        foreign key ("supplierProductUID") references fd."SupplierProducts";

alter table fd."PurchasePricesOfSupplierProducts"
    add constraint "ukPurchasePricesOfSupplierProducts1"
        unique ("supplierProductUID", "datePurchasePriceEffective");

/**
  fd."ProductSales"
 */
select --
       sls."productSaleUID",
       sls."customerUID",
       sls."productUID",
       sls.hinta as "productSalePrice",
       sls.kpl   as "productSaleAmount",
       sls.pvm   as "productSaleDate"
into fd."ProductSales"
from sanitized.san_tst_myynti sls;

alter table fd."ProductSales"
    alter column "customerUID" set not null;

alter table fd."ProductSales"
    alter column "productUID" set not null;

alter table fd."ProductSales"
    alter column "productSalePrice" set not null;

alter table fd."ProductSales"
    alter column "productSalePrice" set default 0;

alter table fd."ProductSales"
    alter column "productSaleAmount" set not null;

alter table fd."ProductSales"
    alter column "productSaleAmount" set default 0;

alter table fd."ProductSales"
    alter column "productSaleDate" set not null;

alter table fd."ProductSales"
    alter column "productSaleDate" set default now()::date;

alter table fd."ProductSales"
    add constraint "pkProductSales"
        primary key ("productSaleUID");

alter table fd."ProductSales"
    add constraint "fkCustomerInProductSales"
        foreign key ("customerUID") references fd."Customers";

alter table fd."ProductSales"
    add constraint "fkProductInProductSales"
        foreign key ("productUID") references fd."Products";

-- Validate final data
with "FinalDataValidation" as (
--
    select --
           'Customers'                                 as "tableName",
           'tst_asiakas'                               as "sourceableName",
           (select count(*) from fd."Customers")       as "rowsCount",
           (select count(*) from incoming.tst_asiakas) as "incomingRowsCount",
           (select count(*) from incoming.tst_asiakas) -
           (select count(*) from fd."Customers")       as "rowsCountDiff"
    union
    select --
           'ProductCategories'                            as "tableName",
           'tst_tuoteryhma'                               as "sourceableName",
           (select count(*) from fd."ProductCategories")  as "rowsCount",
           (select count(*) from incoming.tst_tuoteryhma) as "incomingRowsCount",
           (select count(*) from incoming.tst_tuoteryhma) -
           (select count(*) from fd."ProductCategories")  as "rowsCountDiff"
    union
    select --
           'Products'                                as "tableName",
           'tst_tuote'                               as "sourceableName",
           (select count(*) from fd."Products")      as "rowsCount",
           (select count(*) from incoming.tst_tuote) as "incomingRowsCount",
           (select count(*) from incoming.tst_tuote) -
           (select count(*) from fd."Products")      as "rowsCountDiff"
    union
    select --
           'ProductSales'                             as "tableName",
           'tst_myynti'                               as "sourceableName",
           (select count(*) from fd."ProductSales")   as "rowsCount",
           (select count(*) from incoming.tst_myynti) as "incomingRowsCount",
           (select count(*) from incoming.tst_myynti) -
           (select count(*) from fd."ProductSales")   as "rowsCountDiff"
    union
    select --
           'PurchasePricesOfSupplierProducts'                           as "tableName",
           'tst_ostohinta'                                              as "sourceableName",
           (select count(*) from fd."PurchasePricesOfSupplierProducts") as "rowsCount",
           (select count(*) from incoming.tst_ostohinta)                as "incomingRowsCount",
           (select count(*) from incoming.tst_ostohinta) -
           (select count(*) from fd."PurchasePricesOfSupplierProducts") as "rowsCountDiff"
    union
    select --
           'StockOfProducts'                           as "tableName",
           'tst_saldo'                                 as "sourceableName",
           (select count(*) from fd."StockOfProducts") as "rowsCount",
           (select count(*) from incoming.tst_saldo)   as "incomingRowsCount",
           (select count(*) from incoming.tst_saldo) -
           (select count(*) from fd."StockOfProducts") as "rowsCountDiff"
    union
    select --
           'SupplierProducts'                                   as "tableName",
           'tst_toimittajatuote'                               as "sourceableName",
           (select count(*) from fd."SupplierProducts")        as "rowsCount",
           (select count(*) from incoming.tst_toimittajatuote) as "incomingRowsCount",
           (select count(*) from incoming.tst_toimittajatuote) -
           (select count(*) from fd."SupplierProducts")        as "rowsCountDiff"
--
)
select *
from "FinalDataValidation" fdv
order by fdv."tableName";
