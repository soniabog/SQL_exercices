/*
Bazy Danych - Zarządzanie Zasobami Ludzkimi - część 2

Opis:
Analiza Pensji i Lokalizacji w Bazie Danych Pracowników. Celem jest przedstawienie analizy wysokości 
pensji w kontekście firm i lokalizacji pracowników.

Autor: Sonia Bogdańska
*/

-- Zadanie Z2.1: Znalezienie i prezentacja najwyższej pensji w wybranej firmie

-- Ustalenie najwyższej pensji w firmie 'EP'
DECLARE @p money
SELECT @p = (SELECT MAX(e.pensja) FROM ETATY e WHERE id_firmy='EP')

-- Prezentacja pracownika z najwyższą pensją w firmie 'EP'
SELECT 
    LEFT(o.imie, 10) AS 'Imię',
    LEFT(o.nazwisko, 15) AS 'Nazwisko',
    e.pensja AS 'Pensja',
    LEFT(f.nazwa, 20) AS 'Nazwa Firmy'
FROM ETATY e 
JOIN OSOBY o ON o.id_osoby = e.id_osoby 
JOIN FIRMY f ON f.nazwa_skr = e.id_firmy
WHERE e.pensja = @p

-- Wynik pokazuje osobę o najwyższej pensji w firmie 'EP' (ENEA Poznań)
/*
Wyniki:
Imię       Nazwisko        Pensja                Nazwa Firmy
---------- --------------- --------------------- --------------------
Piotr      Tętnica         30000.00              ENEA Poznań
(1 row(s) affected)
*/

-- Zadanie Z2.2: Prezentacja danych etatów, osób i firm z określonymi warunkami lokalizacji

-- Prezentacja szczegółów etatów i danych osobowych pracowników, z uwzględnieniem firm i lokalizacji
SELECT 
    LEFT(e.pensja, 10) AS 'Pensja',
    LEFT(e.stanowisko, 15) AS 'Stanowisko',
    LEFT(o.imie, 15) AS 'Imię',
    LEFT(o.nazwisko, 20) AS 'Nazwisko',
    LEFT(f.nazwa, 20) AS 'Nazwa Firmy',
    LEFT(mf.nazwa, 25) AS 'Miasto Firmy',
    LEFT(mo.nazwa, 15) AS 'Miasto Osoby',
    mf.kod_woj AS 'Kod Woj. Firmy',
    mo.kod_woj AS 'Kod Woj. Osoby'
FROM OSOBY o 
JOIN etaty e ON o.id_osoby = e.id_osoby 
JOIN firmy f ON f.nazwa_skr = e.id_firmy
JOIN MIASTA mf ON f.id_miasta = mf.id_miasta
JOIN MIASTA mo ON o.id_miasta = mo.id_miasta
WHERE LEFT(mo.kod_woj,1) = 'W' AND LEFT(mf.kod_woj,1) = 'M'

-- Wynik prezentuje dane etatów i osobowe pracowników spełniających kryteria lokalizacji

/*
Wyniki:
Pensja     Stanowisko      Imię            Nazwisko             Nazwa Firmy          Miasto Firmy              Miasto Osoby       Kod Woj. Firmy Kod Woj. Osoby
---------- --------------- --------------- -------------------- -------------------- ------------------------- ------------------ ------------- -------------
4000.00    sprzątaczka     Zofia           Krupa                Idea Bank            Warszawa                  Jarocin            MAZ           WLK
3200.00    sprzątaczka     Zofia           Krupa                Cyfrowy Polsat       Warszawa                  Jarocin            MAZ           WLK
(2 row(s) affected)
*/
