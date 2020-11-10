-- Kodune töö YL7
-- Raivo Kasepuu
-- Matrikkel B710710

/*
1. Luua tabel Asulad (id integer, nimi varchar(100))
ID on primaarvõti, automaatselt tuleneva väärtusega
Nimi on unikaalne
Mõlemad väljad on kohustuslikud.
OK!
*/
CREATE TABLE Asula (
id INTEGER NOT NULL DEFAULT AUTOINCREMENT PRIMARY KEY,
nimi VARCHAR(100) NOT NULL,
UNIQUE (nimi)
);

/*
2. Lisada uude tabelisse kõik asukohad tabelist Klubid ja toimumiskohad tabelist
Turniirid.
OK!
*/
INSERT INTO Asula (nimi)
SELECT DISTINCT asukoht FROM Klubid
UNION 
SELECT DISTINCT Toimumiskoht FROM Turniirid;

/*
3. Lisada tabelisse Klubid veerg Asula (integer).
OK!
*/
ALTER TABLE Klubid ADD Asula INTEGER;

/*
4. Väärtustada korraga kõigil Klubi kirjetel veerg Asula sobiliku ID’ga tabelist Asulad:
update klubid set asula = (select id from asulad where asulad.nimi = klubid.asukoht).
OK!
*/
UPDATE Klubid SET Asula = (SELECT id FROM Asula WHERE Asula.nimi = Klubid.asukoht);

/*
5. Lisada tabelile Klubid välisvõti tabelisse Asulad (fk_klubi_2_asula).
Kontrollida andmeid (võrrelda tekstiveerge):
select klubid.asukoht, asulad.nimi from klubid join asulad on klubid.asula = asulad.id.
OK!*/

ALTER TABLE Klubid ADD CONSTRAINT fk_klubid_2_asula
FOREIGN KEY (Asula)
REFERENCES Asula(id)
ON DELETE CASCADE ON UPDATE CASCADE;

-- Kontrollime:
SELECT Klubid.asukoht, Asula.nimi from Klubid JOIN Asula ON Klubid.Asula = Asula.id;

/*
6. Lisada tabelisse Turniirid veerg Asula (integer).
OK!
*/
ALTER TABLE Turniirid ADD Asula INTEGER;

/*
7. Väärtustada korraga kõigil Turniiri kirjetel veerg Asula sobiliku ID’ga tabelist Asulad.
OK!
*/

UPDATE Turniirid SET Asula = (SELECT id FROM Asula WHERE Asula.nimi = Turniirid.Toimumiskoht);

/*
8. Lisada tabelile Turniirid välisvõti tabelisse Asulad (fk_turniir_2_asula)
Kontrollida andmeid (võrrelda tekstiveerge).
OK!
*/

ALTER TABLE Turniirid ADD CONSTRAINT fk_turniirid_2_asula
FOREIGN KEY (Asula)
REFERENCES Asula(id)
ON DELETE CASCADE ON UPDATE CASCADE;

-- Kontrollime:
SELECT Turniirid.toimumiskoht, Asula.nimi from Turniirid JOIN Asula ON Turniirid.Asula = Asula.id;

/*
9. Luua vaade v_asulaklubisid (asula_id, asula_nimi, klubisid), mis annaks asulate
klubide arvud e kui palju on igal asulal klubisid.
OK!
*/

CREATE VIEW v_asulaklubisid (asula_id, asula_nimi, klubisid) AS
SELECT Asula, asukoht, COUNT(*)
FROM Klubid
GROUP BY asula, asukoht;

/*
10. Luua vaade v_asulasuurus (asula_id, asula_nimi, mangijaid), mis annaks
asulate mängijate arvud e kui palju on igal asulal mängijaid.
Kontrollküsimus: kas võib tekkida kirje, kus mangijaid = 0?
*/
CREATE VIEW v_asulasuurus (asula_id, asula_nimi, mangijaid) AS
SELECT Klubid.Asula, Klubid.asukoht, COUNT(*) 
FROM isikud JOIN Klubid ON isikud.klubi = Klubid.id
GROUP BY Klubid.Asula, Klubid.asukoht;

