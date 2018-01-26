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
--A
SELECT
  K1.IMIE,
  K1.FUNKCJA,
  K2.IMIE           "SZEF 1",
  NVL(K3.IMIE
  , '  ')           "SZEF 3",
  NVL(K4.IMIE, ' ') "SZEF 4"
FROM KOCURY K1 LEFT JOIN KOCURY K2 ON K1.SZEF = K2.PSEUDO
  LEFT JOIN KOCURY K3 ON (K2.SZEF = K3.PSEUDO)
  LEFT JOIN KOCURY K4 ON (K3.SZEF = K4.PSEUDO)
WHERE K1.FUNKCJA IN ('KOT', 'MILUSIA');

--B---------------------------------------------------------------------------------------------------------------------
SELECT
  IMIE          "IMIE",
  FUNKCJA       "FUNKCJA",
  NVL("1", ' ') "SZEF1",
  NVL("2", ' ') "SZEF2",
  NVL("3", ' ') "SZEF3"
FROM (SELECT
        CONNECT_BY_ROOT IMIE    "IMIE",
        CONNECT_BY_ROOT FUNKCJA "FUNKCJA",
        LEVEL                   "LVL",
        SZEF
      FROM KOCURY K
      CONNECT BY PRIOR SZEF = PSEUDO
      START WITH FUNKCJA IN ('KOT', 'MILUSIA')
)
      PIVOT (
        MIN(SZEF)
        FOR LVL
        IN (1, 2, 3)
      );
------------------------------------------------------------------------------------------------------------------------

--C
SELECT
  IMIE,
  ' | '                                                         AS " ",
  FUNKCJA,
  RTRIM(REVERSE(RTRIM(SYS_CONNECT_BY_PATH(REVERSE(IMIE),
                                          ' | '), IMIE)), '| ') AS "IMIONA KOLEJNYCH SZEFÓW"
FROM KOCURY
WHERE FUNKCJA IN ('KOT', 'MILUSIA')
CONNECT BY PRIOR PSEUDO = SZEF
START WITH SZEF IS NULL;

--20--
SELECT
  K.IMIE             "IMIE KOTKI",
  B.NAZWA            "NAZWA BANDY",
  WK.IMIE_WROGA      "IMIE WROGA",
  W.STOPIEN_WROGOSCI "OCENA WROGA",
  WK.DATA_INCYDENTU  "DATA INC."
FROM KOCURY K
  JOIN WROGOWIE_KOCUROW WK ON K.PSEUDO = WK.PSEUDO
  JOIN BANDY B ON K.NR_BANDY = B.NR_BANDY
  JOIN WROGOWIE W ON W.IMIE_WROGA = WK.IMIE_WROGA
WHERE K.PLEC = 'D' AND WK.DATA_INCYDENTU > TO_DATE('2007-01-01', 'YYYY-MM-DD');

--21--
SELECT
  B.NAZWA                  "NAZWA BANDY",
  COUNT(DISTINCT K.PSEUDO) "KOTY Z WROGAMI"
FROM BANDY B
  JOIN KOCURY K
  JOIN WROGOWIE_KOCUROW WK ON K.PSEUDO = WK.PSEUDO
  JOIN WROGOWIE ON WK.IMIE_WROGA = WROGOWIE.IMIE_WROGA ON B.NR_BANDY = K.NR_BANDY
GROUP BY B.NAZWA;

--22--
SELECT
  K.FUNKCJA        "FUNKCJA",
  K.PSEUDO         "PSEUDONIM KOTA",
  COUNT(WK.PSEUDO) "LICZBA WROGOW"
FROM KOCURY K
  JOIN WROGOWIE_KOCUROW WK ON K.PSEUDO = WK.PSEUDO
GROUP BY K.PSEUDO, K.FUNKCJA
HAVING COUNT(WK.PSEUDO) >= 2;

