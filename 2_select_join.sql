/*
Database Management - Human Resources Management - Part 2

Description:
Analysis of Salaries and Locations in the Employee Database. The goal is to present an analysis of 
salary levels in the context of companies and employee locations.

Author: Sonia Bogdańska
*/

-- Task Z2.1: Finding and presenting the highest salary in a selected company

-- Determining the highest salary in 'EP' company
DECLARE @p money
SELECT @p = (SELECT MAX(e.pensja) FROM ETATY e WHERE id_firmy='EP')

-- Presenting the employee with the highest salary in 'EP' company
SELECT 
    LEFT(o.imie, 10) AS 'Imię',
    LEFT(o.nazwisko, 15) AS 'Nazwisko',
    e.pensja AS 'Pensja',
    LEFT(f.nazwa, 20) AS 'Nazwa Firmy'
FROM ETATY e 
JOIN OSOBY o ON o.id_osoby = e.id_osoby 
JOIN FIRMY f ON f.nazwa_skr = e.id_firmy
WHERE e.pensja = @p

-- The result shows the person with the highest salary in 'EP' company (ENEA Poznań)
/*
Wyniki:
Imię       Nazwisko        Pensja                Nazwa Firmy
---------- --------------- --------------------- --------------------
Piotr      Tętnica         30000.00              ENEA Poznań
(1 row(s) affected)
*/

-- Task Z2.2: Presenting position, personal, and company data with specific location conditions

-- Presenting details of positions and personal information of employees, considering companies and locations
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

-- The result presents the data of positions and personal information of employees meeting the location criteria

/*
Wyniki:
Pensja     Stanowisko      Imię            Nazwisko             Nazwa Firmy          Miasto Firmy              Miasto Osoby       Kod Woj. Firmy Kod Woj. Osoby
---------- --------------- --------------- -------------------- -------------------- ------------------------- ------------------ ------------- -------------
4000.00    sprzątaczka     Zofia           Krupa                Idea Bank            Warszawa                  Jarocin            MAZ           WLK
3200.00    sprzątaczka     Zofia           Krupa                Cyfrowy Polsat       Warszawa                  Jarocin            MAZ           WLK
(2 row(s) affected)
*/
