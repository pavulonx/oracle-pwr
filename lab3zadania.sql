SET SERVEROUTPUT ON;

/* zad 34 */
DECLARE
  KOCURY_F VARCHAR2(255);
BEGIN
  SELECT DISTINCT FUNKCJA
  INTO KOCURY_F
  FROM KOCURY
  WHERE FUNKCJA = 'LOWCZY';

  DBMS_OUTPUT.PUT_LINE(KOCURY_F);
  EXCEPTION
  WHEN NO_DATA_FOUND
  THEN DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota o podanej funkcji!');
END;

/* zad 35 */
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
  FROM Kocury
  WHERE pseudo = 'TYGRYS'; --'&pseudo'

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

/* zad 36 */
DECLARE
  CURSOR cur_przydz IS
    SELECT
      nvl(przydzial_myszy, 0) pm,
      max_myszy               mm
    FROM Kocury
      JOIN Funkcje USING (funkcja)
    ORDER BY przydzial_myszy ASC
    FOR UPDATE OF przydzial_myszy;

  cur_re         cur_przydz%ROWTYPE;
  przydzial_suma NUMBER;
  nowy_pm        NUMBER;
  liczba_pod     NUMBER := 0;
  sa_wiersze     BOOLEAN := FALSE;
    brak_kotow EXCEPTION;
BEGIN
  LOOP EXIT WHEN przydzial_suma > 1050;
    OPEN cur_przydz;
    LOOP
      FETCH cur_przydz INTO cur_re;
      EXIT WHEN cur_przydz%NOTFOUND;
      IF NOT sa_wiersze
      THEN sa_wiersze := TRUE;
      END IF;

      nowy_pm := cur_re.pm * 1.1;
      IF nowy_pm > cur_re.mm
      THEN nowy_pm := cur_re.mm;
      END IF;
      UPDATE Kocury
      SET przydzial_myszy = nowy_pm
      WHERE CURRENT OF cur_przydz;
      liczba_pod := liczba_pod + 1;
      SELECT sum(nvl(przydzial_myszy, 0))
      INTO przydzial_suma
      FROM Kocury;
      IF przydzial_suma > 1050
      THEN EXIT;
      END IF;
    END LOOP;
    CLOSE cur_przydz;
  END LOOP;
  dbms_output.put_line('Calk. przydzial w stadku - ' || przydzial_suma || ' Zmian - ' || liczba_pod);
  IF NOT sa_wiersze
  THEN RAISE brak_kotow;
  END IF;
  EXCEPTION
  WHEN brak_kotow THEN dbms_output.put_line('Brak kotow');
  WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
END;
ROLLBACK;
SELECT
  imie,
  nvl(przydzial_myszy, 0) "Myszki po podwyzce"
FROM Kocury
ORDER BY 2 DESC;

/* zad 37 */
DECLARE
  i NUMBER := 0;
BEGIN
  dbms_output.put_line('Nr   Pseudonim   Zjada ');
  dbms_output.put_line('-----------------------');
  FOR elem IN (SELECT
                 pseudo,
                 nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0) zjada
               FROM Kocury
               ORDER BY 2 DESC)
  LOOP
    i := i + 1;
    dbms_output.put_line(i || '    ' || rpad(elem.pseudo, 9, ' ') || '   ' || elem.zjada);
    EXIT WHEN i = 5;
  END LOOP;
END;

/* zad 38 */
DECLARE
  CURSOR cur_hier IS
    SELECT
      imie,
      szef
    FROM Kocury
    WHERE funkcja IN ('KOT', 'MILUSIA');
  cur_re       cur_hier%ROWTYPE;
  akt_szef     Kocury.szef%TYPE;
  akt_imie     Kocury.imie%TYPE;
  ilu          NUMBER := '&ilu_przelozonych';
  maxGlebokosc NUMBER;