-- Kontrollküsimus: kas võib tekkida kirje, kus mangijaid = 0? Vastus: Ei teki.

/*
11. Lisada lihtne protseduur klubi kustutamiseks sp_kustuta_klubi(klubinimi).
OK!
*/
CREATE PROCEDURE sp_kustuta_klubi(IN klubiNimi VARCHAR(100))
BEGIN
DELETE FROM Klubid
WHERE nimi = klubiNimi;  
END; 

CALL sp_kustuta_klubi('Kiire Aju');
/*
12. Luua triger, mis klubi lisamise järel lisaks asukoha tabelisse asulad, kui seda
seal pole, ning väärtustaks tabelis klubid asula välja vastava asula
ID’ga, tg_lisa_klubi.
OK!
*/
CREATE TRIGGER tg_lisa_klubi AFTER INSERT, UPDATE ON Klubid
REFERENCING NEW AS uusklubi
FOR EACH ROW
WHEN ((SELECT COUNT(*) FROM Asula WHERE Nimi = uusklubi.asukoht) = 0)
BEGIN 
DECLARE uusklubi_id INTEGER;
INSERT INTO Asula(nimi) VALUES (uusklubi.asukoht);
SELECT @@identity INTO uusklubi_id;
UPDATE Klubid SET Asula = uusklubi_id WHERE id = uusklubi.id;
END;

/*
13. Luua triger, mis klubi kustutamisel kontrollib, kas klubi asula on kuskil
kasutuses (teiste klubide juures või turniiride juures), ja kui pole, siis kustutab
ka asula maha. tg_kustuta_klubi.
OK!
*/
CREATE TRIGGER tg_kustuta_klubi AFTER DELETE ON Klubid
REFERENCING OLD AS vana
FOR EACH ROW
BEGIN
DECLARE klubiAsula INTEGER;
DECLARE turniiriAsula INTEGER;
SELECT COUNT(*) INTO klubiAsula FROM Klubid WHERE Asula = vana.Asula;
SELECT COUNT(*) INTO turniiriAsula FROM Turniirid WHERE Asula = vana.Asula;
IF (klubiAsula = 0 AND turniiriAsula = 0) THEN
DELETE FROM Asula WHERE id = vana.Asula;
END IF; 
END

/*
14. Lisada klubi “Kiire Aju” asukohaga Viljandi.
OK
*/
INSERT INTO Klubid(nimi, asukoht)
VALUES ('Kiire Aju', 'Viljandi');

/*
15. Lisada klubi “Kambja Kibe” asukohaga Kambja.
*/
INSERT INTO Klubid(nimi, asukoht)
VALUES ('Kambja Kibe', 'Kambja');

/*
16. Teha päring tabelisse asulad, et veenduda, mis asulad on olemas.
*/
SELECT DISTINCT nimi FROM Asula;

/*
17. Kustutada klubid maha:
call sp_kustuta_klubi(‘Kiire Aju’)
call sp_kustuta_klubi(‘Kambja Kibe’).
OK!
*/
CALL sp_kustuta_klubi('Kiire Aju');
CALL sp_kustuta_klubi('Kambja Kibe');

/*
18. Teha päring tabelisse asulad, et veenduda, mis asulad on olemas.
OK! 
*/
SELECT DISTINCT nimi FROM Asula;

/*
19. Lisada uus klubi “SQL klubi” asukohaga Tartu.
OK!
*/
INSERT INTO Klubid(nimi, asukoht)
VALUES ('SQL klubi', 'Tartu');

/*
20. Lisada tabelisse Isikud iseennast. Klubiks panna “SQL klubi”.
OK!*/
INSERT INTO Isikud (eesnimi, perenimi, isikukood, klubi)
VALUES ('Raivo', 'Kasepuu', '36906190336', (SELECT id FROM Klubid WHERE nimi = 'SQL klubi'));

