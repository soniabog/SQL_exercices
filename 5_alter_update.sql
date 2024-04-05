/*
Database Management - Human Resources Management - Part 5

Description:
This part focuses on assigning positions to selected 
employees and analyzing employment in the context of 
specific companies.

Author: Sonia Bogdańska
*/

--Z5.1: Assigning positions and analyzing employment in the context of companies

-- Preparing a temporary table for analysis
CREATE TABLE #n (nazwa_f nvarchar(100) not null constraint PK_n_f PRIMARY KEY)
INSERT INTO #n(nazwa_f) VALUES ('Cyfrowy Polsat'), ('Kompania Piwowarska'), ('Idea Bank')

-- Searching for people working in all companies listed in table #n
SELECT o.imie, o.nazwisko
FROM osoby o
JOIN etaty e ON o.id_osoby = e.id_osoby
JOIN firmy f ON e.id_firmy = f.nazwa_skr
JOIN #n n ON f.nazwa = n.nazwa_f
GROUP BY o.id_osoby, o.imie, o.nazwisko
HAVING COUNT(DISTINCT f.nazwa_skr) = (SELECT COUNT(*) FROM #n)

/*
imie                                     nazwisko
---------------------------------------- ----------------------------------------
Adam                                     Nowak

(1 row affected)
*/

--Z5.2: Updating the number of current positions for each person

-- Adding a column to the PERSONS table
ALTER TABLE osoby ADD ILE_AKT_ET int NOT NULL DEFAULT 0

-- Updating the number of positions for each person
UPDATE osoby
SET ILE_AKT_ET = (
	SELECT COUNT(*) FROM etaty
	WHERE etaty.id_osoby = osoby.id_osoby
	AND etaty.do IS NULL
)
WHERE EXISTS (
SELECT 1 FROM etaty WHERE etaty.id_osoby = osoby.id_osoby
);

-- Displaying the updated data
SELECT imie, nazwisko, ILE_AKT_ET FROM osoby

/*
imie                                     nazwisko                                 ILE_AKT_ET
---------------------------------------- ---------------------------------------- -----------
Adam                                     Nowak                                    2
Anna                                     Kowalska                                 2
Elsa                                     Frołzen                                  2
Piotr                                    Tętnica                                  2
Bogdan                                   Ras                                      1
Szymon                                   Abramczyk                                1
Jan                                      Alucz                                    3
Zofia                                    Krupa                                    2
Tomasz                                   Buk                                      1
Denis                                    Wolski                                   0
Stanisław                                Wokulski                                 0
Izabela                                  Łęcka                                    0

(12 rows affected)
*/

-- Cleanup
DROP TABLE IF EXISTS #n