BEGIN
  SELECT max(level)
  INTO maxGlebokosc
  FROM Kocury
  CONNECT BY PRIOR pseudo = szef
  START WITH szef IS NULL;
  IF ilu > maxGlebokosc
  THEN
    ilu := maxGlebokosc - 1;
  END IF;
  dbms_output.put(rpad(' Imie', 12) || '|');
  FOR i IN 1..ilu
  LOOP
    dbms_output.put(rpad(' Szef' || i, 12) || '|');
  END LOOP;
  dbms_output.new_line();
  FOR i IN 1..(ilu + 1)
  LOOP
    dbms_output.put(rpad(' ', 12, '-'));
  END LOOP;
  dbms_output.new_line();
  OPEN cur_hier;
  LOOP
    FETCH cur_hier INTO cur_re;
    EXIT WHEN cur_hier%NOTFOUND;
    dbms_output.put(rpad(' ' || cur_re.imie, 12) || '|');
    akt_szef := cur_re.szef;
    FOR i IN 1..ilu
    LOOP
      IF akt_szef IS NOT NULL
      THEN
        SELECT
          imie,
          szef
        INTO akt_imie, akt_szef
        FROM Kocury
        WHERE pseudo = akt_szef;
        dbms_output.put(rpad(' ' || akt_imie, 12) || '|');
      ELSE EXIT;
      END IF;
    END LOOP;
    dbms_output.new_line();
  END LOOP;
  CLOSE cur_hier;
  dbms_output.new_line();
END;

/* zad 39 */
DECLARE
  nrB             Bandy.nr_bandy%TYPE := 2; --'&numer_bandy';
  nazwaB          Bandy.nazwa%TYPE := 'CZARNI RYCERZE'; --'&nazwa_bandy';
  terenB          Bandy.teren%TYPE := 'POLE'; --'&teren_bandy';
  czyJestDuplikat BOOLEAN := FALSE;
    dup_values EXCEPTION;
    less_zero EXCEPTION;
    null_values EXCEPTION;
  numNr           NUMBER;
  numNaz          NUMBER;
  numTer          NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO numNr
  FROM Bandy
  WHERE nrB = nr_bandy;
  SELECT COUNT(*)
  INTO numNaz
  FROM Bandy
  WHERE nazwaB = nazwa;
  SELECT COUNT(*)
  INTO numTer
  FROM Bandy
  WHERE terenB = teren;
  IF numNr > 0
  THEN
    dbms_output.put(nrB || ', ');
    czyJestDuplikat := TRUE;
  END IF;
  IF numNaz > 0
  THEN
    dbms_output.put(nazwaB || ', ');
    czyJestDuplikat := TRUE;
  END IF;
  IF numTer > 0
  THEN
    dbms_output.put(terenB);
    czyJestDuplikat := TRUE;
  END IF;
  IF czyJestDuplikat
  THEN
    RAISE dup_values;
  END IF;
  IF nrB IS NULL OR nazwaB IS NULL OR terenB IS NULL
  THEN
    RAISE null_values;
  END IF;
  IF nrB <= 0
  THEN
    RAISE less_zero;
  END IF;
  INSERT INTO Bandy (NR_BANDY, NAZWA, TEREN) VALUES (nrB, nazwaB, terenB);
  dbms_output.put_line('Pola dodane pomyslnie !');
  EXCEPTION
  WHEN dup_values THEN dbms_output.put_line(' :juz istnieje');
  WHEN less_zero THEN dbms_output.put_line('Numer bandy <= 0');
  WHEN null_values THEN dbms_output.put_line('Niewprowadzono wszystkich danych !');
  WHEN OTHERS THEN RAISE;
END;
-- ROLLBACK;