/*
21. Proovida kustutada klubi sp_kustuta_klubi(‘SQL klubi’) - ei tohi õnnestuda
(miks?)
*/

CALL sp_kustuta_klubi('SQL klubi');
-- Isikud tabelis on välisvõti, mis viitab Klubid tabelile. Ei saa kustutada klubi, millel on liikmed. 
-- Enne klubi kustutamist tuleb kustutada kõik klubi liikmed. 

/*
22. Luua klubi kustutamisele triger (tg_kustuta_klubi_isikutega), mis kustutaks
maha klubi isikud. NB! Kui isikul on partiisid, siis isikut ei õnnestu kustutada ja
seega ei õnnestu ka klubi kustutada. Nii peabki olema!
call sp_kustuta_klubi(“Laudnikud”) - ei tohi midagi halba teha (kui kõik seosed on
varem õigesti loodud).
Aga call sp_kustuta_klubi(“SQL klubi”) peab kustutama nii klubi kui ka selle ühe
liikme.
OK!
*/

CREATE TRIGGER tg_kustuta_klubi_isikutega BEFORE DELETE ON Klubid
REFERENCING OLD AS vana 
FOR EACH ROW
BEGIN
DELETE FROM Isikud WHERE Klubi = vana.id;
END

/*
23. Kustutage kõik kirjed tabelist Inimesed ja lisada ennast tabelisse Inimesed.
OK!
*/
DELETE FROM Inimesed;
SELECT * FROM inimesed;
INSERT INTO inimesed (eesnimi, perenimi, sugu, synnipaev, isikukood)
VALUES ('Raivo', 'Kasepuu', 'M', '1969-06-19', '36906190336');

/*
24. Luua vaated ülesande 4 päringutele 1 kuni 12.
Vaate nimeks panna V_<päringu number>. Näiteks V_1, V_2, … , V_12.

-- YL4:
/*
1. Leida klubi ?Laudnikud? liikmete nimekiri (eesnimi, perenimi) t?hestiku j?rjekorras
(eesnimi, perenimi).
*/ 
CREATE VIEW V_1(eesnimi, perenimi) AS
SELECT eesnimi, perenimi FROM isikud JOIN klubid 
WHERE klubid.nimi = 'Laudnikud' 
ORDER BY eesnimi ASC, perenimi ASC;

/*
2. Leida klubi ?Laudnikud? liikmete arv.
*/
CREATE VIEW V_2(liikmete_arv) AS
SELECT COUNT(*) AS klubi_Laudnikud_liikmete_arv 
FROM isikud JOIN klubid WHERE klubid.nimi = 'Laudnikud';

/*
3. Leida V-t?hega algavate klubide M-t?hega algavate eesnimedega isikute perekonnanimed
(ja ei muud).
*/
CREATE VIEW V_3(perenimi) AS
SELECT perenimi AS V_tahega_algavate_klubide_M_tahega_algavate_eesnimedega_isikute_perekonnanimed 
FROM isikud JOIN klubid WHERE klubid.nimi like 'v%' AND isikud.eesnimi LIKE 'm%';

/*
4. Leida k?ige esimesena alanud partii algusaeg.
*/ 
CREATE VIEW V_4(algusaeg) AS 
SELECT TOP 1 algushetk 
AS koige_esimesena_alanud_partii_algusaeg 
FROM partiid ORDER BY algushetk;

/*
5. Leida partiide m?ngijad (viited m?ngijatele (v?ljad: valge ja must)), mis algasid 04.
m?rtsil 2005 aastal ajavahemikus 9:00 kuni 11:00.
*/
CREATE VIEW V_5(eesnimi, perenimi) AS
SELECT eesnimi, perenimi 
FROM isikud JOIN partiid 
ON isikud.id = partiid.valge OR isikud.id = partiid.must 
WHERE algushetk BETWEEN 
'2005-03-04 09:00:00.0' AND '2005-03-04 11:00:00.0';

