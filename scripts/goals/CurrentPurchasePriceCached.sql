create materialized view fd."CurrentPurchasePricesCached" as
with "CurrentPurchasePrice" as (
--
    select --
           sprd."productUID",
           (array_agg(spp."spPurchasePrice"
                      order by spp."datePurchasePriceEffective" desc))[1] as "spPurchasePrice"
    from fd."PurchasePricesOfSupplierProducts" spp
             join fd."SupplierProducts" sprd
                  on sprd."supplierProductUID" = spp."supplierProductUID"
                      and sprd."isPrimarySupplierProduct"
    where spp."datePurchasePriceEffective" <= now()::date
    group by sprd."productUID"
    --
)
select cpp."productUID", prd."productSKU", cpp."spPurchasePrice"
from "CurrentPurchasePrice" cpp
         join fd."Products" prd on prd."productUID" = cpp."productUID";

alter materialized view fd."CurrentPurchasePricesCached" owner to postgres;