/* zad 40 */
CREATE OR REPLACE PROCEDURE nowaBanda(nrB Bandy.nr_bandy%TYPE, nazwaB Bandy.nazwa%TYPE, terenB Bandy.teren%TYPE) AS
  czyJestNazwa BOOLEAN := FALSE;
  czyJestNr    BOOLEAN := FALSE;
  czyJestTeren BOOLEAN := FALSE;
    dup_values EXCEPTION;
    less_zero EXCEPTION;
    null_values EXCEPTION;
  numNr        NUMBER;
  numNaz       NUMBER;
  numTer       NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO numNr
    FROM Bandy
    WHERE nrB = nr_bandy;
    SELECT COUNT(*)
    INTO numNaz
    FROM Bandy
    WHERE nazwaB = nazwa;
    SELECT COUNT(*)
    INTO numTer
    FROM Bandy
    WHERE terenB = teren;
    IF numNr > 0
    THEN
      dbms_output.put(nrB || ', ');
      czyJestNr := TRUE;
    END IF;
    IF numNaz > 0
    THEN
      dbms_output.put(nazwaB || ', ');
      czyJestNazwa := TRUE;
    END IF;
    IF numTer > 0
    THEN
      dbms_output.put(terenB);
      czyJestTeren := TRUE;
    END IF;
    IF czyJestNazwa OR czyJestTeren OR czyJestNr
    THEN
      RAISE dup_values;
    END IF;
    IF nrB IS NULL OR nazwaB IS NULL OR terenB IS NULL
    THEN
      RAISE null_values;
    END IF;
    IF nrB <= 0
    THEN
      RAISE less_zero;
    END IF;
    INSERT INTO Bandy (NR_BANDY, NAZWA, TEREN) VALUES (nrB, nazwaB, terenB);
    dbms_output.put_line('Pola dodane pomyslnie !');
    EXCEPTION
    WHEN dup_values THEN dbms_output.put_line(' :juz istnieje');
    WHEN less_zero THEN dbms_output.put_line('Numer bandy <= 0');
    WHEN null_values THEN dbms_output.put_line('Niewprowadzono wszystkich danych !');
    WHEN OTHERS THEN RAISE;
  END;
CALL nowaBanda(2, 'dsa', 'iuhai');
-- CALL nowaBanda(10, 'SZEFOSTWO', 'POLE');
SELECT *
FROM Bandy;
ROLLBACK;

DROP TRIGGER nr_nowej_bandy;

/* zad 41 */
CREATE OR REPLACE TRIGGER nr_nowej_bandy
BEFORE INSERT ON Bandy
FOR EACH ROW
  DECLARE
    numer Bandy.nr_bandy%TYPE;
  BEGIN
    SELECT max(nr_bandy)
    INTO numer
    FROM Bandy;
    :NEW.nr_bandy := numer + 1;
  END;
SHOW ERRORS;

/* zad 42a */
CREATE OR REPLACE PACKAGE wirus AS
  akt_pseudo Kocury.pseudo%TYPE;
  czyWykonac BOOLEAN := FALSE;
  nowyPrzydzial Kocury.przydzial_myszy%TYPE;
  staryPrzydzial Kocury.przydzial_myszy%TYPE;
  FUNCTION przydzial_tygrysa
    RETURN Kocury.przydzial_myszy%TYPE;
END wirus;
CREATE OR REPLACE PACKAGE BODY wirus AS
  FUNCTION przydzial_tygrysa
    RETURN Kocury.przydzial_myszy%TYPE IS
    przydzial Kocury.przydzial_myszy%TYPE;
    BEGIN
      SELECT przydzial_myszy
      INTO przydzial
      FROM Kocury
      WHERE pseudo = 'TYGRYS';
      RETURN przydzial;
    END przydzial_tygrysa;
END wirus;

CREATE OR REPLACE TRIGGER wirusPrzed
BEFORE UPDATE OF przydzial_myszy
  ON Kocury
FOR EACH ROW WHEN (NEW.funkcja = 'MILUSIA')
  DECLARE
  BEGIN
    IF (NOT wirus.czyWykonac)
    THEN
      wirus.akt_pseudo := :NEW.pseudo;
      IF :NEW.przydzial_myszy < :OLD.przydzial_myszy
      THEN
        :NEW.przydzial_myszy := :OLD.przydzial_myszy;
      END IF;
      wirus.nowyPrzydzial := :NEW.przydzial_myszy;
      wirus.staryPrzydzial := :OLD.przydzial_myszy;
    END IF;
  END;

