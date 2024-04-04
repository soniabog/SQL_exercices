/*
Bazy Danych - Wypożyczalnia Aut

Opis projektu:
Część ta koncentruje się na implementacji i zarządzaniu tabelami oraz triggerami 
związanymi z wypożyczalnią aut. Zadanie polega na stworzeniu struktury danych dla 
aut, klientów, wypożyczeń oraz zwrotów, a następnie na zarządzaniu zmianami w dostępności 
pojazdów za pomocą triggerów, które reagują na operacje INSERT, UPDATE oraz DELETE.

Autor: Sonia Bogdańska
*/

-- Usuwanie istniejących tabel (jeżeli istnieją)
IF OBJECT_ID('dbo.AUTA') IS NOT NULL 
	DROP TABLE AUTA
IF OBJECT_ID('dbo.ZWROT') IS NOT NULL
	DROP TABLE ZWROT
IF OBJECT_ID('dbo.WYPOZYCZ') IS NOT NULL
	DROP TABLE WYPOZYCZ
IF OBJECT_ID('dbo.KLIENT') IS NOT NULL
	DROP TABLE KLIENT

-- Tworzenie tabel AUTA, KLIENT, WYPORZYCZ, ZWROT

CREATE TABLE dbo.AUTA (
  id_a INT NOT NULL IDENTITY (1,1) PRIMARY KEY,
  model NVARCHAR(60),
  liczba_dostepnych INT NOT NULL,
  liczba_zakupionych INT NOT NULL
)
GO

CREATE TABLE dbo.KLIENT (
	nazwa nvarchar(100) not null,
	adres nvarchar(100) not null,
	id_klienta int not null identity CONSTRAINT PK_ID_KLIENTA PRIMARY KEY
)
GO

CREATE TABLE dbo.WYPOZYCZ (
	id_wyp int not null identity CONSTRAINT PK_ID_WYP PRIMARY KEY,
	id_klienta int CONSTRAINT FK_WYPOZYCZ_KLIENT FOREIGN KEY REFERENCES KLIENT(id_klienta),
	id_a int CONSTRAINT FK_WYPOZYCZ_AUTA FOREIGN KEY REFERENCES AUTA(id_a),
	liczba int not null
)
GO

CREATE TABLE dbo.zwrot
(	id_zwr int not null identity CONSTRAINT PK_ID_ZWR PRIMARY KEY,
	id_klienta int CONSTRAINT FK_ZWROT_KLIENT FOREIGN KEY REFERENCES KLIENT(id_klienta),
	id_a int CONSTRAINT FK_ZWROT_AUTA FOREIGN KEY REFERENCES AUTA(id_a),
	liczba int not null
)
GO

-- Tworzenie triggerów

-- Trigger na insert do AUTA (przypisanie liczby zakupionych aut do liczby dostępnych)
CREATE TRIGGER dbo.AUTA_INSRT_ZAKUP ON dbo.AUTA FOR INSERT
AS
	UPDATE AUTA
	SET
		liczba_dostepnych = AUTA.liczba_zakupionych
	FROM AUTA 
		JOIN inserted i ON AUTA.id_a = i.id_a
GO

-- Trigger na update dla AUTA (aktualizacja liczby dostępnych aut)
CREATE TRIGGER dbo.AUTA_UPD_ZAKUP ON dbo.AUTA FOR UPDATE
AS
	IF UPDATE(liczba_zakupionych) 
		UPDATE AUTA
		SET 
			liczba_dostepnych += i.liczba_zakupionych-d.liczba_zakupionych
		FROM AUTA a
			JOIN inserted i ON a.id_a=i.id_a
			JOIN deleted d ON a.id_a=d.id_a
GO

-- Trigger do kontroli poprawności aktualizacji liczby dostępnych aut w tabeli AUTA
-- Zapobiega sytuacjom, w których liczba dostępnych aut przekracza liczbę zakupionych lub jest mniejsza od zera
CREATE TRIGGER dbo.AUTA_update_dost ON dbo.AUTA FOR UPDATE
AS
	IF UPDATE(liczba_dostepnych)
		IF EXISTS (SELECT TOP(1) 1 FROM inserted i WHERE i.liczba_dostepnych>i.liczba_zakupionych OR i.liczba_dostepnych<0)
		BEGIN
			RAISERROR(N'Niepoprawna liczba dostępnych aut', 16, 3)
			ROLLBACK TRAN
		END
GO

