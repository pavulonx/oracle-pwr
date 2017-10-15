ALTER SESSION SET NLS_DATE_FORMAT = 'yyyy-mm-dd';

-- ALTER TABLE KOCURY DROP CONSTRAINT KOC_FUNKCJA_TO_FUN_FUNKCJA_FK;
-- ALTER TABLE KOCURY DROP CONSTRAINT KOC_SZEF_TO_KOC_PSEUDO_FK;
-- ALTER TABLE KOCURY DROP CONSTRAINT KOC_NR_BAND_TO_BND_NR_BANDY_FK;
-- ALTER TABLE BANDY DROP CONSTRAINT BND_SZEF_BANDY_TO_KOC_PSEUD_FK;
-- DROP TABLE WROGOWIE;
-- DROP TABLE WROGOWIE_KOCUROW;
-- DROP TABLE BANDY;
-- DROP TABLE KOCURY;
-- DROP TABLE FUNKCJE;

CREATE TABLE BANDY (--bnd
  nr_bandy   NUMBER(2) CONSTRAINT bnd_nr_bandy_pk PRIMARY KEY,
  nazwa      VARCHAR2(20) CONSTRAINT bnd_nazwa_nn NOT NULL,
  teren      VARCHAR2(15) CONSTRAINT bnd_teren_unq UNIQUE,
  szef_bandy VARCHAR2(15) CONSTRAINT bnd_szef_bandy_unq UNIQUE
);

CREATE TABLE FUNKCJE (-- fun
  funkcja   VARCHAR2(10) CONSTRAINT fun_funkcja_pk PRIMARY KEY,
  min_myszy NUMBER(3) CONSTRAINT fun_min_myszy_gt CHECK (min_myszy > 5),
  max_myszy NUMBER(3) CONSTRAINT fun_max_myszy_lt CHECK (max_myszy < 200),
  CONSTRAINT fun_max_myszy_geq_min_myszy CHECK (max_myszy >= min_myszy)
);

CREATE TABLE WROGOWIE (--wrg
  imie_wroga       VARCHAR2(15) CONSTRAINT wrg_imie_wroga_pk PRIMARY KEY,
  stopien_wrogosci NUMBER(2) CONSTRAINT wrg_stopien_wrogosci_bt CHECK (stopien_wrogosci BETWEEN 1 AND 10),
  gatunek          VARCHAR2(15),
  lapowka          VARCHAR2(20)
);

CREATE TABLE KOCURY (-- koc
  imie            VARCHAR2(15) CONSTRAINT koc_imie_nn NOT NULL,
  plec            CHAR(1) CONSTRAINT koc_plec_in CHECK (plec IN ('M', 'D')),
  pseudo          VARCHAR2(15) CONSTRAINT koc_pseudo_pk PRIMARY KEY,
  funkcja         VARCHAR2(10) CONSTRAINT koc_funkcja_to_fun_funkcja_fk REFERENCES FUNKCJE (funkcja),
  szef            VARCHAR2(15) CONSTRAINT koc_szef_to_koc_pseudo_fk REFERENCES KOCURY (pseudo),
  w_stadku_od     DATE DEFAULT SYSDATE,
  przydzial_myszy NUMBER(3),
  myszy_extra     NUMBER(3),
  nr_bandy        NUMBER(2) CONSTRAINT koc_nr_band_to_bnd_nr_bandy_fk REFERENCES BANDY (nr_bandy)
);

ALTER TABLE BANDY
  ADD CONSTRAINT bnd_szef_bandy_to_koc_pseud_fk FOREIGN KEY (szef_bandy) REFERENCES KOCURY (pseudo);

CREATE TABLE WROGOWIE_KOCUROW (-- wrgk
  pseudo         VARCHAR2(15) CONSTRAINT wrgk_pseudo_to_koc_pseudo_fk REFERENCES KOCURY (pseudo),
  imie_wroga     VARCHAR2(15) CONSTRAINT wrgk_im_wrg_to_wrg_im_wrga_fk REFERENCES WROGOWIE (imie_wroga),
  data_incydentu DATE CONSTRAINT wrog_koc_data_incydentu_nn NOT NULL,
  opis_incydentu VARCHAR2(50),
  CONSTRAINT wrgk_pseudo_and_im_wrga_pk PRIMARY KEY (pseudo, imie_wroga)
);