CREATE OR REPLACE TRIGGER wirusPo
AFTER UPDATE OF przydzial_myszy
  ON Kocury
  DECLARE
    czyMniejNiz10 BOOLEAN := TRUE;
  BEGIN
    czyMniejNiz10 := (wirus.nowyPrzydzial - wirus.staryPrzydzial) < wirus.przydzial_tygrysa * 0.1;
    IF (NOT wirus.czyWykonac)
    THEN
      wirus.czyWykonac := TRUE;
      IF (czyMniejNiz10)
      THEN
        UPDATE Kocury
        SET przydzial_myszy = wirus.nowyPrzydzial, myszy_extra = myszy_extra + 5
        WHERE pseudo = wirus.akt_pseudo;

        UPDATE Kocury
        SET przydzial_myszy = przydzial_myszy * 0.9
        WHERE pseudo = 'TYGRYS';
      ELSE
        UPDATE Kocury
        SET myszy_extra = myszy_extra + 5
        WHERE pseudo = 'TYGRYS';

        UPDATE Kocury
        SET przydzial_myszy = wirus.nowyPrzydzial
        WHERE pseudo = wirus.akt_pseudo;
      END IF;
      wirus.czyWykonac := FALSE;
    END IF;
  END;

SELECT
  pseudo,
  funkcja,
  przydzial_myszy,
  myszy_extra
FROM Kocury
WHERE funkcja = 'MILUSIA' OR pseudo = 'TYGRYS';
UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 10
WHERE pseudo = 'MALA';
ROLLBACK;
--show errors;

/* zad 42b */
CREATE OR REPLACE TRIGGER compound_wirus
FOR UPDATE OF przydzial_myszy
  ON Kocury
WHEN (OLD.funkcja = 'MILUSIA')
COMPOUND TRIGGER
  akt_pseudo Kocury.pseudo%TYPE;
  czyWykonac BOOLEAN := FALSE;
  nowyPrzydzial Kocury.przydzial_myszy%TYPE;
  staryPrzydzial Kocury.przydzial_myszy%TYPE;
  przydzial_tygrysa Kocury.przydzial_myszy%TYPE;
  BEFORE STATEMENT IS
  BEGIN
    SELECT przydzial_myszy
    INTO przydzial_tygrysa
    FROM Kocury
    WHERE pseudo = 'TYGRYS';
  END BEFORE STATEMENT;

  BEFORE EACH ROW IS
  BEGIN
    IF (NOT wirus.czyWykonac)
    THEN
      wirus.akt_pseudo := :NEW.pseudo;
      IF :NEW.przydzial_myszy < :OLD.przydzial_myszy
      THEN
        :NEW.przydzial_myszy := :OLD.przydzial_myszy;
      END IF;
      wirus.nowyPrzydzial := :NEW.przydzial_myszy;
      wirus.staryPrzydzial := :OLD.przydzial_myszy;
    END IF;
  END BEFORE EACH ROW;

  AFTER STATEMENT IS
    czyMniejNiz10 BOOLEAN := TRUE;
  BEGIN
    czyMniejNiz10 := (wirus.nowyPrzydzial - wirus.staryPrzydzial) < wirus.przydzial_tygrysa * 0.1;
    IF (NOT wirus.czyWykonac)
    THEN
      wirus.czyWykonac := TRUE;
      IF (czyMniejNiz10)
      THEN
        UPDATE Kocury
        SET przydzial_myszy = wirus.nowyPrzydzial, myszy_extra = myszy_extra + 5
        WHERE pseudo = wirus.akt_pseudo;

        UPDATE Kocury
        SET przydzial_myszy = przydzial_myszy * 0.9
        WHERE pseudo = 'TYGRYS';
      ELSE
        UPDATE Kocury
        SET myszy_extra = myszy_extra + 5
        WHERE pseudo = 'TYGRYS';

        UPDATE Kocury
        SET przydzial_myszy = wirus.nowyPrzydzial
        WHERE pseudo = wirus.akt_pseudo;
      END IF;
      wirus.czyWykonac := FALSE;
    END IF;
  END AFTER STATEMENT;
END compound_wirus;

SELECT
  pseudo,
  funkcja,
  przydzial_myszy,
  myszy_extra
FROM Kocury
WHERE funkcja = 'MILUSIA' OR pseudo = 'TYGRYS';
UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 10
WHERE pseudo = 'MALA';
ROLLBACK;
SHOW errors;

/* zad 43 */
DECLARE
  i          NUMBER := 1;
  temp       NUMBER;
  liczba_fun NUMBER := 0;