-- Trigger na operacje INSERT, UPDATE, DELETE w tabeli WYPOZYCZ
-- Automatycznie aktualizuje liczbę dostępnych aut w tabeli AUTA na podstawie wypożyczeń i zwrotów
CREATE TRIGGER dbo.WYPOZYCZ_ALL ON WYPOZYCZ
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Zmniejszenie liczby dostępnych aut przy wypożyczeniu
    UPDATE auta
    SET liczba_dostepnych = liczba_dostepnych - X.suma
    FROM auta a
    JOIN (
        SELECT id_a, SUM(liczba) as [suma]
        FROM inserted
        GROUP BY id_a
    ) X ON X.id_a = a.id_a;

	-- Zwiększenie liczby dostępnych aut przy usunięciu wypożyczenia
    UPDATE auta
    SET liczba_dostepnych = liczba_dostepnych + X.suma
    FROM auta a
    JOIN (
        SELECT id_a, SUM(liczba) as [suma]
        FROM deleted
        GROUP BY id_a
    ) X ON X.id_a = a.id_a;
END;
GO

-- Trigger na operacje INSERT, UPDATE, DELETE w tabeli ZWROT
-- Aktualizuje liczbę dostępnych aut w AUTA, odzwierciedlając zwroty wypożyczonych aut
CREATE TRIGGER dbo.ZWROT_ALL ON ZWROT
CREATE TRIGGER dbo.ZWROT_ALL ON ZWROT
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Zwiększenie liczby dostępnych aut przy zwrocie
    UPDATE auta
    SET liczba_dostepnych = liczba_dostepnych + X.suma
    FROM auta a
    JOIN (
        SELECT id_a, SUM(liczba) as [suma]
        FROM inserted
        GROUP BY id_a
    ) X ON X.id_a = a.id_a;

    -- Zmniejszenie liczby dostępnych aut przy usunięciu zwrotu
    UPDATE auta
    SET liczba_dostepnych = liczba_dostepnych - X.suma
    FROM auta a
    JOIN (
        SELECT id_a, SUM(liczba) as [suma]
        FROM deleted
        GROUP BY id_a
    ) X ON X.id_a = a.id_a;
END;
GO

-- Zaktualizowany trigger na INSERT dla AUTA
-- Przypisuje liczbę zakupionych aut do liczby dostępnych aut przy każdym dodaniu nowego auta
ALTER TRIGGER dbo.AUTA_INSRT_ZAKUP ON dbo.AUTA FOR INSERT
AS
	UPDATE AUTA
	SET
		liczba_dostepnych = i.liczba_zakupionych
	FROM AUTA a
		JOIN inserted i ON (a.id_a = i.id_a)
GO

-- Zaktualizowany trigger na UPDATE dla AUTA
-- Aktualizuje liczbę dostępnych aut tylko w przypadku zmiany liczby zakupionych aut
ALTER TRIGGER dbo.AUTA_UPD_ZAKUP ON dbo.AUTA FOR UPDATE
AS
	IF UPDATE(liczba_zakupionych) 
		UPDATE AUTA
		SET 
			liczba_dostepnych = d.liczba_zakupionych+i.liczba_zakupionych-d.liczba_zakupionych
		FROM AUTA a
			JOIN inserted i ON a.id_a=i.id_a
			JOIN deleted d ON i.id_a=d.id_a
			WHERE NOT (i.liczba_zakupionych=d.liczba_zakupionych)
GO

-- Aktualizuje trigger na aktualizację tabeli AUTA, monitorujący pole liczba_dostepnych
ALTER TRIGGER dbo.AUTA_update_dost ON dbo.AUTA FOR UPDATE
AS
	IF UPDATE(liczba_dostepnych)
		IF EXISTS (SELECT 1 FROM AUTA a WHERE a.liczba_dostepnych<0 OR a.liczba_dostepnych> a.liczba_zakupionych)
		BEGIN
			RAISERROR(N'Niepoprawna liczba dostępnych aut', 16, 3)
			ROLLBACK TRAN
		END
GO


-- Wstawianie danych testowych i demonstracja działania triggerów

INSERT INTO dbo.AUTA (model, liczba_dostepnych, liczba_zakupionych)
VALUES ('Toyota Camry', 5, 7)

INSERT INTO dbo.AUTA (model, liczba_dostepnych, liczba_zakupionych)
VALUES ('Honda Civic', 3, 4)

INSERT INTO dbo.AUTA (model, liczba_dostepnych, liczba_zakupionych)
VALUES ('Ford Mustang', 8, 10)

GO



SELECT * FROM AUTA
/*
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 5                 7
8           Honda Civic                                                  3                 4
9           Ford Mustang                                                 8                 10

(3 rows affected)
*/

UPDATE AUTA SET  liczba_zakupionych = 11
SELECT * FROM AUTA

/*id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 11                11
8           Honda Civic                                                  11                11
9           Ford Mustang                                                 11                11

(3 rows affected)
*/

UPDATE AUTA SET liczba_zakupionych=8
SELECT * FROM AUTA

/*
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 8                 8
8           Honda Civic                                                  8                 8
9           Ford Mustang                                                 8                 8

(3 rows affected)
*/

INSERT INTO klient (nazwa, adres) VALUES ('pan', 'kwiatowa 1')
INSERT INTO klient (nazwa, adres) VALUES ('pani', 'zielona 12')

INSERT INTO wypozycz(id_a, id_klienta, liczba) VALUES (7,1,2), (8,2,3)