--23--
SELECT
  K.IMIE,
  12 * (K.PRZYDZIAL_MYSZY + K.MYSZY_EXTRA) "DAWKA ROCZNA",
  'PONIZEJ 864'                            "DAWKA"
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
  'POWYZEJ 864'                            "DAWKA"

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
FROM KOCURY K
WHERE &HOWMANY > (
  SELECT DISTINCT COUNT(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))
  FROM KOCURY
  WHERE NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0) < NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)
)
ORDER BY 2 DESC;

--B--
SELECT
  PSEUDO,
  NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0) "ZJADA"
FROM KOCURY
WHERE NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0) IN (
  SELECT *
  FROM (
    SELECT DISTINCT NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)
    FROM KOCURY
    ORDER BY 1 DESC
  )
  WHERE ROWNUM <= &HOWMANY
);

--C--
SELECT
  K.PSEUDO,
  K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0) "ZJADA"
FROM KOCURY K FULL OUTER JOIN KOCURY K2
    ON K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0) < K2.PRZYDZIAL_MYSZY + NVL(K2.MYSZY_EXTRA, 0)
GROUP BY K.PSEUDO, K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0)
HAVING COUNT(*) <= &HOWMANY AND K.PSEUDO IS NOT NULL
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
WHERE RANK <= &HOWMANY;

--28--
SELECT
  EXTRACT(YEAR FROM W_STADKU_OD) || '',
  COUNT(PSEUDO)
FROM KOCURY
GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
HAVING COUNT(PSEUDO) IN (
  (
    SELECT *
    FROM
      (SELECT DISTINCT COUNT(PSEUDO)
       FROM KOCURY
       GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
       HAVING COUNT(PSEUDO) > (
         SELECT AVG(COUNT(EXTRACT(YEAR FROM W_STADKU_OD)))
         FROM KOCURY
         GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
       )
       ORDER BY COUNT(PSEUDO))
    WHERE ROWNUM = 1
  ),
  (
    SELECT *
    FROM
      (SELECT DISTINCT COUNT(PSEUDO)
       FROM KOCURY
       GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
       HAVING COUNT(PSEUDO) < (
         SELECT AVG(COUNT(EXTRACT(YEAR FROM W_STADKU_OD)))
         FROM KOCURY
         GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
       )
       ORDER BY COUNT(PSEUDO) DESC)
    WHERE ROWNUM = 1
  )
)
UNION
SELECT
  'SREDNIA',
  ROUND(AVG(COUNT(EXTRACT(YEAR FROM W_STADKU_OD))), 7)
FROM KOCURY
GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
ORDER BY 2;

--29--
--A
SELECT
  K.IMIE,
  NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0)        "ZJADA",
  K.NR_BANDY,
  AVG(NVL(K2.PRZYDZIAL_MYSZY, 0) + NVL(K2.MYSZY_EXTRA, 0)) "SREDNIA BANDY"
FROM KOCURY K
  JOIN KOCURY K2 ON K.NR_BANDY = K2.NR_BANDY
WHERE K.PLEC = 'M'
GROUP BY K.IMIE, K.PRZYDZIAL_MYSZY, K.MYSZY_EXTRA, K.NR_BANDY
HAVING NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0) < AVG(NVL(K2.PRZYDZIAL_MYSZY, 0) + NVL(K2.MYSZY_EXTRA, 0));

--B
SELECT
  K.IMIE,
  NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0) "ZJADA",
  K.NR_BANDY,
  R.AVG                                             "SREDNIA BANDY"
FROM KOCURY K
  JOIN (SELECT
          AVG(NVL(K2.PRZYDZIAL_MYSZY, 0) + NVL(K2.MYSZY_EXTRA, 0)) "AVG",
          K2.NR_BANDY
        FROM KOCURY K2
        GROUP BY NR_BANDY) R
    ON K.NR_BANDY = R.NR_BANDY
WHERE K.PLEC = 'M' AND NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0) < R.AVG;