BEGIN
  dbms_output.put(rpad('Nazwa Bandy', 16));
  dbms_output.put(rpad('Plec', 7));
  dbms_output.put(rpad('Ile', 8));
  FOR fun IN (SELECT funkcja
              FROM Funkcje) LOOP
    dbms_output.put(rpad(fun.funkcja, 13));
    liczba_fun := liczba_fun + 1;
  END LOOP;
  dbms_output.put(rpad('SUMA', 13));
  dbms_output.new_line();
  dbms_output.put('-------------- ------- ------' || rpad(' ', 13, '-'));
  FOR i IN 1..liczba_fun LOOP
    dbms_output.put(rpad(' ', 13, '-'));
  END LOOP;
  dbms_output.new_line();
  FOR bandy IN (SELECT
                  nr_bandy,
                  nazwa,
                  plec
                FROM Kocury
                  JOIN Bandy USING (nr_bandy)
                GROUP BY nr_bandy, nazwa, plec
                ORDER BY 2, 3 ASC) LOOP
    IF mod(i, 2) != 0
    THEN
      dbms_output.put(rpad(bandy.nazwa, 16));
      dbms_output.put(rpad('Kotka', 7));
    ELSE
      dbms_output.put(lpad(' ', 16));
      dbms_output.put(rpad('Kocor', 7));
    END IF;

    SELECT COUNT(pseudo)
    INTO temp
    FROM Kocury Ko
    WHERE Ko.nr_bandy = bandy.nr_bandy AND Ko.plec = bandy.plec;
    dbms_output.put(rpad(temp, 8));

    FOR funkcje IN (SELECT funkcja
                    FROM Funkcje) LOOP
      SELECT sum(nvl(Ko.przydzial_myszy, 0) + nvl(Ko.myszy_extra, 0))
      INTO temp
      FROM Kocury Ko
      WHERE Ko.nr_bandy = bandy.nr_bandy AND Ko.plec = bandy.plec AND Ko.funkcja = funkcje.funkcja;
      dbms_output.put(rpad(nvl(temp, 0), 13));
    END LOOP;

    SELECT sum(nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0))
    INTO temp
    FROM Kocury Ko
    WHERE Ko.nr_bandy = bandy.nr_bandy AND Ko.plec = bandy.plec;
    dbms_output.put_line(rpad(nvl(temp, 0), 13));
    i := i + 1;
  END LOOP;
  dbms_output.put('z------------- ------- ------' || rpad(' ', 13, '-'));
  FOR i IN 1..liczba_fun LOOP
    dbms_output.put(rpad(' ', 13, '-'));
  END LOOP;
  dbms_output.new_line();
  dbms_output.put(rpad('ZJADA RAZEM', 31));
  FOR funkcje IN (SELECT funkcja
                  FROM Funkcje) LOOP
    SELECT sum(nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0))
    INTO temp
    FROM Kocury Ko
    WHERE Ko.funkcja = funkcje.funkcja;
    dbms_output.put(rpad(nvl(temp, 0), 13));
  END LOOP;
  SELECT sum(nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0))
  INTO temp
  FROM Kocury;
  dbms_output.put_line(nvl(temp, 0));
END;

/* zad 44 */
CREATE OR REPLACE PACKAGE podatek_poglowny AS
  FUNCTION podatek(ps Kocury.pseudo%TYPE)
    RETURN NUMBER;
  PROCEDURE nowaBanda(nrB Bandy.nr_bandy%TYPE, nazwaB Bandy.nazwa%TYPE, terenB Bandy.teren%TYPE);
