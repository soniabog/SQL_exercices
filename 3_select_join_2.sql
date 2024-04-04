/*
Bazy Danych - Zarządzanie Zasobami Ludzkimi - część 3

Opis:
Celem tej części jest przeprowadzenie szczegółowej analizy danych pracowniczych 
w kontekście etatów, pensji oraz przynależności pracowników do poszczególnych firm. 
Poszukiwane są dane dotyczące zatrudnienia w firmie, takie jak rozkład liczby etatów 
przypadających na pracowników, analiza poziomów pensji oraz powiązanie pracowników z firmami 
na podstawie lokalizacji.

Autor: Sonia Bogdańska
*/

-- Z3.1.1: Analiza ilości etatów przypadających na poszczególnych pracowników

SELECT e.id_osoby, COUNT(*) AS ile_et
FROM etaty e
GROUP BY e.id_osoby
ORDER BY ile_et DESC;

-- Wyniki pokazują liczbę etatów przypadających na każdego pracownika.

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

-- Z3.1.2: Znalezienie i zapisanie w tabeli tymczasowej #ot danych dotyczących najniższych pensji

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

-- Tabela #ot zawiera teraz dane o najniższych pensjach dla każdej osoby.

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

-- Z3.2: Wyszukanie najniższej pensji w bazie z tabeli #ot

SELECT * 
FROM #ot
WHERE pensja = (SELECT MIN(pensja) FROM #ot);

-- Wynik zwraca szczegóły dotyczące najniższej pensji w całej bazie danych.

/*
id_osoby imie          nazwisko         pensja                nazwa_skr nazwa
-------- ------------- ---------------- --------------------- --------- --------------------
7        Jan           Alucz            500,00                KP        Kompania Piwowarska

(1 row(s) affected)

*/

-- Z3.3: Pokazanie firm, w których nie pracowała osoba o wybranym nazwisku (np. "Tętnica")

SELECT DISTINCT  LEFT(f.nazwa, 15) AS nazwa, f.nazwa_skr
FROM FIRMY f
WHERE NOT EXISTS (
	SELECT DISTINCT fw.nazwa
	FROM FIRMY fw
	JOIN ETATY e ON fw.nazwa_skr = e.id_firmy
	JOIN OSOBY o ON o.id_osoby = e.id_osoby
	WHERE o.nazwisko = 'Tętnica' AND fw.nazwa_skr =f.nazwa_skr
);

-- Wynikiem jest lista firm bez pracownika o nazwisku "Tętnica".

/*
nazwa           nazwa_skr
--------------- ---------
Cyfrowy Polsat  CP   
Idea Bank       IB   
Kompania Piwowa KP   

(3 row(s) affected)
*/

-- Z3.4: Wyszukanie firm, w których nie pracował nikt z Warszawy
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
-- w każdej firmie pracuje ktoś z Warszawy
*/
