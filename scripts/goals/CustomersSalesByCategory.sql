create view fd."CustomersSalesByCategory" as
with "CustomersSalesByCategory" as (
--
    select --
           sls."customerUID",
           sls."productUID",
           prd."productCategoryUID",
           cat."productCategoryName",
           sls."productSalePrice",
           sls."productSaleAmount",
           (sls."productSalePrice" * sls."productSaleAmount"::numeric)::numeric as "productSalesSum"
    from fd."ProductSales" sls
             join fd."Products" prd on prd."productUID" = sls."productUID"
             join fd."ProductCategories" cat on cat."productCategoryUID" = prd."productCategoryUID"
             left join fd."StockOfProducts" stl on stl."productUID" = sls."productUID"
    where stl."productUID" is null)
select --
       ss."customerUID",
       ss."productCategoryUID",
       max(ss."productCategoryName") as "productCategoryName",
       sum(ss."productSalesSum")     as "toalSalesForCategory"
from "CustomersSalesByCategory" ss
group by ss."customerUID", ss."productCategoryUID"
order by ss."customerUID", ss."productCategoryUID";

alter table fd."CustomersSalesByCategory"
    owner to postgres;

