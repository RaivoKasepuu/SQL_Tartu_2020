---------------------------------------------------------------------
--                           ANDMEBAASID
---------------------------------------------------------------------
--                           IV praktikum
---------------------------------------------------------------------
-- Vaated;
-- Tabelite täitmine päringute abil;
-- Päringute piiramine
---------------------------------------------------------------------

-- Lõige isikute tabelist: vaid isikud klubist numbriga 54:
CREATE VIEW v_klubi54 AS
SELECT * FROM isikud WHERE klubi = 54;

-- kasutamine:
SELECT* FROM v_klubi54

-- Lõige isikute tabelist: vaid isikute nimed klubist numbriga 54
CREATE VIEW v_klubi54pisi (eesnimi, perenimi) AS
SELECT eesnimi, perenimi FROM isikud WHERE klubi = 54;

-- või kasutades juba loodud vaadet v_klubid_54:
CREATE VIEW v_klubi54pisi AS
SELECT eesnimi, perenimi FROM v_klubi54;

-- Loome vaate mängijate andmetega:

/*
Ühendame isikute tabeli ja klubide tabeli seosega isikud.klubi = klubid.id ja
tulemusse tahame veerge nimi ja id tabelist Klubid ning tabelist Isikud isiku
nime (perenimi, eesnimi) ja id väärtust.
*/
CREATE VIEW v_mangijad (klubi_nimi, klubi_id, isik_nimi, isik_id) AS
SELECT klubid.nimi, klubid.id, isikud.perenimi || ', ' || isikud.eesnimi, isikud.id
FROM isikud JOIN klubid ON isikud.klubi = klubid.id;

/*
Loome vaate v_partiid. Selleks vajame andmeid tabelitest isikud: valgetega ja
mustadega mängija nimed, nende klubid (mängija klubi nimi) ja partiid (id,
millisel turniiril, millal algas ja partii tulemus).
Seda päringut on lihtne koostada pannes päringusse tabeli partiid ja vaate
v_mangijad valgetega mängija andmete saamiseks ja teist korda mustadega
mängija andmete tarvis.
*/
CREATE VIEW v_partiid (id, turniir, algus, valge_nimi,
valge_klubi, valge_punkt, must_nimi, must_klubi, must_punkt ) AS
SELECT p.id, p.turniir, p.algushetk, v.isik_nimi,
v.klubi_nimi, p.valge_tulemus / 2.0, m.isik_nimi,
m.klubi_nimi, p.musta_tulemus / 2.0
FROM partiid as p, v_mangijad as v, v_mangijad as m
WHERE p.valge = v.isik_id AND p.must = m.isik_id;

---------------------------------------------------------------------
SELECT * FROM v_partiid ORDER BY algus;
---------------------------------------------------------------------
--                    TABELITE TÄITMINE PÄRINGUTE ABIL
---------------------------------------------------------------------
/*
Täidame tabeli päringuga.
Tavaliselt ajaloo säilitamiseks või keerukamate
andmetöötluste tegemise jaoks.
INSERT INTO <tabel> [({VEERUD})]
SELECT .... FROM .... WHERE ... jne
*/

-- Eesnimede esinemise sagedused. Loome tabeli eesnimede muutuste jälgimiseks
CREATE TABLE eesnimed (
eesnimi varchar(50) NOT NULL,
kogus integer NOT NULL,
hetk datetime NOT NULL DEFAULT current timestamp,
PRIMARY KEY (eesnimi, hetk)
);

-- Lisame andmed veergudesse eesnimi ja kogus
INSERT INTO eesnimed (eesnimi, kogus)
SELECT eesnimi, count(*) FROM isikud GROUP BY eesnimi;
SELECT * FROM eesnimed;

-- Muudame eesnimesid tabelis isikud:
INSERT INTO isikud (eesnimi, perenimi, klubi)
VALUES ('Maria', 'Lihtne', 54);
UPDATE isikud SET eesnimi = 'Toomas'
WHERE eesnimi = 'Taivo';

-- Kordame andmete lisamist tabelisse eesnimed:
INSERT INTO eesnimed (eesnimi, kogus)
SELECT eesnimi, count(*) FROM isikud
GROUP BY eesnimi;

-- Vaatame kuidas muutus nimede arv:
SELECT eesnimi, hetk, kogus FROM eesnimed
WHERE eesnimi IN ( 'Maria' ,
                   'Toomas', 'Taivo') ORDER BY hetk;

---------------------------------------------------------------------
--                    PÄRINGU PIIRAMINE KOGUSEGA
---------------------------------------------------------------------
-- SELECT TOP <mitu> [START AT <esimene>] {veerud} ...
-- Kolm esimest nimekirjas:
SELECT TOP 3 eesnimi, perenimi FROM isikud;

