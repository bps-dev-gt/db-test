create view fd."CurrentAndPreviousPurchasePrices" as
select --
       sprd."productUID",
       max(spp."datePurchasePriceEffective")                                 as "dateCurrentPurchasePriceEffective",
       (array_agg(spp."spPurchasePrice"
                  order by spp."datePurchasePriceEffective" desc))[1]        as "spCurrentPurchasePrice",
       (array_agg(spp."datePurchasePriceEffective"
                  order by spp."datePurchasePriceEffective" desc))[2]        as "datePreviousPurchasePriceEffective",
       (array_agg(spp."spPurchasePrice"
                  order by spp."datePurchasePriceEffective" desc))[2]        as "spPreviousPurchasePrice",
       ((array_agg(spp."spPurchasePrice"
                   order by spp."datePurchasePriceEffective" desc))[2]
           - (array_agg(spp."spPurchasePrice"
                        order by spp."datePurchasePriceEffective" desc))[1]) as "priceChange",
       round(((array_agg(spp."spPurchasePrice"
                         order by spp."datePurchasePriceEffective" desc))[2]
           - (array_agg(spp."spPurchasePrice"
                        order by spp."datePurchasePriceEffective" desc))[1]) /
             ((array_agg(spp."spPurchasePrice"
                         order by spp."datePurchasePriceEffective" desc))[2] /
              100), 2)                                                       as "priceChangePrc"
from fd."PurchasePricesOfSupplierProducts" spp
         join fd."SupplierProducts" sprd
              on sprd."supplierProductUID" = spp."supplierProductUID"
                  and sprd."isPrimarySupplierProduct"
where spp."datePurchasePriceEffective" <= now()::date
group by sprd."productUID"
having (array_agg(spp."spPurchasePrice"
                  order by spp."datePurchasePriceEffective" desc))[2] is not null;

alter table fd."CurrentAndPreviousPurchasePrices"
    owner to postgres;