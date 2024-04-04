/*
Bazy Danych - Zarządzanie Zasobami Ludzkimi - część 1

Opis projektu:
Celem części 1 jest zaprezentowanie struktury danych umożliwiającej efektywne zarządzanie informacjami o pracownikach, ich etatach oraz firmach, 
w których są zatrudnieni, z uwzględnieniem lokalizacji geograficznej.

Autor: Sonia Bogdańska
*/

-- Usuwanie istniejących tabel (jeżeli istnieją)
IF OBJECT_ID('ETATY') IS NOT NULL DROP TABLE ETATY;
IF OBJECT_ID('FIRMY') IS NOT NULL DROP TABLE FIRMY;
IF OBJECT_ID('OSOBY') IS NOT NULL DROP TABLE OSOBY;
IF OBJECT_ID('MIASTA') IS NOT NULL DROP TABLE MIASTA;
IF OBJECT_ID('WOJ') IS NOT NULL DROP TABLE WOJ;
GO

-- Tworzenie struktury bazy danych

-- Tworzenie tabel WOJ (województwa)
CREATE TABLE dbo.WOJ (
    kod_woj     nchar(4)        NOT NULL CONSTRAINT PK_WOJ PRIMARY KEY,
    nazwa       nvarchar(40)    NOT NULL
);
GO

-- Tworzenie tabel MIASTA
CREATE TABLE dbo.MIASTA (
    kod_woj     nchar(4)        NOT NULL,
    nazwa       nvarchar(40)    NOT NULL,
    id_miasta   int             NOT NULL IDENTITY CONSTRAINT PK_MIASTA PRIMARY KEY,
    CONSTRAINT FK_WOJ FOREIGN KEY (kod_woj) REFERENCES WOJ(kod_woj)
);
GO

-- Tworzenie tabel OSOBY
CREATE TABLE dbo.OSOBY (
    id_miasta   INT             NOT NULL,
    imie        nvarchar(40)    NOT NULL,
    nazwisko    nvarchar(40)    NOT NULL,
    adres       nvarchar(100)   NOT NULL,
    id_osoby    int             NOT NULL IDENTITY CONSTRAINT PK_OSOBY PRIMARY KEY
);
GO

-- Tworzenie tabel FIRMY
CREATE TABLE dbo.FIRMY (
    nazwa_skr   nchar(5)        NOT NULL CONSTRAINT PK_FIRMY PRIMARY KEY,
    id_miasta   INT             NOT NULL,
    nazwa       nvarchar(60)    NOT NULL,
    kod_pocztowy nchar(6)       NOT NULL,
    ulica       nvarchar(40)    NOT NULL
);
GO

-- Tworzenie tabel ETATY (etat)
CREATE TABLE dbo.ETATY (
    id_osoby    int             NOT NULL,
    id_firmy    nchar(5)        NOT NULL,
    stanowisko  nvarchar(40)    NOT NULL,
    pensja      MONEY           NOT NULL,
    od          DATETIME        NOT NULL,
    do          DATETIME        NULL,
    id_etatu    INT             NOT NULL IDENTITY CONSTRAINT PK_ETATY PRIMARY KEY
);
GO

-- Wstawianie danych do tabel

-- Wstawianie danych do tabeli WOJ (województwa)
INSERT INTO WOJ (kod_woj, nazwa) VALUES 
    ('MAZ', 'Mazowieckie'),
    ('WLK', 'Wielkopolskie'),
    ('POM', 'Pomorskie');
GO

-- Deklaracja zmiennych do przechowywania ID dla łatwiejszego zarządzania referencjami między tabelami
DECLARE @id_wes int
	,	@id_wwa int
	,	@id_rdm int
	,	@id_pzn int
	,	@id_kls int
	,	@id_jar int
	,	@id_lsz int
	,	@id_gzn int
	,	@id_ms	int 
	,	@id_jk	int
	,	@id_an	int
	,	@id_ak	int
	,	@id_ef	int
	,	@id_pt	int
	,	@id_br	int
	,	@id_sa	int
	,	@id_ja	int
	,	@id_zk	int
	,	@id_tb	int
;

-- Wprowadzanie danych do tabeli MIASTA
-- Dla każdego miasta podajemy przynależność do województwa (kod_woj) oraz jego nazwę. 
-- Wykorzystanie SCOPE_IDENTITY() pozwala na zapisanie ID nowo dodanego miasta do zmiennej,
-- co ułatwia późniejsze tworzenie relacji z innymi encjami, takimi jak osoby czy firmy.
INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('MAZ', 'Wesoła');
SET @id_wes = SCOPE_IDENTITY();

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('MAZ', 'Warszawa');
SET @id_wwa = SCOPE_IDENTITY();

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('MAZ', 'Radom');
SET @id_rdm = SCOPE_IDENTITY();

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('WLK', 'Poznań');
SET @id_pzn = SCOPE_IDENTITY();

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('WLK', 'Kalisz');
SET @id_kls = SCOPE_IDENTITY();

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('WLK', 'Jarocin');
SET @id_jar = SCOPE_IDENTITY();

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('WLK', 'Leszno');
SET @id_lsz = SCOPE_IDENTITY();

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('WLK', 'Gniezno');
SET @id_gzn = SCOPE_IDENTITY();