SELECT * FROM AUTA

/*(2 rows affected)
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 6                 8
8           Honda Civic                                                  5                 8
9           Ford Mustang                                                 8                 8

(3 rows affected)
*/

DELETE FROM wypozycz WHERE id_klienta=2
SELECT * FROM AUTA

/*(1 row affected)
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 6                 8
8           Honda Civic                                                  8                 8
9           Ford Mustang                                                 8                 8
*/

/*więcej aut dostępnych niż kupionych*/
INSERT INTO zwrot(id_a, id_klienta, liczba) VALUES (7,1,2), (7,2,3)
SELECT * FROM AUTA
/* Msg 50000, Level 16, State 3, Procedure AUTA_update_dost, Line 6 [Batch Start Line 309]
Niepoprawna liczba dostępnych aut
Msg 3609, Level 16, State 1, Procedure ZWROT_ALL, Line 6 [Batch Start Line 309]
The transaction ended in the trigger. The batch has been aborted.
*/

/*ujemna liczba aut dostępnych*/
INSERT INTO wypozycz(id_a, id_klienta, liczba) VALUES (8,1,9), (8,2,4)
SELECT * FROM AUTA

/*
Msg 50000, Level 16, State 3, Procedure AUTA_update_dost, Line 6 [Batch Start Line 318]
Niepoprawna liczba dostępnych aut
Msg 3609, Level 16, State 1, Procedure WYPOZYCZ_ALL, Line 6 [Batch Start Line 318]
The transaction ended in the trigger. The batch has been aborted.
*/

DELETE FROM zwrot WHERE id_klienta=2
SELECT * FROM AUTA
/*
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 6                 8
8           Honda Civic                                                  2                 8
9           Ford Mustang                                                 8                 8

(3 rows affected)
*/

INSERT INTO wypozycz(id_a, id_klienta, liczba) VALUES (7,1,2), (7,2,3)
SELECT * FROM AUTA
INSERT INTO zwrot(id_a, id_klienta, liczba) VALUES (7,1,2), (7,2,3)
SELECT * FROM AUTA
/*
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 1                 8
8           Honda Civic                                                  2                 8
9           Ford Mustang                                                 8                 8

(3 rows affected)

(1 row affected)

(0 rows affected)

(2 rows affected)

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 6                 8
8           Honda Civic                                                  2                 8
9           Ford Mustang                                                 8                 8

(3 rows affected)
*/

SELECT * FROM wypozycz
SELECT * FROM auta
DELETE FROM wypozycz WHERE id_wyp = 1 OR id_wyp = 5
SELECT * FROM wypozycz
SELECT * FROM auta

/*
id_wyp      id_klienta  id_a        liczba
----------- ----------- ----------- -----------
1           1           7           2
3           1           8           2
4           2           8           4
7           1           7           2
8           2           7           3

(5 rows affected)

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 6                 8
8           Honda Civic                                                  2                 8
9           Ford Mustang                                                 8                 8

(3 rows affected)

(0 rows affected)

(1 row affected)

(1 row affected)

id_wyp      id_klienta  id_a        liczba
----------- ----------- ----------- -----------
3           1           8           2
4           2           8           4
7           1           7           2
8           2           7           3

(4 rows affected)

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 8                 8
8           Honda Civic                                                  2                 8
9           Ford Mustang                                                 8                 8

(3 rows affected)
*/

SELECT * FROM ZWROT
SELECT * FROM AUTA
DELETE FROM zwrot WHERE id_klienta = 1 OR id_klienta = 2
SELECT * FROM ZWROT
SELECT * FROM AUTA

/*
id_zwr      id_klienta  id_a        liczba
----------- ----------- ----------- -----------
3           1           7           2
4           2           7           3

(2 rows affected)

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 8                 8
8           Honda Civic                                                  2                 8
9           Ford Mustang                                                 8                 8

(3 rows affected)

(0 rows affected)

(1 row affected)

(2 rows affected)

id_zwr      id_klienta  id_a        liczba
----------- ----------- ----------- -----------

(0 rows affected)

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 3                 8
8           Honda Civic                                                  2                 8
9           Ford Mustang                                                 8                 8

(3 rows affected)
*/

INSERT INTO wypozycz(id_a, id_klienta, liczba) VALUES (7,1,2), (9,2,4)
INSERT INTO zwrot(id_a, id_klienta, liczba) VALUES (7,1,2), (9,2,3)
SELECT * FROM auta
UPDATE auta SET liczba_zakupionych=15 WHERE id_a = 7 OR id_a=9
SELECT * FROM AUTA

/*id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 3                 8
8           Honda Civic                                                  2                 8
9           Ford Mustang                                                 7                 8

(3 rows affected)

(2 rows affected)

(2 rows affected)

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
7           Toyota Camry                                                 15                15
8           Honda Civic                                                  2                 8
9           Ford Mustang                                                 15                15

(3 rows affected)
*/