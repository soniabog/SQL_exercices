/*
Bazy Danych - Zarządzanie Zasobami Ludzkimi - część 5

Opis:
Część ta koncentruje się na przypisywaniu etatów do wybranych 
pracowników oraz analizie zatrudnienia w kontekście specyficznych 
firm.

Autor: Sonia Bogdańska
*/

--Z5.1: Przypisywanie etatów i analiza zatrudnienia w kontekście firm

-- Przygotowanie tabeli tymczasowej do analizy
CREATE TABLE #n (nazwa_f nvarchar(100) not null constraint PK_n_f PRIMARY KEY)
INSERT INTO #n(nazwa_f) VALUES ('Cyfrowy Polsat'), ('Kompania Piwowarska'), ('Idea Bank')

-- Wyszukiwanie osób pracujących we wszystkich firmach z tabeli #n
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

--Z5.2: Aktualizacja liczby aktualnych etatów dla każdej osoby

-- Dodanie kolumny do tabeli OSOBY
ALTER TABLE osoby ADD ILE_AKT_ET int NOT NULL DEFAULT 0

-- Aktualizacja liczby etatów dla każdej osoby
UPDATE osoby
SET ILE_AKT_ET = (
	SELECT COUNT(*) FROM etaty
	WHERE etaty.id_osoby = osoby.id_osoby
	AND etaty.do IS NULL
)
WHERE EXISTS (
SELECT 1 FROM etaty WHERE etaty.id_osoby = osoby.id_osoby
);

-- Wyświetlenie zaktualizowanych danych
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

-- Zakończenie i czyszczenie
DROP TABLE IF EXISTS #n