-- Wprowadzanie danych do tabeli OSOBY
-- Dla każdej osoby podajemy imię, nazwisko, ID miasta (za pomocą wcześniej zdefiniowanych zmiennych) oraz adres. 
-- Następnie, za pomocą SCOPE_IDENTITY(), przechowujemy ID nowo utworzonej osoby dla ewentualnego wykorzystania w przyszłości (np. przy przypisywaniu etatów).
INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Adam', 'Nowak', @id_wes, 'Mostowa 5');
SET @id_an = SCOPE_IDENTITY();

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Anna', 'Kowalska', @id_wes, 'Solna 33b');
SET @id_ak = SCOPE_IDENTITY();

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Elsa', 'Frołzen', @id_jar, 'Lodowa 444');
SET @id_ef = SCOPE_IDENTITY();

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Piotr', 'Tętnica', @id_jar, 'Stok');
SET @id_pt = SCOPE_IDENTITY();

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Bogdan', 'Ras', @id_wes, 'Hoża 22');
SET @id_br = SCOPE_IDENTITY();

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Szymon', 'Abramczyk', @id_wes, 'Długa 12h');
SET @id_sa = SCOPE_IDENTITY();

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Jan', 'Alucz', @id_jar, 'Domek 22');
SET @id_ja = SCOPE_IDENTITY();

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Zofia', 'Krupa', @id_jar, 'Blokowa 13');
SET @id_zk = SCOPE_IDENTITY();

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Tomasz', 'Buk', @id_wes, 'Maczka 3');
SET @id_tb = SCOPE_IDENTITY();

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Denis', 'Wolski', @id_wes, 'Krótka 2');

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Stanisław', 'Wokulski', @id_jar, 'Dobra 1');

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Izabela', 'Łęcka', @id_jar, 'Dobra 33');


-- Wprowadzanie danych do tabeli FIRMY
-- Każdy rekord zawiera skróconą nazwę firmy (klucz główny), ID miasta (powiązane z tabelą MIASTA),
-- pełną nazwę firmy, kod pocztowy oraz ulicę siedziby firmy.

INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) 
VALUES 
    ('CP', @id_wwa, 'Cyfrowy Polsat', '00-132', 'Cyfrowa'),
    ('IB', @id_wwa, 'Idea Bank', '00-999', 'Bankowa'),
    ('EP', @id_pzn, 'ENEA Poznań', '78-222', 'Prądowa'),
    ('VP', @id_pzn, 'Volskwagen', '62-455', 'Samochodowa'),
    ('KP', @id_pzn, 'Kompania Piwowarska', '66-325', 'Piwna');

-- Test integralności kluczy obcych
-- Próba dodania firmy do nieistniejącego miasta (zakomentowane, by uniknąć błędów)
--INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES ('BP', @id_niema, 'BP', '00-000', 'Nieistniejąca');
/*
Msg 137, Level 15, State 2, Line 108
Must declare the scalar variable "@id_niema".
*/

-- Wprowadzanie danych do tabeli ETATY
-- Każdy rekord reprezentuje etat przypisany osobie (id_osoby) w konkretnej firmie (id_firmy).
-- Zawiera informacje o stanowisku, pensji, dacie rozpoczęcia pracy (od) oraz opcjonalnie dacie zakończenia (do).

INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES 
    (@id_an, 'CP', 'grafik', 8000, CONVERT(datetime,'20000101',112), CONVERT(datetime,'20030101',112)),
    (@id_an, 'CP', 'obsługa klienta', 4700, CONVERT(datetime,'20040401',112), CONVERT(datetime,'20100201',112)),
    (@id_an, 'IB', 'obsługa klienta', 3400, CONVERT(datetime,'20100501',112), CONVERT(datetime,'20110101',112)),
    (@id_ak, 'VP', 'mechanik', 20000, CONVERT(datetime,'20130101',112), NULL),
    (@id_ak, 'EP', 'obsługa techniczna', 10000, CONVERT(datetime,'20170201',112), NULL),
    (@id_ef, 'KP', 'prezes', 40000, CONVERT(datetime,'20030101',112), CONVERT(datetime,'20050501',112)),
	(@id_pt, 'EP', 'księgowy', 11000, CONVERT(datetime,'20070101',112)),
	(@id_pt, 'EP', 'wiceprezes', 30000, CONVERT(datetime,'20180601',112)),
	(@id_br, 'IB', 'manager marketingu', 125000, CONVERT(datetime,'20090901',112), CONVERT(datetime,'20180101',112)),
	(@id_br, 'CP', 'prezenter', 16000, CONVERT(datetime,'20070301',112)),
	(@id_sa, 'KP', 'kontroler jakości', 6000, CONVERT(datetime,'20150201',112)),
	(@id_ja, 'KP', 'smakosz', 500, CONVERT(datetime,'19900201',112)),
	(@id_ja, 'VP', 'specjalista public relations', 7500, CONVERT(datetime,'20000801',112))
	(@id_zk, 'IB', 'sprzątaczka', 4000, CONVERT(datetime,'19990101',112)),
	(@id_zk, 'CP', 'sprzątaczka', 3200, CONVERT(datetime,'20090301',112)),
    (@id_tb, 'EP', 'dyrektor finansowy', 9800, CONVERT(datetime,'20100701',112), NULL);

