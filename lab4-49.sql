--zadanie 49--
ALTER SESSION SET nls_date_format = 'yyyy-mm-dd';
SET SERVEROUTPUT ON;
DROP TABLE myszy;
DECLARE
  q VARCHAR2(600) := 'CREATE TABLE MYSZY(
  nr_myszy NUMBER CONSTRAINT NR_M_PK PRIMARY KEY,
  lowca VARCHAR2(15) CONSTRAINT lowca_fk REFERENCES KOCURY(PSEUDO),
  zjadacz VARCHAR2(15) CONSTRAINT zjadacz_fk REFERENCES KOCURY(PSEUDO),
  waga_myszy NUMBER CONSTRAINT w_m_checkin CHECK (waga_myszy BETWEEN 15 and 45),
  data_zlowienia DATE CONSTRAINT dz_notnull NOT NULL,
  data_wydania DATE CONSTRAINT dw_ostatnia_sroda CHECK(data_wydania = (next_day(last_day(data_wydania)-7,''Wednesday''))),
  CONSTRAINT daty_ok CHECK (data_zlowienia <= data_wydania))';
BEGIN
  EXECUTE IMMEDIATE q;
  EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;


/*
fill data
*/
DECLARE
  TYPE PSEUDO_LICZBAMYSZY IS RECORD (pseudo Kocury.pseudo%TYPE, liczbaMyszy NUMBER(3));
  --tworzymy rekord trzymajacy pseudo i liczbe myszy
  --potrzebujemy tylko dwoch informacji wiec nie bierzemy np kocurow
  TYPE TYP_TABLICA_KOTOW IS TABLE OF PSEUDO_LICZBAMYSZY INDEX BY BINARY_INTEGER;
  -- kluczami tej tabeli sa binary integery
  tablica_kotow           TYP_TABLICA_KOTOW;

  TYPE TYP_TABLICA_MYSZY IS TABLE OF Myszy%ROWTYPE INDEX BY BINARY_INTEGER;
  tablica_myszy           TYP_TABLICA_MYSZY;

  ostatnia_sroda_miesiaca DATE := NEXT_DAY(LAST_DAY(TO_DATE('2004-01-01', 'YYYY-MM-DD')) - 7,
                                           'Wednesday');
  --ostatnia sroda od pierwszego dnia ewidencji, tu pierwsza wyplatka
  data_start              DATE := TO_DATE('2004-01-01', 'YYYY-MM-DD');
  data_end                DATE := TO_DATE('2018-01-09', 'YYYY-MM-DD');

  srednia_liczba_myszy    NUMBER;
  --że każdy kot jest w stanie upolować w ciągu miesiąca liczbę średnia spozywanychw miesiacu
  index_po_m_zlapanych    BINARY_INTEGER := 1;
  index_po_m_zjedzonych   BINARY_INTEGER := 1;

  data_zlowienia_pom      Myszy.data_zlowienia%TYPE;
  pseudonim_min_myszy     Kocury.pseudo%TYPE;
  --nadwyzka idzie do kota ktory ma najmniej
