create schema if not exists sanitized;
alter schema sanitized owner to postgres;

/**
  Sanitize the tst_myynti
 */
drop table if exists sanitized.san_tst_myynti;

select sls.*
into sanitized.san_tst_myynti
from incoming.tst_myynti sls
         join incoming.tst_asiakas cus
              on cus.asiakas = sls.asiakas
         join incoming.tst_tuote prd
              on prd.tuote = sls.tuote;

alter table sanitized.san_tst_myynti
    owner to postgres;

comment on table sanitized.san_tst_myynti
    is 'Sanitized tst_myynti';

/**
  Sanitize the tst_saldo
 */
drop table if exists sanitized.san_tst_saldo;

select sl.*
into sanitized.san_tst_saldo
from incoming.tst_saldo sl
         join incoming.tst_tuote prd
              on sl.tuote = prd.tuote;

alter table sanitized.san_tst_saldo
    owner to postgres;

comment on table sanitized.san_tst_saldo
    is 'Sanitized tst_saldo';

/**
  Sanitize the tst_toimittajatuote
 */
drop table if exists sanitized.san_tst_toimittajatuote;

select spr.*
into sanitized.san_tst_toimittajatuote
from incoming.tst_toimittajatuote spr
         join incoming.tst_tuote prd on spr.tuote = prd.tuote;

alter table sanitized.san_tst_toimittajatuote
    owner to postgres;

comment on table sanitized.san_tst_toimittajatuote
    is 'Sanitized tst_toimittajatuote';

/**
  Sanitize the tst_ostohinta
 */
drop table if exists sanitized.san_tst_ostohinta;

select ppp.*
into sanitized.san_tst_ostohinta
from incoming.tst_ostohinta ppp
         join sanitized.san_tst_toimittajatuote sprd
              on sprd.toimittajatuote = ppp.toimittajatuote;

alter table sanitized.san_tst_ostohinta
    owner to postgres;

comment on table sanitized.san_tst_ostohinta
    is 'Sanitized tst_ostohinta';

/**
  Add the tst_saldo, does not require cleanup.
 */
drop table if exists sanitized.san_tst_asiakas;

select *
into sanitized.san_tst_asiakas
from incoming.tst_asiakas;

alter table sanitized.san_tst_asiakas
    owner to postgres;

comment on table sanitized.san_tst_asiakas
    is 'Sanitized tst_asiakas';

/**
  Add the tst_tuote, does not require cleanup.
 */
drop table if exists sanitized.san_tst_tuote;

select *
into sanitized.san_tst_tuote
from incoming.tst_tuote;

alter table sanitized.san_tst_tuote
    owner to postgres;

comment on table sanitized.san_tst_tuote
    is 'Sanitized tst_tuote';

/**
  Add the tst_tuoteryhma, does not require cleanup.
 */
drop table if exists sanitized.san_tst_tuoteryhma;

select *
into sanitized.san_tst_tuoteryhma
from incoming.tst_tuoteryhma;

alter table sanitized.san_tst_tuoteryhma
    owner to postgres;

comment on table sanitized.san_tst_tuoteryhma
    is 'Sanitized tst_tuoteryhma';
