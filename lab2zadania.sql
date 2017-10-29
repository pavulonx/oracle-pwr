--17--
SELECT
  PSEUDO          "POLUJE W POLU",
  PRZYDZIAL_MYSZY "PRYDZIAL MYSZY",
  NAZWA
FROM KOCURY K
  JOIN BANDY B ON K.NR_BANDY = B.NR_BANDY
WHERE K.PRZYDZIAL_MYSZY > 50 AND B.TEREN IN ('POLE', 'CALOSC');

--18--
SELECT
  K.IMIE                               "IMIE",
  TO_CHAR(K.W_STADKU_OD, 'YYYY-MM-DD') "POLUJE OD"
FROM KOCURY K
  JOIN KOCURY KJ ON K.W_STADKU_OD < KJ.W_STADKU_OD AND KJ.IMIE = 'JACEK'
ORDER BY K.W_STADKU_OD DESC;

--19--
SELECT
  K1.imie,
  K1.funkcja,
  K2.imie           "szef 1",
  NVL(K3.imie
  , '  ')           "szef 3",
  NVL(K4.imie, ' ') "szef 4"
FROM Kocury K1 LEFT JOIN Kocury K2 ON K1.szef = K2.pseudo
  LEFT JOIN Kocury K3 ON (K2.szef = K3.pseudo)
  LEFT JOIN Kocury K4 ON (K3.szef = K4.pseudo)
WHERE K1.funkcja IN ('KOT', 'MILUSIA');
--b--
SELECT
  CONNECT_BY_ROOT imie                                              AS "Imie",
  ' | '                                                                " ",
  funkcja                                                           AS "Funkcja",
  ' | '                                                                " ",
  NVL((SELECT imie
       FROM
         Kocury
       WHERE LEVEL = 2
       CONNECT BY PRIOR szef = pseudo
       START WITH pseudo = K.pseudo), ' ')                          AS "Szef 1",
  ' | '                                                                " ",
  NVL((SELECT imie
       FROM Kocury
       WHERE LEVEL = 3
       CONNECT BY PRIOR
                  szef = pseudo START WITH pseudo = K.pseudo), ' ') AS "
Szef 2",
  ' | '                                                                " ",
  NVL((SELECT imie
       FROM Kocury
       WHERE LEVEL = 4
       CONNECT BY PRIOR szef = pseudo
       START WITH pseudo = K.pseudo), ' ')                          AS "Szef 3"
FROM Kocury K
WHERE funkcja IN ('KOT', 'MILUSIA')
CONNECT BY PRIOR szef = pseudo
START WITH funkcja IN ('KOT', 'MILUSIA');
--c--
SELECT
  imie,
  ' | '                                                         AS " ",
  funkcja,
  RTRIM(REVERSE(RTRIM(SYS_CONNECT_BY_PATH(REVERSE(imie),
                                          ' | '), imie)), '| ') AS "Imiona kolejnych szefów"
FROM Kocury
WHERE funkcja IN ('KOT', 'MILUSIA')
CONNECT BY PRIOR pseudo = szef
START WITH szef IS NULL;

--20--
SELECT
  K.IMIE             "IMIE KOTKI",
  B.NAZWA            "NAZWA BANDY",
  WK.IMIE_WROGA      "IMIE WROGA",
  W.STOPIEN_WROGOSCI "OCENA WROGA",
  WK.DATA_INCYDENTU  "Data inc."
FROM KOCURY K
  JOIN WROGOWIE_KOCUROW WK ON K.PSEUDO = WK.PSEUDO
  JOIN BANDY B ON K.NR_BANDY = B.NR_BANDY
  JOIN WROGOWIE W ON W.IMIE_WROGA = WK.IMIE_WROGA
WHERE K.PLEC = 'D' AND WK.DATA_INCYDENTU > TO_DATE('2007-01-01', 'YYYY-MM-DD');

--21--
SELECT
  B.NAZWA                  "Nazwa bandy",
  COUNT(DISTINCT K.PSEUDO) "Koty z wrogami"

FROM BANDY B
  JOIN KOCURY K
  JOIN WROGOWIE_KOCUROW WK ON K.PSEUDO = WK.PSEUDO
  JOIN WROGOWIE ON WK.IMIE_WROGA = WROGOWIE.IMIE_WROGA ON B.NR_BANDY = K.NR_BANDY
GROUP BY B.NAZWA;

--22--
SELECT
  K.FUNKCJA        "Funkcja",
  K.PSEUDO         "Pseudonim kota",
  COUNT(WK.PSEUDO) "Liczba wrogow"
