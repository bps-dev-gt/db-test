-- Add customerUID into san_tst_asiakas
alter table sanitized.san_tst_asiakas
    add "customerUID" uuid default gen_random_uuid() not null;

-- Add productSaleUID, customerUID, productUID into san_tst_myynti
alter table sanitized.san_tst_myynti
    add "productSaleUID" uuid default gen_random_uuid() not null;
alter table sanitized.san_tst_myynti
    add "customerUID" uuid;
alter table sanitized.san_tst_myynti
    add "productUID" uuid;

-- Add spPurchasePriceUID into san_tst_ostohinta
alter table sanitized.san_tst_ostohinta
    add "spPurchasePriceUID" uuid default gen_random_uuid() not null;
alter table sanitized.san_tst_ostohinta
    add "supplierProductUID" uuid;

-- Add stockOfProductUID, productUID into san_tst_saldo
alter table sanitized.san_tst_saldo
    add "stockOfProductUID" uuid default gen_random_uuid() not null;
alter table sanitized.san_tst_saldo
    add "productUID" uuid;

-- Add stockOfProductUID, productUID into san_tst_toimittajatuote
alter table sanitized.san_tst_toimittajatuote
    add "supplierProductUID" uuid default gen_random_uuid() not null;
alter table sanitized.san_tst_toimittajatuote
    add "productUID" uuid;

-- Add productUID, productCategoryUID into san_tst_tuote
alter table sanitized.san_tst_tuote
    add "productUID" uuid default gen_random_uuid() not null;
alter table sanitized.san_tst_tuote
    add "productCategoryUID" uuid;

-- Add productCategoryUID into san_tst_tuoteryhma
alter table sanitized.san_tst_tuoteryhma
    add "productCategoryUID" uuid default gen_random_uuid() not null;

-- Add missing customer relationship into san_tst_myynti
with "MissingCustomersInSales" as (--
    select       --
        distinct cus.asiakas,
                 cus."customerUID"
    from sanitized.san_tst_myynti sls
             join sanitized.san_tst_asiakas cus on cus.asiakas = sls.asiakas
    where sls."customerUID" is null --
)
update sanitized.san_tst_myynti
set "customerUID" = mcus."customerUID"
from "MissingCustomersInSales" mcus
where sanitized.san_tst_myynti."asiakas" = mcus.asiakas;

alter table sanitized.san_tst_myynti
    alter column "customerUID" set not null;

-- Add missing products relationship into san_tst_myynti
with "MissingProductsInSales" as (--
    select       --
        distinct prd.tuote,
                 prd."productUID"
    from sanitized.san_tst_myynti sls
             join sanitized.san_tst_tuote prd on prd.tuote = sls.tuote
    where sls."productUID" is null --
)
update sanitized.san_tst_myynti
set "productUID" = mprd."productUID"
from "MissingProductsInSales" mprd
where sanitized.san_tst_myynti."tuote" = mprd.tuote;

alter table sanitized.san_tst_myynti
    alter column "productUID" set not null;

-- Add missing supplier products relationship into san_tst_ostohinta
with "MissingSupProductsInPurPrices" as (--
    select       --
        distinct sprd.toimittajatuote,
                 sprd."supplierProductUID"
    from sanitized.san_tst_ostohinta pup
             join sanitized.san_tst_toimittajatuote sprd on sprd.toimittajatuote = pup.toimittajatuote
    where pup."supplierProductUID" is null --
)
update sanitized.san_tst_ostohinta
set "supplierProductUID" = mprd."supplierProductUID"
from "MissingSupProductsInPurPrices" mprd
where sanitized.san_tst_ostohinta."toimittajatuote" = mprd.toimittajatuote;

alter table sanitized.san_tst_ostohinta
    alter column "supplierProductUID" set not null;

-- Add missing products relationship into san_tst_saldo
with "MissingProductsInStockLevels" as (--
    select       --
        distinct prd.tuote,
                 prd."productUID"
    from sanitized.san_tst_saldo bal
             join sanitized.san_tst_tuote prd on prd.tuote = bal.tuote
    where bal."productUID" is null --
)
update sanitized.san_tst_saldo
set "productUID" = mprd."productUID"
from "MissingProductsInStockLevels" mprd
where sanitized.san_tst_saldo."tuote" = mprd.tuote;

alter table sanitized.san_tst_saldo
    alter column "productUID" set not null;

-- Add missing products relationship into san_tst_saldo
with "MissingProductsInSupplierProducts" as (--
    select       --
        distinct prd.tuote,
                 prd."productUID"
    from sanitized.san_tst_toimittajatuote sprd
             join sanitized.san_tst_tuote prd on prd.tuote = sprd.tuote
    where sprd."productUID" is null --
)
update sanitized.san_tst_toimittajatuote
set "productUID" = mprd."productUID"
from "MissingProductsInSupplierProducts" mprd
where sanitized.san_tst_toimittajatuote."tuote" = mprd.tuote;

alter table sanitized.san_tst_toimittajatuote
    alter column "productUID" set not null;

-- Add missing products category relationship into san_tst_tuote
with "MissingProductsCatInProducts" as (--
    select       --
        distinct pcat.tuoteryhma,
                 pcat."productCategoryUID"
    from sanitized.san_tst_tuote prd
             join sanitized.san_tst_tuoteryhma pcat on pcat.tuoteryhma = prd.tuoteryhma
    where prd."productCategoryUID" is null --
)
update sanitized.san_tst_tuote
set "productCategoryUID" = mcat."productCategoryUID"
from "MissingProductsCatInProducts" mcat
where sanitized.san_tst_tuote."tuoteryhma" = mcat.tuoteryhma;

alter table sanitized.san_tst_tuote
    alter column "productCategoryUID" set not null;
