ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
--1--
SELECT
  IMIE_WROGA     "WROG",
  OPIS_INCYDENTU "PRZEWINA"
FROM WROGOWIE_KOCUROW
WHERE extract(YEAR FROM DATA_INCYDENTU) = 2009;

SELECT
  IMIE_WROGA     "WROG",
  OPIS_INCYDENTU "PRZEWINA"
FROM WROGOWIE_KOCUROW
WHERE DATA_INCYDENTU LIKE '%2009%';

--2--
SELECT
  IMIE,
  FUNKCJA,
  W_STADKU_OD "Z NAMI OD"
FROM KOCURY
WHERE PLEC = 'D' AND W_STADKU_OD BETWEEN '2005-09-01' AND '2007-07-31';

--3--
SELECT
  imie_wroga       "WROG",
  gatunek,
  stopien_wrogosci "STOPIEN WROGOSCI"
FROM Wrogowie
WHERE lapowka IS NULL
ORDER BY stopien_wrogosci ASC;

--4--
SELECT imie || ' zwany ' || pseudo || ' (fun. ' || funkcja || ') lowi myszki w bandzie'
       || nr_bandy || ' od ' || w_stadku_od "WSZYSTKO O KOCURACH"
FROM Kocury
WHERE plec = 'M'
ORDER BY w_stadku_od DESC, pseudo ASC;

--5--
SELECT
  pseudo,
  REGEXP_REPLACE(
      REGEXP_REPLACE(pseudo, 'L', '%', 1, 1),
      'A', '#', 1, 1
  ) "Po wymianie A na # oraz L na %"
FROM Kocury
WHERE pseudo LIKE '%L%' AND pseudo LIKE '%A%';

--6 nie dziala add months--
SELECT
  imie,
  w_stadku_od                               "w stadku",
  ROUND(NVL((przydzial_myszy * 0.9), 0), 0) "Zjadal",
  ADD_MONTHS(w_stadku_od, 6)                "Podwyzka",
  przydzial_myszy                           "Zjada"
FROM Kocury
WHERE
  (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM w_stadku_od)) > 7 AND EXTRACT(MONTH FROM w_stadku_od) BETWEEN 3 AND 9;

--7--
SELECT *
FROM kocury;
SELECT
  imie,
  NVL(przydzial_myszy, 0) * 3 "MYSZY KWARTALNE",
  NVL(myszy_extra, 0) * 3     "KWARTALNE DODATKI"
FROM Kocury
WHERE (przydzial_myszy) > NVL(myszy_extra, 0) * 2 AND NVL(przydzial_myszy, 0) >= 55;

--8--
SELECT
  imie,
  CASE
  WHEN (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) * 12 = 660
    THEN 'LIMIT'
  WHEN (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) * 12 > 660
    THEN
      TO_CHAR((NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) * 12)
  ELSE 'Ponizej 660' END "Zjada rocznie"
FROM Kocury
ORDER BY imie ASC;

--9--
--a
SELECT
  PSEUDO,
  to_char(W_STADKU_OD, 'yyyy-mm-dd') "W STADKU",
  to_char(CASE
          WHEN EXTRACT(DAY FROM W_STADKU_OD) <= 15
            THEN
              CASE
              WHEN NEXT_DAY(LAST_DAY(TO_DATE('2017-10-23', 'yyyy-mm-dd')) - 7, 'WEDNESDAY') <
                   TO_DATE('2017-10-23', 'yyyy-mm-dd')
                THEN NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2017-10-26', 'yyyy-mm-dd'), 1)) - 7, 'WEDNESDAY')
              ELSE
                NEXT_DAY(LAST_DAY(TO_DATE('2017-10-23', 'yyyy-mm-dd')) - 7, 'WEDNESDAY')
              END
          ELSE
            NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2017-10-23', 'yyyy-mm-dd'), 1)) - 7, 'WEDNESDAY')
          END, 'yyyy-mm-dd')         "WYPLATA"
FROM Kocury;
--b
SELECT
  PSEUDO,
  to_char(W_STADKU_OD, 'yyyy-mm-dd') "W STADKU",
  to_char(CASE
          WHEN EXTRACT(DAY FROM W_STADKU_OD) <= 15
            THEN
              CASE
              WHEN NEXT_DAY(LAST_DAY(TO_DATE('2017-10-26', 'yyyy-mm-dd')) - 7, 'WEDNESDAY') <
                   TO_DATE('2017-10-26', 'yyyy-mm-dd')
                THEN NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2017-10-26', 'yyyy-mm-dd'), 1)) - 7, 'WEDNESDAY')
              ELSE
                NEXT_DAY(LAST_DAY(TO_DATE('2017-10-26', 'yyyy-mm-dd')) - 7, 'WEDNESDAY')
              END
          ELSE
            NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2017-10-26', 'yyyy-mm-dd'), 1)) - 7, 'WEDNESDAY')
          END, 'yyyy-mm-dd')         "WYPLATA"
FROM Kocury;

--10--
SELECT CASE COUNT(pseudo)
       WHEN 1
         THEN pseudo || ' - Unikalny'
       ELSE pseudo || ' - Nieunikalny'
       END "Unikalnosc atr.PSEUDO"
FROM Kocury
GROUP BY pseudo;

--szef--

SELECT CASE COUNT(szef)
       WHEN 1
         THEN szef || ' - Unikalny'
       ELSE szef || ' - Nieunikalny'
       END "Unikalnosc atr. SZEF"
FROM Kocury
WHERE szef IS NOT NULL
GROUP BY szef;

--11--
SELECT
  pseudo,
  COUNT(imie_wroga) "Liczba wrogow"
FROM WROGOWIE_KOCUROW
GROUP BY pseudo
HAVING COUNT(imie_wroga) >= 2;

--12--

SELECT
  'Liczba kotow='                                    " ",
  COUNT(*)                                           "  ",
  'lowi jako'                                        "   ",
  funkcja                                            "    ",
  'i zjada max.'                                     "     ",
  MAX(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) "      "
FROM Kocury
WHERE
  funkcja <> 'SZEFUNIO'
  AND plec <> 'M'
GROUP BY funkcja
HAVING AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) > 50;

--13--
SELECT
  nr_bandy                     "Nr Bandy",
  plec                         "Plec",
  MIN(NVL(przydzial_myszy, 0)) "Minimalny przydzial"
FROM Kocury
GROUP BY nr_bandy, plec;

--14--
SELECT
  LEVEL    "Poziom",
  pseudo   "Pseudonim",
  funkcja  "Funkcja",
  nr_bandy "Nr Bandy"
FROM Kocury
WHERE plec = 'M'
CONNECT BY PRIOR pseudo = szef
START WITH funkcja = 'BANDZIOR';

--15--
SELECT
  RPAD((LPAD((LEVEL - 1), (LEVEL - 1) * 4 + 1, '===>')), 16) ||
  LPAD(' ', (LEVEL - 1) * 4) || imie "Hierarchia",
  NVL(SZEF, 'Sam sobie panem')       "Pseudo szefa",
  funkcja                            "Funkcja"
FROM Kocury
WHERE NVL(MYSZY_EXTRA, 0) > 0
START WITH SZEF IS NULL
CONNECT BY PRIOR PSEUDO = SZEF;

--16--
SELECT LPAD('   ', 4 * (LEVEL - 1)) || pseudo "Droga sluzbowa"
FROM Kocury
CONNECT BY PRIOR SZEF = PSEUDO
START WITH plec = 'M' AND (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM w_stadku_od)) > 7 AND NVL(myszy_extra, 0) = 0;