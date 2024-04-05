/*
Database Management - Human Resources Management - Part 4

Project Description:
The procedure "szukaj_fi" was designed to flexibly 
search for companies in the database based on various criteria, 
such as the company's abbreviated name, full name, and the city 
in which the company is located. This allows for detailed filtering of data 
and obtaining precise information related to companies and their 
location. 

Author: Sonia Bogdańska
*/

-- Declaration of the "szukaj_fi" procedure

CREATE PROCEDURE dbo.szukaj_fi
( 
	@nazwa_skr nvarchar(40) = NULL,
	@nazwa_pelna nvarchar(40) = NULL,
	@miasto_nazwa nvarchar(40) = NULL
)
AS
	DECLARE @zapytanie nvarchar(3000), @where nvarchar(200)
	SET @zapytanie = 'SELECT f.*, m.nazwa AS [miasto], w.nazwa AS [województwo] FROM firmy f JOIN miasta m ON f.id_miasta = m.id_miasta JOIN woj w ON m.kod_woj = w.kod_woj'
	EXEC dbo.add_cond @where = @where output, @col = N'f.nazwa_skr', @val = @nazwa_skr
	EXEC dbo.add_cond @where = @where output, @col = N'f.nazwa', @val = @nazwa_pelna
	EXEC dbo.add_cond @where = @where output, @col = N'm.nazwa', @val = @miasto_nazwa
	SET @zapytanie = @zapytanie + @where
	select @zapytanie
	EXEC sp_sqlexec @zapytanie
GO

EXEC szukaj_fi @nazwa_skr = N'CP'
/*

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT f.*, m.nazwa AS [miasto], w.nazwa AS [wojewodztwo] FROM firmy f JOIN miasta m ON (f.id_miasta = m.id_miasta) JOIN woj w ON (m.kod_woj=w.kod_woj) WHERE (f.nazwa_skr = 'CP') 

(1 row(s) affected)

nazwa_skr id_miasta   nazwa                                                        kod_pocztowy ulica                                    miasto                                   wojewodztwo
--------- ----------- ------------------------------------------------------------ ------------ ---------------------------------------- ---------------------------------------- ----------------------------------------
CP        2           Cyfrowy Polsat                                               00-132       Cyfrowa                                  Warszawa                                 Mazowieckie

(1 row(s) affected)
*/

EXEC szukaj_fi @nazwa_skr= N'KP', @miasto_nazwa= N'Pozna�'
/*

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT f.*, m.nazwa AS [miasto], w.nazwa AS [wojewodztwo] FROM firmy f JOIN miasta m ON (f.id_miasta = m.id_miasta) JOIN woj w ON (m.kod_woj=w.kod_woj) WHERE (f.nazwa_skr = 'KP')  AND (m.nazwa = 'Poznań') 

(1 row(s) affected)

nazwa_skr id_miasta   nazwa                                                        kod_pocztowy ulica                                    miasto                                   wojewodztwo
--------- ----------- ------------------------------------------------------------ ------------ ---------------------------------------- ---------------------------------------- ----------------------------------------
KP        4           Kompania Piwowarska                                          66-325       Piwna                                    Poznań                                   Wielkopolskie

(1 row(s) affected)
*/

EXEC szukaj_fi @nazwa_skr= N'KP', @miasto_nazwa= N'Jarocin'
/*

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT f.*, m.nazwa AS [miasto], w.nazwa AS [wojewodztwo] FROM firmy f JOIN miasta m ON (f.id_miasta = m.id_miasta) JOIN woj w ON (m.kod_woj=w.kod_woj) WHERE (f.nazwa_skr = 'KP')  AND (m.nazwa = 'Jarocin') 

(1 row(s) affected)

nazwa_skr id_miasta   nazwa                                                        kod_pocztowy ulica                                    miasto                                   wojewodztwo
--------- ----------- ------------------------------------------------------------ ------------ ---------------------------------------- ---------------------------------------- ----------------------------------------

(0 row(s) affected)
*/