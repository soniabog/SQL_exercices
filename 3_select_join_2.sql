/*
Database Management - Human Resources Management - Part 3

Description:
The goal of this part is to conduct a detailed analysis of employee data 
in the context of positions, salaries, and the affiliation of employees to specific companies. 
Sought are data regarding employment in the company, such as the distribution of the number of positions 
per employees, salary levels analysis, and linking employees with companies 
based on location.

Author: Sonia Bogdańska
*/

-- Z3.1.1: Analysis of the number of positions per individual employees

SELECT e.id_osoby, COUNT(*) AS ile_et
FROM etaty e
GROUP BY e.id_osoby
ORDER BY ile_et DESC;

-- The results show the number of positions held by each employee.

/* id_osoby    ile_et
----------- -----------
1           3
2           3
4           3
7           3
8           2
5           2
6           1
3           1
9           1

(9 row(s) affected)
*/

-- Z3.1.2: Finding and storing data about the lowest salaries in the temporary table #ot

IF OBJECT_ID(N'tempdb..#ot') IS NOT NULL
	DROP TABLE #ot

SELECT
	LEFT(o.id_osoby, 3) AS id_osoby,
	LEFT(o.imie, 13) AS imie, 
	LEFT(o.nazwisko, 16) AS nazwisko,
	e.pensja,
	LEFT(f.nazwa_skr, 5) AS nazwa_skr, 
	LEFT(f.nazwa, 20) AS nazwa 
INTO #ot
FROM osoby o
JOIN etaty e ON e.id_osoby = o.id_osoby
JOIN firmy f ON f.nazwa_skr = e.id_firmy
WHERE e.pensja = (
	SELECT MIN(e.pensja) AS min_pensja
	FROM etaty e
	WHERE e.id_osoby = o.id_osoby
);

-- The #ot table now contains data about the lowest salaries for each person.

/*
id_osoby imie          nazwisko         pensja   nazwa_skr nazwa
-------- ------------- ---------------- -------- --------- --------------------
1        Adam          Nowak            3400.00  IB        Idea Bank
2        Anna          Kowalska         10000.00 EP        ENEA Pozna�
3        Elsa          Fro�zen          40000.00 KP        Kompania Piwowarska
4        Piotr         T�tnica          4000.00  VP        Volskwagen
5        Bogdan        Ras              16000.00 CP        Cyfrowy Polsat
6        Szymon        Abramczyk        6000.00  KP        Kompania Piwowarska
7        Jan           Alucz            500.00   KP        Kompania Piwowarska
8        Zofia         Krupa            3200.00  CP        Cyfrowy Polsat
9        Tomasz        Buk              9800.00  EP        ENEA Pozna�

(9 row(s) affected)

*/

-- Z3.2: Finding the lowest salary in the database from table #ot

SELECT * 
FROM #ot
WHERE pensja = (SELECT MIN(pensja) FROM #ot);

-- The result returns details about the lowest salary in the entire database.

/*
id_osoby imie          nazwisko         pensja                nazwa_skr nazwa
-------- ------------- ---------------- --------------------- --------- --------------------
7        Jan           Alucz            500,00                KP        Kompania Piwowarska

(1 row(s) affected)

*/

-- Z3.3: Showing companies where an individual with a selected surname (e.g., "Tętnica") has not worked

SELECT DISTINCT  LEFT(f.nazwa, 15) AS nazwa, f.nazwa_skr
FROM FIRMY f
WHERE NOT EXISTS (
	SELECT DISTINCT fw.nazwa
	FROM FIRMY fw
	JOIN ETATY e ON fw.nazwa_skr = e.id_firmy
	JOIN OSOBY o ON o.id_osoby = e.id_osoby
	WHERE o.nazwisko = 'Tętnica' AND fw.nazwa_skr =f.nazwa_skr
);

-- The result is a list of companies without an employee with the surname "Tętnica".

/*
nazwa           nazwa_skr
--------------- ---------
Cyfrowy Polsat  CP   
Idea Bank       IB   
Kompania Piwowa KP   

(3 row(s) affected)
*/

-- Z3.4: Finding companies where no one from Warsaw has worked
SELECT DISTINCT f.nazwa_skr, LEFT(f.nazwa,15) AS nazwa, m.nazwa AS miasto_firmy, w.nazwa AS województwo_firmy
FROM FIRMY f
JOIN MIASTA m ON m.id_miasta = f.id_miasta
JOIN WOJ w ON w.kod_woj = m.kod_woj
WHERE NOT EXISTS (
	SELECT DISTINCT fw.nazwa_skr
	FROM FIRMY fw
	JOIN ETATY ew ON (fw.nazwa_skr = ew.id_firmy)
	JOIN OSOBY ow ON (ow.id_osoby = ew.id_osoby)
	JOIN MIASTA mw ON (mw.id_miasta = ow.id_miasta)
	WHERE mw.nazwa = 'Warszawa' AND fw.nazwa_skr =f.nazwa_skr
);

/*
nazwa_skr nazwa           miasto_firmy                             województwo_firmy
--------- --------------- ---------------------------------------- ----------------------------------------
CP        Cyfrowy Polsat  Warszawa                                 Mazowieckie
EP        ENEA Pozna�     Pozna�                                   Wielkopolskie
IB        Idea Bank       Warszawa                                 Mazowieckie
KP        Kompania Piwowa Pozna�                                   Wielkopolskie
VP        Volskwagen      Pozna�                                   Wielkopolskie

(5 row(s) affected)
-- everyone has someone from Warsaw working
*/