--C
SELECT
  K.IMIE,
  NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0)  "ZJADA",
  K.NR_BANDY,
  TO_CHAR((SELECT AVG(NVL(KS.PRZYDZIAL_MYSZY, 0) + NVL(KS.MYSZY_EXTRA, 0))
           FROM KOCURY KS
           WHERE K.NR_BANDY = KS.NR_BANDY), '99.99') "SREDNIA BANDY"
FROM KOCURY K
WHERE K.PLEC = 'M'
      AND NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0) <
          (SELECT AVG(NVL(KW.PRZYDZIAL_MYSZY, 0) + NVL(KW.MYSZY_EXTRA, 0))
           FROM KOCURY KW
           WHERE K.NR_BANDY = KW.NR_BANDY);

--30--
SELECT
  IMIE,
  W_STADKU_OD "WSTAPIL DO STADKA",
  ' '         " "
FROM KOCURY K
WHERE W_STADKU_OD != (SELECT MAX(W_STADKU_OD)
                      FROM KOCURY
                      WHERE K.NR_BANDY = NR_BANDY)
      AND W_STADKU_OD != (SELECT MIN(W_STADKU_OD)
                          FROM KOCURY
                          WHERE K.NR_BANDY = NR_BANDY)
UNION ALL
SELECT
  K.IMIE,
  K.W_STADKU_OD                                                       "WSTAPIL DO STADKA",
  '<--- NAJMLODSZY STAZEM W BANDZIE ' || K.NR_BANDY || ' ' || B.NAZWA " "
FROM KOCURY K
  JOIN BANDY B ON B.NR_BANDY = K.NR_BANDY
WHERE K.W_STADKU_OD = (SELECT MAX(W_STADKU_OD)
                       FROM KOCURY MAX_K
                       WHERE MAX_K.NR_BANDY = K.NR_BANDY)
UNION ALL
SELECT
  IMIE,
  W_STADKU_OD                                  "WSTAPIL DO STADKA",
  '<--- NAJSTARSZY STAZEM W BANDZIE ' || NAZWA " "
FROM KOCURY K
  JOIN BANDY B ON B.NR_BANDY = K.NR_BANDY
WHERE K.W_STADKU_OD = (SELECT MIN(W_STADKU_OD)
                       FROM KOCURY MIN_K
                       WHERE MIN_K.NR_BANDY = K.NR_BANDY)
ORDER BY 1;

--31--
CREATE OR REPLACE VIEW STAT_BANDY AS
  SELECT
    B.NAZWA                        "NAZWA_BANDY",
    AVG(NVL(K.PRZYDZIAL_MYSZY, 0)) "SREDNIE_SPOZ",
    MAX(NVL(K.PRZYDZIAL_MYSZY, 0)) "MAX_SPOZ",
    MIN(NVL(K.PRZYDZIAL_MYSZY, 0)) "MIN_SPOZ",
    COUNT(PSEUDO)                  "KOTY",
    COUNT(MYSZY_EXTRA)             "KOTY_Z_DOD"
  FROM BANDY B
    JOIN KOCURY K ON B.NR_BANDY = K.NR_BANDY
  GROUP BY B.NAZWA;

SELECT *
FROM STAT_BANDY;

SELECT
  K.PSEUDO                                          "PSEUDONIM",
  K.IMIE,
  K.FUNKCJA,
  NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0) "ZJADA",
  'OD ' || SB.MIN_SPOZ || ' DO ' || SB.MAX_SPOZ     "GRANICE SPOZYCIA",
  TO_CHAR(K.W_STADKU_OD, 'YYYY-MM-DD')              "LOWI OD"

FROM KOCURY K
  JOIN BANDY B ON K.NR_BANDY = B.NR_BANDY
  JOIN STAT_BANDY SB ON SB.NAZWA_BANDY = B.NAZWA
WHERE K.PSEUDO = &PSEUDO;