/* Lühem alternatiiv  Jaana Liländer-Koppel
*/
SELECT Valge, Must FROM Partiid
WHERE Algushetk BETWEEN '2005-03-04 09:00'
AND '2005-03-04 11:00'
 
/*
6. Leida valgetega v?itnute (valge_tulemus=2) isikute nimed (eesnimi, perenimi), kus partii
kestis 9 kuni 11 minutit (vt funktsiooni Datediff(); Datediff(minute, <algus>, <l?pp>)).
*/
CREATE VIEW V_6(eesnimi, perenimi) AS
SELECT eesnimi, perenimi FROM isikud JOIN partiid 
ON isikud.id = partiid.valge WHERE valge_tulemus = 2 
AND DATEDIFF(minute, algushetk, lopphetk) BETWEEN 9 AND 11; 

/*
7. Leida tabelis Isikud rohkem kui 1 kord esinevad perekonnanimed (ja ei muud).
*/
CREATE VIEW V_7(perenimi) AS
SELECT perenimi FROM isikud 
GROUP BY perenimi HAVING COUNT(*) > 1;

/*
8. Leida klubid (nimi ja liikmete arv), kus on alla 4 liikme.
*/
CREATE VIEW V_8(Klubi_nimi, Liikmete_arv) AS
SELECT nimi AS Klubi_nimi, count(*) AS Liikmete_arv 
FROM isikud JOIN klubid ON isikud.klubi = klubid.id 
GROUP BY nimi HAVING Liikmete_arv < 4 ;

/*
9. Leida k?igi Arvode poolt kokku valgetega m?ngitud partiide arv.
*/
CREATE VIEW v_9(Arvo_valgetega_mangitud_partiide_arv) AS
SELECT count(*) AS Arvo_valgetega_mangitud_partiide_arv 
FROM isikud JOIN partiid ON isikud.id = partiid.valge 
WHERE eesnimi = 'Arvo';

/*
10. Leida k?igi Arvode poolt kokku valgetega m?ngitud partiide arv turniiride l?ikes
(turniiri id ja partiide arv).
*/
CREATE VIEW V_10(Turniiri_ID, Arvo_valgetega_mangitud_partiide_arv ) AS
SELECT turniirid.Id AS Turniiri_ID , 
count(*) AS Arvo_valgetega_mangitud_partiide_arv 
FROM turniirid INNER JOIN partiid
ON partiid.turniir = turniirid.id
INNER JOIN isikud
ON isikud.id = partiid.valge WHERE eesnimi = 'Arvo' GROUP BY turniirid.Id  ORDER BY turniirid.Id ;

/*
11. Leida k?igi Mariade poolt kokku mustadega m?ngitud m?ngudest saadud punktide arv
(tulemus = 2 on v?it ja annab ?he punkti, tulemus = 1 on viik ja annab pool punkti).
*/
CREATE VIEW V_11(Mariade_poolt_kokku_mustadega_mängitud_mängudest_saadud_punktide_arv) AS
SELECT SUM(musta_tulemus)/2 AS Mariade_poolt_kokku_mustadega_mängitud_mängudest_saadud_punktide_arv
FROM isikud JOIN partiid  
ON isikud.id = partiid.must 
WHERE eesnimi = 'Maria';

/*
12. Leida partiide keskmine kestvus turniiride kaupa (tulemuseks on tabel 2 veeruga:
turniiri nimi, keskmine partii pikkus).
*/
CREATE VIEW V_12(Turniiri_nimi,Keskmine_partiide_pikkus) AS
SELECT turniirid.Nimetus AS Turniiri_nimi, SUM (DATEDIFF(minute, algushetk, lopphetk))/count(*) AS Keskmine_partiide_pikkus 
FROM partiid JOIN turniirid  
ON partiid.turniir = turniirid.Id GROUP BY turniirid.Nimetus;