FROM KOCURY K
  JOIN WROGOWIE_KOCUROW WK ON K.PSEUDO = WK.PSEUDO
GROUP BY K.PSEUDO, K.FUNKCJA
HAVING COUNT(WK.PSEUDO) >= 2;

--23--
SELECT
  K.IMIE,
  12 * (K.PRZYDZIAL_MYSZY + K.MYSZY_EXTRA) "DAWKA ROCZNA",
  'ponizej 864'                            "DAWKA"
FROM KOCURY K
WHERE 12 * (K.PRZYDZIAL_MYSZY + K.MYSZY_EXTRA) > 864
UNION
SELECT
  K.IMIE,
  12 * (K.PRZYDZIAL_MYSZY + K.MYSZY_EXTRA) "DAWKA ROCZNA",
  '864'                                    "DAWKA"
FROM KOCURY K
WHERE 12 * (K.PRZYDZIAL_MYSZY + K.MYSZY_EXTRA) = 864
UNION
SELECT
  K.IMIE,
  12 * (K.PRZYDZIAL_MYSZY + K.MYSZY_EXTRA) "DAWKA ROCZNA",
  'powyzej 864'                            "DAWKA"

FROM KOCURY K
WHERE 12 * (K.PRZYDZIAL_MYSZY + K.MYSZY_EXTRA) < 864
ORDER BY "DAWKA ROCZNA" DESC;

--24--
SELECT
  B.NR_BANDY,
  B.NAZWA,
  B.TEREN
FROM BANDY B LEFT JOIN KOCURY K ON B.NR_BANDY = K.NR_BANDY
WHERE K.NR_BANDY IS NULL;

SELECT
  B.NR_BANDY,
  B.NAZWA,
  B.TEREN
FROM BANDY B
WHERE NOT EXISTS(SELECT *
                 FROM KOCURY K
                 WHERE K.NR_BANDY = B.NR_BANDY);

--25--
SELECT
  K.IMIE,
  K.FUNKCJA,
  K.PRZYDZIAL_MYSZY
FROM KOCURY K
WHERE K.PRZYDZIAL_MYSZY >= 3 * (SELECT *
                                FROM (SELECT K2.PRZYDZIAL_MYSZY
                                      FROM KOCURY K2
                                      WHERE K2.FUNKCJA = 'MILUSIA'
                                      ORDER BY K2.PRZYDZIAL_MYSZY DESC)
                                WHERE ROWNUM = 1);

--26--
SELECT *
FROM
  (
    SELECT
      K.FUNKCJA,
      ROUND(AVG(K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0)))                   "PRZYDZIAL MYSZY",
      DENSE_RANK()
      OVER (
        ORDER BY ROUND(AVG(K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0))) ASC )  "DRANK_ASC",
      DENSE_RANK()

      OVER (
        ORDER BY ROUND(AVG(K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0))) DESC ) "DRANK_DSC"
    FROM KOCURY K
    GROUP BY K.FUNKCJA
    HAVING K.FUNKCJA <> 'SZEFUNIO'
    ORDER BY "PRZYDZIAL MYSZY" ASC)
WHERE DRANK_ASC = 1 OR DRANK_DSC = 1;

--27--
SELECT
  PSEUDO,
  (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "ZJADA"
FROM Kocury K
WHERE 6 >= (
  SELECT DISTINCT COUNT(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))
  FROM Kocury
  WHERE NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0) < NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)
)
ORDER BY 2 DESC;

--B--
SELECT
  PSEUDO,
  NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0) "ZJADA"
FROM Kocury
WHERE NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0) IN (
  SELECT *
  FROM (
    SELECT DISTINCT NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)
    FROM Kocury
    ORDER BY 1 DESC
  )
  WHERE ROWNUM <= 6
);

--C--
SELECT
  K.PSEUDO,
  K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0) "ZJADA"
FROM KOCURY K FULL OUTER JOIN KOCURY K2
    ON K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0) < K2.PRZYDZIAL_MYSZY + NVL(K2.MYSZY_EXTRA, 0)
GROUP BY K.PSEUDO, K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0)
HAVING COUNT(*) <= 6 AND K.PSEUDO IS NOT NULL
ORDER BY ZJADA DESC;

--D--
SELECT
  PSEUDO,
  ZJADA
FROM (SELECT
        K.PSEUDO                                                    "PSEUDO",
        K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0)                   "ZJADA",
        RANK()
        OVER (
          ORDER BY K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0) DESC ) "RANK"
      FROM KOCURY K)
WHERE RANK <= 6;

--28--