--32--
CREATE OR REPLACE VIEW OLDEST AS
  SELECT
    PSEUDO "PSEUDONIM",
    PLEC   "PLEC",
    "PRZYDZIAL_MYSZY",
    "MYSZY_EXTRA"
  FROM (
    SELECT
      K.PSEUDO,
      K.PLEC,
      NVL(K.PRZYDZIAL_MYSZY, 0)  "PRZYDZIAL_MYSZY",
      NVL(K.MYSZY_EXTRA, 0)      "MYSZY_EXTRA",
      DENSE_RANK()
      OVER (
        PARTITION BY K.NR_BANDY
        ORDER BY K.W_STADKU_OD ) "RANK"
    FROM KOCURY K
      JOIN BANDY B ON K.NR_BANDY = B.NR_BANDY
    WHERE B.NAZWA IN ('CZARNI RYCERZE', 'LACIACI MYSLIWI')
  )
  WHERE RANK <= 3;

SELECT
  "PSEUDONIM",
  "PLEC",
  PRZYDZIAL_MYSZY "MYSZY PRZED PODW.",
  MYSZY_EXTRA     "EXTRA PRZED PODW."
FROM OLDEST;

UPDATE KOCURY K
SET K.PRZYDZIAL_MYSZY = CASE
                        WHEN K.PLEC = 'D'
                          THEN K.PRZYDZIAL_MYSZY + 0.1 * (SELECT MIN(NVL(PRZYDZIAL_MYSZY, 0))
                                                          FROM KOCURY)
                        ELSE K.PRZYDZIAL_MYSZY + 10 END,

  K.MYSZY_EXTRA       = ROUND(NVL(K.MYSZY_EXTRA, 0) + 0.15 * (SELECT AVG(NVL(MYSZY_EXTRA, 0))
                                                              FROM KOCURY
                                                              WHERE NR_BANDY = K.NR_BANDY));

SELECT
  "PSEUDONIM",
  "PLEC",
  PRZYDZIAL_MYSZY "MYSZY PO PODW.",
  MYSZY_EXTRA     "EXTRA PO PODW."
FROM OLDEST;

ROLLBACK;

--33--
--A
SELECT
  DECODE(PLEC, 'KOTKA', ' ', NAZWA) NAZWA,
  PLEC,
  ILE,
  SZEFUNIO,
  BANDZIOR,
  LOWCZY,
  LAPACZ,
  KOT,
  MILUSIA,
  DZIELCZY,
  SUMA
FROM (
  SELECT
    NAZWA,
    DECODE(PLEC, 'M', 'KOCOR', 'KOTKA')                                                         PLEC,
    TO_CHAR(COUNT(PSEUDO))                                                                      ILE,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'SZEFUNIO', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) SZEFUNIO,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'BANDZIOR', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) BANDZIOR,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'LOWCZY', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))   LOWCZY,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'LAPACZ', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))   LAPACZ,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'KOT', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))      KOT,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'MILUSIA', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))  MILUSIA,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'DZIELCZY', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) DZIELCZY,
    TO_CHAR(SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)))                                 SUMA
  FROM KOCURY
    NATURAL JOIN BANDY
  GROUP BY NAZWA, PLEC
  UNION
  SELECT
    '---------------',
    '------',
    '--------',
    '---------',
    '---------',
    '--------',
    '--------',
    '--------',
    '--------',
    '--------',
    '--------'
  FROM DUAL
  UNION
  SELECT
    'ZJADA RAZEM'                                                                               NAZWA,
    ' '                                                                                         PLEC,
    ' '                                                                                         ILE,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'SZEFUNIO', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) SZEFUNIO,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'BANDZIOR', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) BANDZIOR,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'LOWCZY', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))   LOWCZY,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'LAPACZ', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))   LAPACZ,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'KOT', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))      KOT,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'MILUSIA', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))  MILUSIA,
    TO_CHAR(SUM(DECODE(FUNKCJA, 'DZIELCZY', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) DZIELCZY,
    TO_CHAR(SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)))                                 SUMA
  FROM KOCURY
    JOIN BANDY ON KOCURY.NR_BANDY = BANDY.NR_BANDY
  ORDER BY 1, 2
);

