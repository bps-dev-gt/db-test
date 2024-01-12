create table incoming.tst_asiakas
(
    asiakas     integer not null,
    asiakasnimi text,
    email       text,
    aikaleima   timestamp without time zone,
    constraint pk_tst_asiakas primary key (asiakas)
)
    with (
        oids= false
    );
alter table incoming.tst_asiakas
    owner to postgres;


create table incoming.tst_tuoteryhma
(
    tuoteryhma     integer not null,
    tuoteryhmanimi text,
    constraint pk_tst_tuoteryhma primary key (tuoteryhma)
)
    with (
        oids= false
    );
alter table incoming.tst_tuoteryhma
    owner to postgres;


create table incoming.tst_tuote
(
    tuote      integer not null,
    koodi      character varying(25),
    tuoteryhma integer,
    constraint pk_tst_tuote primary key (tuote)
)
    with (
        oids= false
    );
alter table incoming.tst_tuote
    owner to postgres;


create table incoming.tst_toimittajatuote
(
    toimittajatuote      integer not null,
    tuote                integer,
    toimittajatuotekoodi character varying(20),
    oletustoimittaja     boolean,
    constraint pk_tst_toimittajatuote primary key (toimittajatuote)
)
    with (
        oids= false
    );
alter table incoming.tst_toimittajatuote
    owner to postgres;


create table incoming.tst_myynti
(
    asiakas integer not null,
    tuote   integer not null,
    kpl     bigint,
    hinta   numeric,
    pvm     date,
    constraint pk_tst_myynti primary key (asiakas, tuote)
)
    with (
        oids= false
    );
alter table incoming.tst_myynti
    owner to postgres;


create table incoming.tst_ostohinta
(
    toimittajatuote integer,
    hinta           numeric,
    pvm             date
)
    with (
        oids= false
    );
alter table incoming.tst_ostohinta
    owner to postgres;


create table incoming.tst_saldo
(
    tuote integer not null,
    saldo integer,
    constraint pk_tst_saldo primary key (tuote)
)
    with (
        oids= false
    );
alter table incoming.tst_saldo
    owner to postgres;
