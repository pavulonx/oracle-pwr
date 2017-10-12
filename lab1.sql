ALTER SESSION SET NLS_DATE_FORMAT = 'yyyy-mm-dd';

-- DROP TABLE BANDY;
-- DROP TABLE FUNKCJE;
-- DROP TABLE WROGOWIE;
-- DROP TABLE KOCURY;
-- DROP TABLE WROGOWIE_KOCUROW;

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
  nr_bandy        NUMBER(2) CONSTRAINT koc_nr_bandy_to_bnd_nr_bandy_fk REFERENCES BANDY (nr_bandy)
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

ALTER TABLE KOCURY
  DISABLE CONSTRAINT kocury_pseudo_fk;

ALTER TABLE KOCURY
  DISABLE CONSTRAINT bandy_nr_bandy_fk;

ALTER TABLE KOCURY
  DISABLE CONSTRAINT funkcje_funkcja_fk;

INSERT ALL
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('JACEK', 'M', 'PLACEK', 'LOWCZY', 'LYSY', '2008-12-01', 67, NULL, 2)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('BARI', 'M', 'RURA', 'LAPACZ', 'LYSY', '2009-09-01', 56, NULL, 2)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('MICKA', 'D', 'LOLA', 'MILUSIA', 'TYGRYS', '2009-10-14', 25, 47, 1)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('LUCEK', 'M', 'ZERO', 'KOT', 'KURKA', '2010-03-01', 43, NULL, 3)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('SONIA', 'D', 'PUSZYSTA', 'MILUSIA', 'ZOMBI', '2010-11-18', 20, 35, 3)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('LATKA', 'D', 'UCHO', 'KOT', 'RAFA', '2011-01-01', 40, NULL, 4)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('DUDEK', 'M', 'MALY', 'KOT', 'RAFA', '2011-05-15', 40, NULL, 4)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('MRUCZEK', 'M', 'TYGRYS', 'SZEFUNIO', NULL, '2002-01-01', 103, 33, 1)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('CHYTRY', 'M', 'BOLEK', 'DZIELCZY', 'TYGRYS', '2002-05-05', 50, NULL, 1)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('KOREK', 'M', 'ZOMBI', 'BANDZIOR', 'TYGRYS', '2004-03-16', 75, 13, 3)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('BOLEK', 'M', 'LYSY', 'BANDZIOR', 'TYGRYS', '2006-08-15', 72, 21, 2)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('ZUZIA', 'D', 'SZYBKA', 'LOWCZY', 'LYSY', '2006-07-21', 65, NULL, 2)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('RUDA', 'D', 'MALA', 'MILUSIA', 'TYGRYS', '2006-09-17', 22, 42, 1)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('PUCEK', 'M', 'RAFA', 'LOWCZY', 'TYGRYS', '2006-10-15', 65, NULL, 4)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('PUNIA', 'D', 'KURKA', 'LOWCZY', 'ZOMBI', '2008-01-01', 61, NULL, 3)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('BELA', 'D', 'LASKA', 'MILUSIA', 'LYSY', '2008-02-01', 24, 28, 2)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('KSAWERY', 'M', 'MAN', 'LAPACZ', 'RAFA', '2008-07-12', 51, NULL, 4)
INTO KOCURY (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy)
VALUES ('MELA', 'D', 'DAMA', 'LAPACZ', 'RAFA', '2008-11-01', 51, NULL, 4)
SELECT 1
FROM KOCURY;


ALTER TABLE KOCURY
  ENABLE CONSTRAINT kocury_pseudo_fk;

ALTER TABLE KOCURY
  ENABLE CONSTRAINT bandy_nr_bandy_fk;

ALTER TABLE KOCURY
  ENABLE CONSTRAINT funkcje_funkcja_fk;


COMMIT;