END podatek_poglowny;
CREATE OR REPLACE PACKAGE BODY podatek_poglowny AS
  FUNCTION podatek(ps Kocury.pseudo%TYPE)
    RETURN NUMBER IS
    sumaPod NUMBER := 0;
    temp    NUMBER := 0;
    temp2   NUMBER := 0;
    BEGIN
      SELECT ceil(nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0)) * 0.05
      INTO sumaPod
      FROM Kocury
      WHERE pseudo = ps;

      SELECT count(*)
      INTO temp
      FROM Kocury
      WHERE szef = ps;
      IF temp = 0
      THEN
        sumaPod := sumaPod + 2;
      END IF;

      SELECT count(*)
      INTO temp
      FROM Wrogowie_Kocurow
      WHERE pseudo = ps;
      IF temp = 0
      THEN
        sumaPod := sumaPod + 1;
      END IF;

      SELECT PRZYDZIAL_MYSZY
      INTO temp
      FROM Kocury
      WHERE pseudo = ps;
      SELECT avg(PRZYDZIAL_MYSZY)
      INTO temp2
      FROM Kocury;
      IF temp < temp2
      THEN
        sumaPod := sumaPod + temp;
      END IF;

      RETURN sumaPod;
    END podatek;

  PROCEDURE nowaBanda(nrB Bandy.nr_bandy%TYPE, nazwaB Bandy.nazwa%TYPE, terenB Bandy.teren%TYPE) AS
    czyJestNazwa BOOLEAN := FALSE;
    czyJestNr    BOOLEAN := FALSE;
    czyJestTeren BOOLEAN := FALSE;
      dup_values EXCEPTION;
      less_zero EXCEPTION;
      null_values EXCEPTION;
    numNr        NUMBER;
    numNaz       NUMBER;
    numTer       NUMBER;
    BEGIN
      SELECT COUNT(*)
      INTO numNr
      FROM Bandy
      WHERE nrB = nr_bandy;
      SELECT COUNT(*)
      INTO numNaz
      FROM Bandy
      WHERE nazwaB = nazwa;
      SELECT COUNT(*)
      INTO numTer
      FROM Bandy
      WHERE terenB = teren;
      IF numNr > 0
      THEN
        dbms_output.put(nrB || ', ');
        czyJestNr := TRUE;
      END IF;
      IF numNaz > 0
      THEN
        dbms_output.put(nazwaB || ', ');
        czyJestNazwa := TRUE;
      END IF;
      IF numTer > 0
      THEN
        dbms_output.put(terenB);
        czyJestTeren := TRUE;
      END IF;
      IF czyJestNazwa OR czyJestTeren OR czyJestNr
      THEN
        RAISE dup_values;
      END IF;
      IF nrB IS NULL OR nazwaB IS NULL OR terenB IS NULL
      THEN
        RAISE null_values;
      END IF;
      IF nrB <= 0
      THEN
        RAISE less_zero;
      END IF;
      INSERT INTO Bandy (NR_BANDY, NAZWA, TEREN) VALUES (nrB, nazwaB, terenB);
      dbms_output.put_line('Pola dodane pomy�lnie !');
      EXCEPTION
      WHEN dup_values THEN dbms_output.put_line(' :juz istnieje');
      WHEN less_zero THEN dbms_output.put_line('Numer bandy <= 0');
      WHEN null_values THEN dbms_output.put_line('Niewprowadzono wszystkich danych !');
      WHEN OTHERS THEN dbms_output.put_line('Co� poszlo nie tak :(');
    END nowaBanda;
END podatek_poglowny;

BEGIN
  dbms_output.put(rpad('PSEUDO', 10));
  dbms_output.put(rpad('PODATEK', 10));
  dbms_output.new_line();
  dbms_output.put(lpad(' ', 10, '-'));
  dbms_output.put(lpad(' ', 10, '-'));
  dbms_output.new_line();
  FOR kot IN (SELECT pseudo
              FROM Kocury) LOOP
    dbms_output.put(rpad(kot.pseudo, 10));
    dbms_output.put(rpad(podatek_poglowny.podatek(kot.pseudo), 10));
    dbms_output.new_line();
  END LOOP;
END;

/* zad 45 */
DROP SEQUENCE indexDodatki;
DROP TABLE Dodatki_extra;

CREATE SEQUENCE indexDodatki
START WITH 1
INCREMENT BY 1;

CREATE TABLE Dodatki_extra (
  id      NUMBER PRIMARY KEY,
  pseudo  VARCHAR2(15) CONSTRAINT de_ps_fk REFERENCES Kocury (pseudo),
  dodatek NUMBER
);

CREATE OR REPLACE TRIGGER trig_antywirus
AFTER UPDATE OF przydzial_myszy, myszy_extra
  ON Kocury
