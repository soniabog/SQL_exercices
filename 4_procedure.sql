/*
Bazy Danych - Zarządzanie Zasobami Ludzkimi - część 4

Opis projektu:
Procedura "szukaj_fi" została zaprojektowana w celu elastycznego 
wyszukiwania firm w bazie danych na podstawie różnych kryteriów, 
takich jak skrócona nazwa firmy, pełna nazwa oraz miasto, w którym 
firma się znajduje. Umożliwia to szczegółowe filtrowanie danych 
i uzyskanie precyzyjnych informacji związanych z firmami i ich 
lokalizacją. 

Autor: Sonia Bogdańska

*/

-- Deklaracja procedury "szukaj_fi"

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