-- NB! järjestus oli juhuslik! Õigem oleks:
SELECT TOP 3 eesnimi, perenimi FROM isikud
ORDER BY perenimi, eesnimi;

-- Eelviimane isik (perenimede järjestuses)
-- mängijate nimekirjas:
SELECT TOP 1 START AT 2 eesnimi, perenimi
FROM isikud ORDER BY perenimi DESC, eesnimi DESC;
---------------------------------------------------------------------

-- Abitabeli täitmine numbritega
CREATE TABLE viis (nr INTEGER NOT NULL PRIMARY KEY);

INSERT INTO viis
SELECT TOP 8 number(*) FROM partiid;

DELETE FROM viis WHERE nr > 5;
---------------------------------------------------------------------
--                    MASSILINE ANDMETE LISAMINE
---------------------------------------------------------------------

/*
Tekitame kõigile tudengitele erinevused tabelisse partiid (omad andmed).
Selleks:
Lisame uue kirje (uue turniiri) tabelisse turniirid.
Olgu uus turniiri numbriga 47 (id=47)
Lisame selle kirje (nn käsitsi)
*/

INSERT INTO turniirid
(id, nimi, toimumiskoht, alguskuupaev, loppkuupaev)
VALUES
(47, 'Kuldkarikas 2010'
, 'Elva', '2010-10-14'
, '2010-10-14');

-- Muutsime meelt: turniiri nimi olgu Plekkkarikas
UPDATE turniirid SET nimi = 'Plekkkarikas 2010' WHERE id = 47;

-- Lisame juurde kõigi mängijate omavahelised partiid
-- (va endaga ja mängijatega klubist 57), algushetke võtame juhusliku
INSERT INTO partiid (turniir, algushetk, valge, must)
SELECT turniirid.id, dateadd(minute,1+rand()*10,
dateadd(hour, 8+rand()*10,turniirid.alguskuupaev)), v.id, m.id
FROM turniirid , isikud v, isikud m
WHERE turniirid.id = 47 AND v.id <> m.id AND
v.klubi <> 57 AND m.klubi <> 57;

-- Väärtustame (juhuslikult) veerud Lõpphetk ja paneme paika juhuslik võitja
UPDATE partiid SET lopphetk = dateadd(second,
50+mod(id, 121), dateadd(minute, 19 +
mod(id,18) + mod(id,3) - mod(id,13), algushetk))
WHERE turniir = 47;

UPDATE partiid set valge_tulemus =
mod(id+valge-must+turniir, 3) WHERE turniir = 47;

UPDATE partiid SET musta_tulemus = 2 - valge_tulemus
WHERE turniir = 47;

-- Kustutame need partiid, kus sama turniiri jooksul mängijate paar kordub
DELETE FROM partiid p
WHERE EXISTS (
SELECT * FROM partiid q
WHERE p.valge =q.must AND q.valge = p.must AND
p.id < q.id AND turniir=47)
AND turniir = 47;

-- Kustutame maha ajaliselt kõlbmatud. Pole võimalik alustada uut partiid,
-- kui ühel mängijatest eelmine veel pooleli
DELETE FROM partiid p WHERE EXISTS (
SELECT * FROM partiid q
WHERE p.algushetk>= q.algushetk AND
p.algushetk <= q.lopphetk AND p.id <> q.id AND
(p.valge = q.valge OR p.valge=q.must OR p.must=q.valge OR p.must=q.must)
AND q.turniir = p.turniir
) AND turniir = 47;

---------------------------------------------------------------------

/*
Ülesanne nr 5
1. Luua vaade v_turniiripartiid (turniir_nimi, partii_id, partii_algus,
partii_lopp).
2a. Luua vaade v_klubipartiikogused_1 (klubi_nimi, partiisid) veeru
partiisid väärtus = selliste partiide arv, kus kas valge või must mängija
on klubi liige (kui mõlemad samast, siis lisandub klubile 1 partii).
2b. Luua vaade v_klubipartiikogused_2 (klubi_nimi, partiisid) veeru
partiisid väärtus = selliste partiide arv, kus kas valge või must mängija
on klubi liige (kui mõlemad samast, siis lisandub klubile 2 partiid).
3. Luua vaade v_punktid (partii, turniir, mangija, varv, punkt), kus
oleksid kõigi mängijate kõigi partiide jooksul saadud punktid (viitega
partiile ja turniirile) koos värviga (valge (V), must (M)).
*/
---------------------------------------------------------------------