FOR EACH ROW WHEN (OLD.funkcja = 'MILUSIA')
  DECLARE
    akt_dodatek NUMBER := 0;
    ilosc       NUMBER := 0;
  BEGIN
    IF (LOGIN_USER != 'TYGRYS' AND (:NEW.przydzial_myszy > :OLD.przydzial_myszy OR :NEW.myszy_extra > :OLD.myszy_extra))
    THEN
      SELECT COUNT(*)
      INTO ilosc
      FROM Dodatki_extra
      WHERE pseudo = :OLD.pseudo;
      IF ilosc = 0
      THEN
        INSERT INTO Dodatki_extra VALUES (indexDodatki.nextval, :OLD.pseudo, -10);
      ELSE
        SELECT dodatek
        INTO akt_dodatek
        FROM Dodatki_extra
        WHERE pseudo = :OLD.pseudo;
        akt_dodatek := akt_dodatek - 10;
        UPDATE Dodatki_extra
        SET dodatek = akt_dodatek
        WHERE pseudo = :OLD.pseudo;
      END IF;
    END IF;
  END;

SAVEPOINT zad24b;
SELECT
  pseudo,
  funkcja,
  przydzial_myszy,
  myszy_extra
FROM Kocury
WHERE funkcja = 'MILUSIA' OR pseudo = 'TYGRYS';
UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 10
WHERE pseudo = 'LASKA';
SELECT
  pseudo,
  funkcja,
  przydzial_myszy,
  myszy_extra
FROM Kocury;
SELECT *
FROM Dodatki_extra;
ROLLBACK;
SHOW errors;


CREATE OR REPLACE TRIGGER CONSTR_MIN_MAX_TRIG
BEFORE INSERT ON KOCURY
FOR EACH ROW
  DECLARE
    MIN_M   KOCURY.PRZYDZIAL_MYSZY%TYPE;
    MAX_M   KOCURY.PRZYDZIAL_MYSZY%TYPE;
    OP_TYPE VARCHAR2(10);
  BEGIN
    IF INSERTING
    THEN
      OP_TYPE := 'INSERTING';
    END IF;
    IF UPDATING
    THEN
      OP_TYPE := 'UPDATING ';
    END IF;

    SELECT
      F.MIN_MYSZY,
      F.MAX_MYSZY
    INTO MIN_M, MAX_M
    FROM FUNKCJE F
    WHERE F.FUNKCJA = :OLD.FUNKCJA;
    IF :NEW.PRZYDZIAL_MYSZY < MIN_M OR MAX_M < :NEW.PRZYDZIAL_MYSZY
    THEN
      :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
    END IF;
  END;

--CREATE OR REPLACE TRIGGER trig_antywirus
--AFTER UPDATE OF przydzial_myszy, myszy_extra ON Kocury
--FOR EACH ROW WHEN(OLD.funkcja = 'MILUSIA')
--DECLARE
--  akt_dodatek NUMBER := 0;
--  ilosc NUMBER := 0;
--  temp NUMBER := 0;
--BEGIN
--  IF (LOGIN_USER != 'TYGRYS' AND (:NEW.przydzial_myszy > :OLD.przydzial_myszy OR :NEW.myszy_extra > :OLD.myszy_extra)) THEN
--      SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = upper('Dodatki_extra');
--      IF temp = 0 THEN
--        EXECUTE IMMEDIATE 'CREATE TABLE Dodatki_extra(
--                          id NUMBER PRIMARY KEY,
--                          pseudo VARCHAR2(15) CONSTRAINT de_ps_fk REFERENCES Kocury(pseudo),
--                          dodatek NUMBER
--                          )';
--      ELSE
--        SELECT COUNT(*) INTO ilosc FROM Dodatki_extra WHERE pseudo = :OLD.pseudo;
--        IF ilosc = 0 THEN
--          INSERT INTO Dodatki_extra VALUES(indexDodatki.nextval, :OLD.pseudo, -10);
--        ELSE
--          SELECT dodatek INTO akt_dodatek FROM Dodatki_extra WHERE pseudo = :OLD.pseudo;
--          akt_dodatek := akt_dodatek - 10;
--          UPDATE Dodatki_extra SET dodatek = akt_dodatek WHERE pseudo = :OLD.pseudo;
--        END IF;
--      END IF;
--  END IF;
--END;