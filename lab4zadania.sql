DROP TYPE KOTO;
DROP TABLE KOTYR;


DROP TYPE PLEBS;
DROP TABLE PLEBSY;

DROP TYPE ELITA;
DROP TABLE ELITY;

DROP TYPE KONTO;
DROP TABLE KONTA;

DROP TYPE INCYDENT;
DROP TABLE INCYDENTYr;

drop table kotyr;
drop table plebsr;
drop table elitar;
drop table incydentyr;
drop table kontor;
drop type konto;
drop type elita;
drop type plebs;
drop type incydent;
drop type koty;





ROLLBACK ;
ALTER SESSION SET NLS_DATE_FORMAT = 'yyyy-mm-dd';

CREATE OR REPLACE TYPE KOTO AS OBJECT
(
  imie VARCHAR2(15),
  plec VARCHAR2(1),
  pseudo VARCHAR2(15),
  funkcja VARCHAR2(10),
  szef VARCHAR2(15),
  w_stadku_od DATE,
  przydzial_myszy NUMBER(3),
  myszy_extra NUMBER(3),
  nr_bandy NUMBER(2),
  MEMBER FUNCTION myszy_lacznie RETURN NUMBER,
  MEMBER FUNCTION daj_imie RETURN VARCHAR2,
  MEMBER FUNCTION czy_ma_szefa RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY KOTO AS
    MEMBER FUNCTION myszy_lacznie RETURN NUMBER
    IS
    BEGIN
      RETURN nvl(przydzial_myszy,0) + nvl(myszy_extra,0);
    END;
    MEMBER FUNCTION daj_imie RETURN VARCHAR2
    IS
    BEGIN
      RETURN imie;
    END;
    MEMBER FUNCTION czy_ma_szefa RETURN VARCHAR2
    IS
    BEGIN
      IF szef IS NULL THEN
        RETURN 'Nie ma szefa';
        ELSE
        RETURN 'Ma szefa';
      END IF;
    END;
END;


CREATE TABLE KOTYR OF KOTO
(
  CONSTRAINT ok_im_nn CHECK(imie IS NOT NULL),
  CONSTRAINT ok_p_md CHECK (plec IN ('M', 'D')),
  CONSTRAINT ok_pk PRIMARY KEY (pseudo),
  w_stadku_od DEFAULT (SYSDATE)
);
SELECT * FROM KOTYR;

INSERT INTO KOTYR VALUES ('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2);
INSERT INTO KOTYR VALUES ('BARI','M','RURA','LAPACZ','LYSY','2009-09-01',56,NULL,2);
INSERT INTO KOTYR VALUES ('MICKA','D','LOLA','MILUSIA','TYGRYS','2009-10-14',25,47,1);
INSERT INTO KOTYR VALUES ('LUCEK','M','ZERO','KOT','KURKA','2010-03-01',43,NULL,3);
INSERT INTO KOTYR VALUES ('SONIA','D','PUSZYSTA','MILUSIA','ZOMBI','2010-11-18',20,35,3);
INSERT INTO KOTYR VALUES ('LATKA','D','UCHO','KOT','RAFA','2011-01-01',40,NULL,4);
INSERT INTO KOTYR VALUES ('DUDEK','M','MALY','KOT','RAFA','2011-05-15',40,NULL,4);
INSERT INTO KOTYR VALUES ('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,'2002-01-01',103,33,1);
INSERT INTO KOTYR VALUES ('CHYTRY','M','BOLEK','DZIELCZY','TYGRYS','2002-05-05',50,NULL,1);
INSERT INTO KOTYR VALUES ('KOREK','M','ZOMBI','BANDZIOR','TYGRYS','2004-03-16',75,13,3);
INSERT INTO KOTYR VALUES ('BOLEK','M','LYSY','BANDZIOR','TYGRYS','2006-08-15',72,21,2);
INSERT INTO KOTYR VALUES ('ZUZIA','D','SZYBKA','LOWCZY','LYSY','2006-07-21',65,NULL,2);
INSERT INTO KOTYR VALUES ('RUDA','D','MALA','MILUSIA','TYGRYS','2006-09-17',22,42,1);
INSERT INTO KOTYR VALUES ('PUCEK','M','RAFA','LOWCZY','TYGRYS','2006-10-15',65,NULL,4);
INSERT INTO KOTYR VALUES ('PUNIA','D','KURKA','LOWCZY','ZOMBI','2008-01-01',61,NULL,3);
INSERT INTO KOTYR VALUES ('BELA','D','LASKA','MILUSIA','LYSY','2008-02-01',24,28,2);
INSERT INTO KOTYR VALUES ('KSAWERY','M','MAN','LAPACZ','RAFA','2008-07-12',51,NULL,4);
INSERT INTO KOTYR VALUES ('MELA','D','DAMA','LAPACZ','RAFA','2008-11-01',51,NULL,4);

SELECT K.czy_ma_szefa() FROM KOTYR K WHERE K.pseudo = 'PLACEK';
SELECT K.czy_ma_szefa() FROM KOTYR K WHERE K.pseudo = 'TYGRYS';
SELECT VALUE(K).imie FROM KOTYR K;
SELECT ref(K) FROM KOTYR K;

CREATE OR REPLACE TYPE INCYDENT AS OBJECT
(
  nr_incydentu NUMBER,
  kot REF KOTO,
  imie_wroga VARCHAR2(15),
  data_incydentu DATE,
	opis_incydentu VARCHAR2(50),
  MEMBER FUNCTION to_string RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY INCYDENT AS
  MEMBER FUNCTION to_string
    RETURN VARCHAR2
  IS
    BEGIN
      RETURN 'Incydent { ' ||
             'nr_incydentu: ' || nr_incydentu ||
             ', imie_wroga: ' || imie_wroga ||
             ', data_incydentu: ' || data_incydentu ||
             ', opis_incydentu: ' || opis_incydentu ||
             ' }';
    END;
END;

show errors;
-- DROP TABLE IncydentyR;
-- DROP type Incydent;
CREATE TABLE IncydentyR OF INCYDENT
(
  kot SCOPE IS KOTYR CONSTRAINT inc_kot_nn NOT NULL,
  imie_wroga CONSTRAINT inc_imie_wroga_nn NOT NULL,
  CONSTRAINT inc_zlozony_pk PRIMARY KEY (nr_incydentu)
);

SELECT * from IncydentyR;


-- ALTER SESSION SET NLS_DATE_FORMAT = 'yyyy-mm-dd';
-- EXECUTE EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''yyyy-mm-dd'';
-- INSERT INTO IncydentyR SELECT 1,REF(K),''KAZIO'',''2004-10-13'',''USILOWAL NABIC NA WIDLY'' FROM KOTYR K WHERE K.pseudo=''TYGRYS'';
-- INSERT INTO IncydentyR SELECT 2,REF(K),''SWAWOLNY DYZIO'',''2005-03-07'',''WYBIL OKO Z PROCY'' FROM KOTYR K WHERE K.pseudo=''ZOMBI'';
-- INSERT INTO IncydentyR SELECT 3,REF(K),''KAZIO'',''2005-03-29'',''POSZCZUL BURKIEM'' FROM KOTYR K WHERE K.pseudo=''BOLEK'';
-- INSERT INTO IncydentyR SELECT 4,REF(K),''GLUPIA ZOSKA'',''2006-09-12'',''UZYLA KOTA JAKO SCIERKI'' FROM KOTYR K WHERE K.pseudo=''SZYBKA'';
-- INSERT INTO IncydentyR SELECT 5,REF(K),''CHYTRUSEK'',''2007-03-07'',''ZALECAL SIE'' FROM KOTYR K WHERE K.pseudo=''MALA'';
-- INSERT INTO IncydentyR SELECT 6,REF(K),''DZIKI BILL'',''2007-06-12'',''USILOWAL POZBAWIC ZYCIA'' FROM KOTYR K WHERE K.pseudo=''TYGRYS'';
-- INSERT INTO IncydentyR SELECT 7,REF(K),''DZIKI BILL'',''2007-11-10'',''ODGRYZL UCHO'' FROM KOTYR K WHERE K.pseudo=''BOLEK'';
-- INSERT INTO IncydentyR SELECT 8,REF(K),''DZIKI BILL'',''2008-12-12'',''POGRYZL ZE LEDWO SIE WYLIZALA'' FROM KOTYR K WHERE K.pseudo=''LASKA'';
-- INSERT INTO IncydentyR SELECT 9,REF(K),''KAZIO'',''2009-01-07'',''ZLAPAL ZA OGON I ZROBIL WIATRAK'' FROM KOTYR K WHERE K.pseudo=''LASKA'';
-- INSERT INTO IncydentyR SELECT 10,REF(K),''KAZIO'',''2009-02-07'',''CHCIAL OBEDRZEC ZE SKORY'' FROM KOTYR K WHERE K.pseudo=''DAMA'';
-- INSERT INTO IncydentyR SELECT 11,REF(K),''REKSIO'',''2009-04-14'',''WYJATKOWO NIEGRZECZNIE OBSZCZEKAL'' FROM KOTYR K WHERE K.pseudo=''MAN'';
-- INSERT INTO IncydentyR SELECT 12,REF(K),''BETHOVEN'',''2009-05-11'',''NIE PODZIELIL SIE SWOJA KASZA''FROM KOTYR K WHERE K.pseudo=''LYSY'';
-- INSERT INTO IncydentyR SELECT 13,REF(K),''DZIKI BILL'',''2009-09-03'',''ODGRYZL OGON'' FROM KOTYR K WHERE K.pseudo=''RURA'';
-- INSERT INTO IncydentyR SELECT 14,REF(K),''BAZYLI'',''2010-07-12'',''DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA'' FROM KOTYR K WHERE K.pseudo=''PLACEK'';
-- INSERT INTO IncydentyR SELECT 15,REF(K),''SMUKLA'',''2010-11-19'',''OBRZUCILA SZYSZKAMI'' FROM KOTYR K WHERE K.pseudo=''PUSZYSTA'';
-- INSERT INTO IncydentyR SELECT 16,REF(K),''BUREK'',''2010-12-14'',''POGONIL'' FROM KOTYR K WHERE K.pseudo=''KURKA'';
-- INSERT INTO IncydentyR SELECT 17,REF(K),''CHYTRUSEK'',''2011-07-13'',''PODEBRAL PODEBRANE JAJKA'' FROM KOTYR K WHERE K.pseudo=''MALY'';
-- INSERT INTO IncydentyR SELECT 18,REF(K),''SWAWOLNY DYZIO'',''2011-07-14'',''OBRZUCIL KAMIENIAMI'' FROM KOTYR K WHERE K.pseudo=''UCHO'';'


ALTER SESSION SET NLS_DATE_FORMAT = 'yyyy-mm-dd';

SELECT 1,REF(K),'KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY' FROM KOTYR K WHERE K.pseudo='TYGRYS';

INSERT INTO IncydentyR SELECT 1,REF(K),'KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY' FROM KOTYR K WHERE K.pseudo='TYGRYS';
INSERT INTO IncydentyR SELECT 2,REF(K),'SWAWOLNY DYZIO','2005-03-07','WYBIL OKO Z PROCY' FROM KOTYR K WHERE K.pseudo='ZOMBI';
INSERT INTO IncydentyR SELECT 3,REF(K),'KAZIO','2005-03-29','POSZCZUL BURKIEM' FROM KOTYR K WHERE K.pseudo='BOLEK';
INSERT INTO IncydentyR SELECT 4,REF(K),'GLUPIA ZOSKA','2006-09-12','UZYLA KOTA JAKO SCIERKI' FROM KOTYR K WHERE K.pseudo='SZYBKA';
INSERT INTO IncydentyR SELECT 5,REF(K),'CHYTRUSEK','2007-03-07','ZALECAL SIE' FROM KOTYR K WHERE K.pseudo='MALA';
INSERT INTO IncydentyR SELECT 6,REF(K),'DZIKI BILL','2007-06-12','USILOWAL POZBAWIC ZYCIA' FROM KOTYR K WHERE K.pseudo='TYGRYS';
INSERT INTO IncydentyR SELECT 7,REF(K),'DZIKI BILL','2007-11-10','ODGRYZL UCHO' FROM KOTYR K WHERE K.pseudo='BOLEK';
INSERT INTO IncydentyR SELECT 8,REF(K),'DZIKI BILL','2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA' FROM KOTYR K WHERE K.pseudo='LASKA';;;
INSERT INTO IncydentyR SELECT 9,REF(K),'KAZIO','2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK' FROM KOTYR K WHERE K.pseudo='LASKA';
INSERT INTO IncydentyR SELECT 10,REF(K),'KAZIO','2009-02-07','CHCIAL OBEDRZEC ZE SKORY' FROM KOTYR K WHERE K.pseudo='DAMA';
INSERT INTO IncydentyR SELECT 11,REF(K),'REKSIO','2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL' FROM KOTYR K WHERE K.pseudo='MAN';
INSERT INTO IncydentyR SELECT 12,REF(K),'BETHOVEN','2009-05-11','NIE PODZIELIL SIE SWOJA KASZA'FROM KOTYR K WHERE K.pseudo='LYSY';
INSERT INTO IncydentyR SELECT 13,REF(K),'DZIKI BILL','2009-09-03','ODGRYZL OGON' FROM KOTYR K WHERE K.pseudo='RURA';
INSERT INTO IncydentyR SELECT 14,REF(K),'BAZYLI','2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA' FROM KOTYR K WHERE K.pseudo='PLACEK';
INSERT INTO IncydentyR SELECT 15,REF(K),'SMUKLA','2010-11-19','OBRZUCILA SZYSZKAMI' FROM KOTYR K WHERE K.pseudo='PUSZYSTA';
INSERT INTO IncydentyR SELECT 16,REF(K),'BUREK','2010-12-14','POGONIL' FROM KOTYR K WHERE K.pseudo='KURKA';
INSERT INTO IncydentyR SELECT 17,REF(K),'CHYTRUSEK','2011-07-13','PODEBRAL PODEBRANE JAJKA' FROM KOTYR K WHERE K.pseudo='MALY';
INSERT INTO IncydentyR SELECT 18,REF(K),'SWAWOLNY DYZIO','2011-07-14','OBRZUCIL KAMIENIAMI' FROM KOTYR K WHERE K.pseudo='UCHO';
-- SELECT I.to_string() from INCYDENTYR i WHERE i.NR_INCYDENTU = 1;
--drop table incydentyR;
--SELECT * FROM IncydentyR;

CREATE OR REPLACE TYPE PLEBS AS OBJECT
(
  nr_kota NUMBER(3),
  kot REF KOTO,
  MEMBER FUNCTION daj_pseudo_pana RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY PLEBS AS
  MEMBER FUNCTION daj_pseudo_pana RETURN VARCHAR2 IS
  ps_pana VARCHAR2(15);

	BEGIN
		SELECT E.kot.pseudo INTO ps_pana
		FROM ElitaR E
		WHERE DEREF(E.sluga) = SELF;
		RETURN ps_pana;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN RETURN 'brak pana';
	END;
END;
 show errors;
CREATE TABLE PlebsR OF PLEBS
(
  kot SCOPE IS KOTYR CONSTRAINT pl_kot_nn NOT NULL,
  CONSTRAINT nr_kot_pk PRIMARY KEY (nr_kota)
);
--drop table plebsr;

set SERVEROUTPUT ON;

DECLARE
i NUMBER := 1;
BEGIN
  FOR elem IN (SELECT pseudo FROM Kocury WHERE (nvl(przydzial_myszy,0) + nvl(myszy_extra,0)) < 70)
  LOOP
    INSERT INTO PlebsR
    SELECT i, REF(K) FROM KOTYR K WHERE K.pseudo = elem.pseudo;
    dbms_output.put_line(i);
    i := i + 1;
  END LOOP;
END;

--select count(*) FROM Kocury WHERE (nvl(myszy_extra,0)+nvl(przydzial_myszy,0)) > 90;
--SELECT P.nr_kota, nvl(P.kot.myszy_extra,0)+nvl(P.kot.przydzial_myszy,0) FROM PlebsR P;

--------------------------------------------
CREATE OR REPLACE TYPE ELITA AS OBJECT
(
  nr_kota NUMBER(3),
  kot REF KOTO,
  sluga REF PLEBS,
  MEMBER FUNCTION myszy_na_koncie RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY ELITA AS
  MEMBER FUNCTION myszy_na_koncie RETURN NUMBER IS
  ile NUMBER;
	BEGIN
		SELECT COUNT(*) INTO ile
		FROM KontoR K
		WHERE DEREF(K.kot_elita) = SELF;
		RETURN ile;
	END;
END;

CREATE TABLE ElitaR OF ELITA
(
  kot SCOPE IS KOTYR CONSTRAINT eli_kotr_nn NOT NULL,
  sluga SCOPE IS PlebsR CONSTRAINT eli_slugar_nn NOT NULL,
  CONSTRAINT nr_kota_eli_pk PRIMARY KEY (nr_kota)
);

-- drop table elitar;
-- drop type elita;

DECLARE
i NUMBER := 1;
BEGIN
  FOR elem IN (SELECT pseudo FROM Kocury WHERE (nvl(przydzial_myszy,0) + nvl(myszy_extra,0)) > 90)
  LOOP
    INSERT INTO ElitaR
    SELECT i, REF(K), (SELECT REF(P) FROM PlebsR P WHERE nr_kota = i) FROM KOTYR K WHERE K.pseudo = elem.pseudo;
    dbms_output.put_line(i);
    i := i + 1;
  END LOOP;
END;

SELECT P.nr_kota, P.kot.pseudo FROM PlebsR P;
SELECT E.kot.pseudo,E.sluga.kot.pseudo
FROM ElitaR E;

CREATE OR REPLACE TYPE KONTO AS OBJECT
(
  nr_myszy NUMBER(5),
  kot_elita REF ELITA,
  data_wprowadzenia DATE,
  data_usuniecia DATE,
  MEMBER FUNCTION czasu_na_koncie RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY KONTO AS
  MEMBER FUNCTION czasu_na_koncie RETURN NUMBER
  IS
  BEGIN
    IF data_usuniecia IS NULL THEN
      RETURN SYSDATE - data_wprowadzenia;
    ELSE
      RETURN data_usuniecia - data_wprowadzenia;
    END IF;
  END;
END;

CREATE TABLE KontoR OF KONTO
(
  kot_elita SCOPE IS ElitaR CONSTRAINT ko_kot_e_nn NOT NULL,
  data_wprowadzenia DEFAULT SYSDATE,
  CONSTRAINT nr_kontor_pk PRIMARY KEY (nr_myszy)
);

 INSERT INTO KontoR
 SELECT 1,REF(E),SYSDATE,NULL FROM ElitaR E WHERE E.nr_kota = 1;
  INSERT INTO KontoR
 SELECT 4,REF(E),SYSDATE,NULL FROM ElitaR E WHERE E.nr_kota = 1;
  INSERT INTO KontoR
 SELECT 2,REF(E),SYSDATE,NULL FROM ElitaR E WHERE E.nr_kota = 2;
  INSERT INTO KontoR
 SELECT 3,REF(E),SYSDATE,NULL FROM ElitaR E WHERE E.nr_kota = 3;

/*ZAD Z LIST*/
--zad 18
SELECT K1.imie, K1.w_stadku_od "Poluje od"
FROM KotyR K1 JOIN KotyR K2
                ON K2.imie='JACEK' AND K1.w_stadku_od < K2.w_stadku_od
ORDER BY K1.w_stadku_od DESC;

--27--
SELECT
  k.PSEUDO,
  (NVL(k.PRZYDZIAL_MYSZY, 0) + NVL(k.MYSZY_EXTRA, 0)) "ZJADA"
FROM kotyr K
WHERE &HOWMANY > (
  SELECT DISTINCT COUNT(NVL(kn.PRZYDZIAL_MYSZY, 0) + NVL(kn.MYSZY_EXTRA, 0))
  FROM kotyr kn
  WHERE NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0) < NVL(kn.PRZYDZIAL_MYSZY, 0) + NVL(kn.MYSZY_EXTRA, 0)
)
ORDER BY 2 DESC;


 --34
DECLARE
kocury_f VARCHAR2(255);
BEGIN
  SELECT min(funkcja) INTO kocury_f
  FROM KotyR
  WHERE funkcja = 'LOWCZY'
--   WHERE funkcja = 'nie ma takiejfunkcji'
  GROUP BY funkcja;
  dbms_output.put_line(kocury_f);
EXCEPTION
  WHEN NO_DATA_FOUND
  THEN dbms_output.put_line('Nie znaleziono kota o podanej funkcji !');
END;


-- zad 35
DECLARE
  kocury_przydzial NUMBER;
  kocury_imie      VARCHAR2(255);
  kocury_wstad     DATE;
  kocury_bool      BOOLEAN := TRUE;
BEGIN
  SELECT
    (nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0)) * 12,
    imie,
    w_stadku_od
  INTO kocury_przydzial, kocury_imie, kocury_wstad
  FROM KOTYR k
  WHERE k.pseudo = 'TYGRYS'; --'&pseudo'

  IF kocury_przydzial > 700
  THEN
    dbms_output.put_line('calkowity roczny przydzial myszy > 700');
    kocury_bool := FALSE;
  END IF;
  IF kocury_imie LIKE '%A%'
  THEN
    dbms_output.put_line('imie zawiera litere A');
    kocury_bool := FALSE;
  END IF;
  IF extract(MONTH FROM kocury_wstad) = 1
  THEN
    dbms_output.put_line('styczen jest miesiacem przystapienia do stada');
    kocury_bool := FALSE;
  END IF;
  IF kocury_bool
  THEN
    dbms_output.put_line('nie odpowiada kryteriom');
  END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND
  THEN dbms_output.put_line('Niepoprawny pseudonim kota');
END;



---