BEGIN
  WHILE data_start <= data_end LOOP
    SELECT
      pseudo,
      NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)
    BULK COLLECT INTO tablica_kotow
    FROM Kocury
    WHERE w_stadku_od < data_start;
    --wybieramy wszystkie koty ktore sa w stadku od daty 2004

    SELECT CEIL(AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)))
    INTO srednia_liczba_myszy
    FROM Kocury
    WHERE w_stadku_od < data_start;
    --srednia liczba myszy jedzona w miesiacu

    SELECT pseudo
    INTO pseudonim_min_myszy
    FROM Kocury
    WHERE w_stadku_od < data_start
          AND (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) =
              (SELECT MIN(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))
               FROM Kocury
               WHERE w_stadku_od < data_start)
          AND ROWNUM = 1; --wybieramy kota ktoremy nalezy sie nadwyzka

    dbms_output.put_line(
        data_start || ' - ' || ostatnia_sroda_miesiaca || ' : ' || srednia_liczba_myszy * tablica_kotow.COUNT);
    FOR i IN 1..tablica_kotow.COUNT LOOP
      FOR j IN 1..srednia_liczba_myszy LOOP
        data_zlowienia_pom := data_start + DBMS_RANDOM.VALUE(0, ostatnia_sroda_miesiaca - data_start);

        IF data_zlowienia_pom <= data_end
        THEN
          --wpisujemy zdobyte myszy przez kotow po kolei z waga wybrana randomowo i data zlowienia tez randomowa
          tablica_myszy(index_po_m_zlapanych).nr_myszy := index_po_m_zlapanych;
          tablica_myszy(index_po_m_zlapanych).lowca := tablica_kotow(i).pseudo;
          tablica_myszy(index_po_m_zlapanych).waga_myszy := ROUND(DBMS_RANDOM.VALUE(15, 45), 2);
          tablica_myszy(index_po_m_zlapanych).data_zlowienia := data_zlowienia_pom;
          IF ostatnia_sroda_miesiaca <= data_end
          THEN --ustawiamy kiedy powinno byc wydane
            tablica_myszy(index_po_m_zlapanych).data_wydania := ostatnia_sroda_miesiaca;
          END IF;
          index_po_m_zlapanych := index_po_m_zlapanych + 1; --zwiekszamy index myszy zlapanych
        END IF;
      END LOOP;
    END LOOP;

    IF (ostatnia_sroda_miesiaca <= data_end)
    THEN --rozdajemy kotom myszy zlapane
      FOR i IN 1..tablica_kotow.COUNT LOOP
        FOR j IN 1..tablica_kotow(i).liczbaMyszy LOOP
          tablica_myszy(index_po_m_zjedzonych).zjadacz := tablica_kotow(i).pseudo;
          index_po_m_zjedzonych := index_po_m_zjedzonych + 1;
        END LOOP;
      END LOOP;
      --mamy jeszcze nadwyzke zlapanych do zjedzonych oddajemy temu co najmniej
      WHILE index_po_m_zlapanych > index_po_m_zjedzonych LOOP
        tablica_myszy(index_po_m_zjedzonych).zjadacz := pseudonim_min_myszy;
        index_po_m_zjedzonych := index_po_m_zjedzonych + 1;
      END LOOP;
    END IF;

    data_start := ostatnia_sroda_miesiaca + 1; --miesiac pozniej , po wyplacie itd
    ostatnia_sroda_miesiaca := (NEXT_DAY(LAST_DAY(ADD_MONTHS(ostatnia_sroda_miesiaca, 1)) - 7, 'Wednesday'));
    --kolejna sroda miesiac
  END LOOP;

  FORALL i IN 1..tablica_myszy.COUNT
  INSERT INTO Myszy VALUES (
    tablica_myszy(i).nr_myszy,
    tablica_myszy(i).lowca,
    tablica_myszy(i).zjadacz,
    tablica_myszy(i).waga_myszy,
    tablica_myszy(i).data_zlowienia,
    tablica_myszy(i).data_wydania
  );
  EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

-- DELETE FROM MYSZY;
SELECT count(*)
FROM MYSZY;

/*
One table per cat
*/
DECLARE
  Q VARCHAR2(6000);
BEGIN
  FOR KOT IN (SELECT PSEUDO
              FROM KOCURY)
  LOOP
    Q := 'CREATE TABLE TAB_MYSZ_ZLOW_' || KOT.PSEUDO || '(
 nr_myszy INTEGER CONSTRAINT pk_nr_myszy_' || KOT.PSEUDO || ' PRIMARY KEY,
 waga_myszy NUMBER(3) CONSTRAINT waga_myszy_' || KOT.PSEUDO || ' CHECK (waga_myszy BETWEEN 15 AND 45),
 data_zlowienia DATE CONSTRAINT data_zlowienia_nn_' || KOT.PSEUDO || ' NOT NULL)';
    EXECUTE IMMEDIATE Q;
  END LOOP;
  EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

--- drop
DECLARE
  Q VARCHAR2(6000);