--B

SELECT
  DECODE(PLEC, 'KOTKA', '   ', NAZWA) NAZWA,
  PLEC,
  ILE,
  SZEFUNIO,
  BANDZIOR,
  LOWCZY,
  LAPACZ,
  KOT,
  MILUSIA,
  DZIELCZY,
  HONOROWA
FROM ((
        SELECT
          NAZWA,
          DECODE(PLEC, 'M', 'KOCOR', 'KOTKA') PLEC,
          TO_CHAR(R.NCOUNT)                   ILE,
          NVL(SZEFUNIO, 0)                    SZEFUNIO,
          NVL(BANDZIOR, 0)                    BANDZIOR,
          NVL(LOWCZY, 0)                      LOWCZY,
          NVL(LAPACZ, 0)                      LAPACZ,
          NVL(KOT, 0)                         KOT,
          NVL(MILUSIA, 0)                     MILUSIA,
          NVL(DZIELCZY, 0)                    DZIELCZY,
          NVL(HONOROWA, 0)                    HONOROWA
        FROM (
          SELECT
            NAZWA,
            PLEC,
            FUNKCJA,
            NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0) LICZBA
          FROM KOCURY
            JOIN BANDY ON KOCURY.NR_BANDY = BANDY.NR_BANDY
          GROUP BY NAZWA, FUNKCJA, PLEC, NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)
          )
          PIVOT (
            SUM(LICZBA)
            FOR FUNKCJA
            IN (
              'SZEFUNIO' SZEFUNIO,
              'BANDZIOR' BANDZIOR,
              'LOWCZY' LOWCZY,
              'LAPACZ' LAPACZ,
              'KOT' KOT,
              'MILUSIA' MILUSIA,
              'DZIELCZY' DZIELCZY,
              'HONOROWA' HONOROWA
            )
          )
          JOIN (SELECT
                  COUNT(*) NCOUNT,
                  NAZWA    NNAZWA,
                  PLEC     NPLEC
                FROM KOCURY
                  JOIN BANDY ON KOCURY.NR_BANDY = BANDY.NR_BANDY
                GROUP BY NAZWA, PLEC) R ON R.NNAZWA = NAZWA AND R.NPLEC = PLEC
      )
      UNION (
        (SELECT
           'ZJADA RAZEM',
           '    ',
           '     ',
           NVL(SUM(SZEFUNIO), 0) SZEFUNIO,
           NVL(SUM(BANDZIOR), 0) BANDZIOR,
           NVL(SUM(LOWCZY), 0)   LOWCZY,
           NVL(SUM(LAPACZ), 0)   LAPACZ,
           NVL(SUM(KOT), 0)      KOT,
           NVL(SUM(MILUSIA), 0)  MILUSIA,
           NVL(SUM(DZIELCZY), 0) DZIELCZY,
           NVL(SUM(HONOROWA), 0) HONOROWA
         FROM (
           SELECT
             NAZWA,
             PLEC,
             FUNKCJA,
             NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0) LICZBA
           FROM KOCURY
             JOIN BANDY ON KOCURY.NR_BANDY = BANDY.NR_BANDY
           GROUP BY NAZWA, FUNKCJA, PLEC, NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)
         )
           PIVOT (
             SUM(LICZBA)
             FOR FUNKCJA
             IN (
               'SZEFUNIO' SZEFUNIO,
               'BANDZIOR' BANDZIOR,
               'LOWCZY' LOWCZY,
               'LAPACZ' LAPACZ,
               'KOT' KOT,
               'MILUSIA' MILUSIA,
               'DZIELCZY' DZIELCZY,
               'HONOROWA' HONOROWA
             )
           )
        )
      )
      ORDER BY 1, 2
);

