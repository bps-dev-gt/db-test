create view fd."SplitProductSales" as
with "SplitProductSales" as (
--
    select --
           sls.*,
           unnest(regexp_split_to_array(lpad('', sls."productSaleAmount"::integer), '')) as splitter
    from fd."ProductSales" sls
    --
)
select --
       sps."productSaleUID",
       sps."customerUID",
       sps."productUID",
       sps."productSalePrice",
       sps."productSaleAmount",
       row_number() over (partition by sps."productSaleUID") as "productSaleItemOrder"
from "SplitProductSales" sps;

alter table fd."SplitProductSales"
    owner to postgres;