BEGIN
  FOR KOT IN (SELECT PSEUDO
              FROM KOCURY)
  LOOP
    Q := 'DROP TABLE TAB_MYSZ_ZLOW_' || KOT.PSEUDO || '';
    EXECUTE IMMEDIATE Q;
  END LOOP;
  EXCEPTION
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;





--przyjecie myszy upolowanych--

CREATE OR REPLACE PROCEDURE przyjmij_myszy_od_kota(ps Kocury.pseudo%TYPE, data_z DATE) AS

  ma_byc_1_pseudo            NUMBER;
    PSEUDO_NIEPRAWIDLOWE_EXCEPTION EXCEPTION;

  ---przechowuje cale info z myszy
  TYPE MYSZY_TABLICA_TYP IS TABLE OF MYSZY%ROWTYPE INDEX BY BINARY_INTEGER;
  myszy_tablica              MYSZY_TABLICA_TYP;

  --- wybrane tylko te info, ktore nas interesuja
  TYPE MYSZY_KOTA_REKORD IS RECORD (nr_myszy MYSZY.nr_myszy%TYPE, waga_myszy MYSZY.waga_myszy%TYPE, data_zlowienia MYSZY.data_zlowienia%TYPE);
  TYPE MYSZY_KOTA IS TABLE OF MYSZY_KOTA_REKORD INDEX BY BINARY_INTEGER;
  upolowane_myszy            MYSZY_KOTA;

  daj_myszy_dany_dzien_query VARCHAR2(500);
  ostatni_index_w_tab_myszy  NUMBER;
  BEGIN

    SELECT COUNT(*)
    INTO ma_byc_1_pseudo
    FROM Kocury
    WHERE pseudo = ps;

    IF ma_byc_1_pseudo != 1
    THEN
      RAISE PSEUDO_NIEPRAWIDLOWE_EXCEPTION;
    END IF;

    SELECT MAX(NVL(nr_myszy, 0))
    INTO ostatni_index_w_tab_myszy
    FROM Myszy;

    ostatni_index_w_tab_myszy := ostatni_index_w_tab_myszy + 1;

    daj_myszy_dany_dzien_query := 'SELECT * FROM TAB_MYSZ_ZLOW_' || PS || ' WHERE data_zlowienia=''' || data_z || '''';

    EXECUTE IMMEDIATE daj_myszy_dany_dzien_query
    BULK COLLECT INTO upolowane_myszy;

    FOR i IN 1..upolowane_myszy.COUNT LOOP
      myszy_tablica(i).nr_myszy := ostatni_index_w_tab_myszy;
      myszy_tablica(i).waga_myszy := upolowane_myszy(i).waga_myszy;
      myszy_tablica(i).data_zlowienia := upolowane_myszy(i).data_zlowienia;
      ostatni_index_w_tab_myszy := ostatni_index_w_tab_myszy + 1;
    END LOOP;

    FORALL i IN 1..myszy_tablica.COUNT
    INSERT INTO Myszy VALUES (myszy_tablica(i).nr_myszy, ps, NULL, myszy_tablica(i).waga_myszy,
                              myszy_tablica(i).data_zlowienia, NULL);

    daj_myszy_dany_dzien_query := 'DELETE FROM TAB_MYSZ_ZLOW_' || ps || ' WHERE data_zlowienia=''' || data_z || '''';
    EXECUTE IMMEDIATE daj_myszy_dany_dzien_query;

    EXCEPTION
    WHEN PSEUDO_NIEPRAWIDLOWE_EXCEPTION THEN dbms_output.put_line('Podany pseudonim jest nieprawidlowy!');
    WHEN OTHERS THEN dbms_output.put_line(dbms_utility.format_error_backtrace);
  END przyjmij_myszy_od_kota;
INSERT INTO TAB_MYSZ_ZLOW_TYGRYS VALUES (1, 23, TO_DATE('2017-01-22'));
INSERT INTO TAB_MYSZ_ZLOW_TYGRYS VALUES (2, 32, TO_DATE('2017-01-22'));
INSERT INTO TAB_MYSZ_ZLOW_TYGRYS VALUES (3, 39, TO_DATE('2017-01-22'));

EXECUTE przyjmij_myszy_od_kota('TYGRYS',TO_DATE('2017-01-22'));
SELECT *
FROM TAB_MYSZ_ZLOW_TYGRYS;
SELECT *
FROM myszy
ORDER BY 5 DESC;

CREATE OR REPLACE PROCEDURE wyplata AS
  index_kota             NUMBER := 1;
  index_myszy            NUMBER := 1;
  suma_przydzialow_kotow NUMBER := 0;
  przydzielono_mysz      BOOLEAN;

  najblizsza_sroda       DATE := NEXT_DAY(LAST_DAY(SYSDATE) - 7, 'Wednesday');

  TYPE TABLICA_MYSZY_TYP IS TABLE OF Myszy%ROWTYPE INDEX BY BINARY_INTEGER;
  myszy_tablica          TABLICA_MYSZY_TYP;

  TYPE PSEUDO_LICZBAMYSZY_RECORD IS RECORD (pseudo Kocury.pseudo%TYPE, myszy NUMBER(3));
  TYPE TABLICA_DANEKOTA_TYP IS TABLE OF PSEUDO_LICZBAMYSZY_RECORD INDEX BY BINARY_INTEGER;
  koty_tablica           TABLICA_DANEKOTA_TYP;

  BEGIN
    SELECT *
    BULK COLLECT INTO myszy_tablica
    FROM Myszy
    WHERE zjadacz IS NULL; --wybieramy wszystko gdzie zjadacz jest nullem


    SELECT
      pseudo,
      NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)
    BULK COLLECT INTO koty_tablica
    FROM Kocury
    WHERE w_stadku_od <= NEXT_DAY(LAST_DAY(ADD_MONTHS(SYSDATE, -1)) - 7, 'ŚRODA')
    START WITH szef IS NULL
    CONNECT BY PRIOR pseudo = szef
    ORDER BY LEVEL ASC;
    --zaczynamy wyplate od szefa

    FOR i IN 1..koty_tablica.COUNT LOOP
      suma_przydzialow_kotow := suma_przydzialow_kotow + koty_tablica(i).myszy;
    END LOOP;

    WHILE index_myszy <= myszy_tablica.COUNT AND suma_przydzialow_kotow > 0 LOOP -- rozdziela myszy
      przydzielono_mysz := FALSE;
      WHILE NOT przydzielono_mysz LOOP --
        IF koty_tablica(index_kota).myszy > 0
        THEN
          myszy_tablica(index_myszy).zjadacz := koty_tablica(index_kota).pseudo;
          myszy_tablica(index_myszy).data_wydania := najblizsza_sroda;
          koty_tablica(index_kota).myszy := koty_tablica(index_kota).myszy - 1;
          suma_przydzialow_kotow := suma_przydzialow_kotow - 1;
          przydzielono_mysz := TRUE;
          index_myszy := index_myszy + 1; -- bierze kolejna mysz jak ta juz zostala rozdzielona
        END IF;
        index_kota := index_kota + 1; -- bierze kolejnego kota gdy tez juz nie potrzebuje dostac
        IF index_kota > koty_tablica.COUNT
        THEN index_kota := 1;
        END IF;
      END LOOP;
      --DBMS_OUTPUT.PUT_LINE(' Mysz: '||TO_CHAR(index_myszy)|| ' Pseudo zjadacz - ' || koty_tablica(index_kota).pseudo);
      --DBMS_OUTPUT.PUT_LINE(myszy_tablica.COUNT);
    END LOOP;

    FORALL i IN 1..myszy_tablica.COUNT
    SAVE EXCEPTIONS
    UPDATE MYSZY
    SET data_wydania = myszy_tablica(i).data_wydania,
      zjadacz        = myszy_tablica(i).zjadacz
    WHERE nr_myszy = myszy_tablica(i).nr_myszy;

    EXCEPTION
    WHEN OTHERS THEN dbms_output.put_line(dbms_utility.format_error_backtrace);

  END wyplata;
EXECUTE wyplata;

SELECT *
FROM myszy
ORDER BY 5 DESC;