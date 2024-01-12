with "DataValidationTests" as (
--
    select --
           'tst_myynti'                   as "tableName",
           'invalid customers'            as "validationTest",
           (--
               select count(*) cnt
               from incoming.tst_myynti sls
                        left join incoming.tst_asiakas cus
                                  on cus.asiakas = sls.asiakas
               where cus.asiakas is null) as "invalidRecords"
    union
    select --
           'tst_myynti'                 as "tableName",
           'invalid products'           as "validationTest",
           (--
               select count(*) cnt
               from incoming.tst_myynti sls
                        left join incoming.tst_tuote prd
                                  on prd.tuote = sls.tuote
               where prd.tuote is null) as "invalidRecords"
    union
    select --
           'tst_tuote'                       as "tableName",
           'invalid categories'              as "validationTest",
           (--
               select count(*) cnt
               from incoming.tst_tuote prd
                        left join incoming.tst_tuoteryhma cat
                                  on cat.tuoteryhma = prd.tuoteryhma
               where cat.tuoteryhma is null) as "invalidRecords"
    union
    select --
           'tst_ostohinta'                         as "tableName",
           'invalid supplier products'             as "validationTest",
           (--
               select count(*) cnt
               from incoming.tst_ostohinta ppp
                        left join (select *
                                   from incoming.tst_toimittajatuote st
                                            join incoming.tst_tuote rt on rt.tuote = st.tuote) sprd
                                  on sprd.toimittajatuote = ppp.toimittajatuote
               where sprd.toimittajatuote is null) as "invalidRecords"
    union
    select --
           'tst_saldo'                  as "tableName",
           'invalid products'           as "validationTest",
           (--
               select count(*)
               from incoming.tst_saldo sl
                        left join incoming.tst_tuote prd
                                  on prd.tuote = sl.tuote
               where prd.tuote is null) as "invalidRecords"
    union
    select --
           'tst_toimittajatuote'        as "tableName",
           'invalid products'           as "validationTest",
           (--
               select count(*)
               from incoming.tst_toimittajatuote spr
                        left join incoming.tst_tuote prd
                                  on prd.tuote = spr.tuote
               where prd.tuote is null) as "invalidRecords"
    --
)
select --
       dvt."tableName",
       dvt."validationTest",
       case when dvt."invalidRecords" = 0 then '✓' else '' end as "passedValidation",
       dvt."invalidRecords"
from "DataValidationTests" dvt
order by "tableName", "validationTest";