SELECT * FROM WOJ
/*kod_woj nazwa
------- ----------------------------------------
MAZ     Mazowieckie
POM     Pomorskie
WLK     Wielkopolskie

(3 row(s) affected)
*/
SELECT * FROM MIASTA
/*kod_woj nazwa                                    id_miasta
------- ---------------------------------------- -----------
MAZ     Wesoła                                   1
MAZ     Warszawa                                 2
MAZ     Radom                                    3
WLK     Poznań                                   4
WLK     Kalisz                                   5
WLK     Jarocin                                  6
WLK     Leszno                                   7
WLK     Gniezno                                  8

(8 row(s) affected)
*/
SELECT * FROM OSOBY
/*id_miasta   imie                                     nazwisko                                 adres                                                                                                id_osoby
----------- ---------------------------------------- ---------------------------------------- ---------------------------------------------------------------------------------------------------- -----------
1           Adam                                     Nowak                                    Mostowa 5                                                                                            1
1           Anna                                     Kowalska                                 Solna 33b                                                                                            2
6           Elsa                                     Frołzen                                  Lodowa 444                                                                                           3
6           Piotr                                    Tętnica                                  Stok                                                                                                 4
1           Bogdan                                   Ras                                      Hoża 22                                                                                              5
1           Szymon                                   Abramczyk                                Długa 12h                                                                                            6
6           Jan                                      Alucz                                    Domek 22                                                                                             7
6           Zofia                                    Krupa                                    Blokowa 13                                                                                           8
1           Tomasz                                   Buk                                      Maczka 3                                                                                             9
1           Denis                                    Wolski                                   Krótka 2                                                                                             10
6           Stanisław                                Wokulski                                 Dobra 1                                                                                              11
6           Izabela                                  Łęcka                                    Dobra 33                                                                                             12

(12 row(s) affected)
*/

/* to samo dodać odnośnie FIRMY i ETATY */
SELECT * FROM FIRMY
/*nazwa_skr id_miasta   nazwa                                                        kod_pocztowy ulica
--------- ----------- ------------------------------------------------------------ ------------ ----------------------------------------
CP        2           Cyfrowy Polsat                                               00-132       Cyfrowa
EP        4           ENEA Poznań                                                  78-222       Prądowa
IB        2           Idea Bank                                                    00-999       Bankowa
KP        4           Kompania Piwowarska                                          66-325       Piwna
VP        4           Volskwagen                                                   62-455       Samochodowa

(5 row(s) affected)
*/

SELECT * FROM ETATY
/*id_osoby    id_firmy stanowisko                               pensja                od                      do                      id_etatu
----------- -------- ---------------------------------------- --------------------- ----------------------- ----------------------- -----------
3           CP       grafik                                   8000,00               2000-01-01 00:00:00.000 2003-01-01 00:00:00.000 1
3           CP       obsługa klienta                          4700,00               2004-04-01 00:00:00.000 2010-02-01 00:00:00.000 2
3           IB       obsługa klienta                          3400,00               2010-05-01 00:00:00.000 2011-01-01 00:00:00.000 3
4           VP       mechanik                                 20000,00              2013-01-01 00:00:00.000 NULL                    4
4           EP       obsługa techniczna                       10000,00              2017-02-01 00:00:00.000 NULL                    5
5           KP       prezes                                   40000,00              2003-01-01 00:00:00.000 2005-05-01 00:00:00.000 6
6           EP       księgowy                                 11000,00              2007-01-01 00:00:00.000 NULL                    7
6           EP       wiceprezes                               30000,00              2018-06-01 00:00:00.000 NULL                    8
7           IB       manager marketingu                       125000,00             2009-09-01 00:00:00.000 2018-01-01 00:00:00.000 9
7           CP       prezenter                                16000,00              2007-03-01 00:00:00.000 NULL                    10
8           KP       kontroler jakości                        6000,00               2015-02-01 00:00:00.000 NULL                    11
9           KP       smakosz                                  500,00                1990-02-01 00:00:00.000 NULL                    12
9           VP       specjalista public relations             7500,00               2000-08-01 00:00:00.000 NULL                    13
10          IB       sprzątaczka                              4000,00               1999-01-01 00:00:00.000 NULL                    14
10          CP       sprzątaczka                              3200,00               2009-03-01 00:00:00.000 NULL                    15
11          EP       dyrektor finansowy                       9800,00               2010-07-01 00:00:00.000 NULL                    16

(16 row(s) affected)
*/