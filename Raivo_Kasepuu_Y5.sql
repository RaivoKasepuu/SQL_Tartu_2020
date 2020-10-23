-- Kodune töö YL5
-- Raivo Kasepuu

/*
Ülesanne nr 5
1. Luua vaade v_turniiripartiid (turniir_nimi, partii_id, partii_algus,
partii_lopp).
*/

CREATE VIEW v_turniiripartiid (turniir_nimi, partii_id, partii_algus, partii_lopp) AS
SELECT Nimetus, partiid.id, algushetk, lopphetk
FROM partiid
         JOIN turniirid ON partiid.turniir = turniirid.id;

/*
 2a. Luua vaade v_klubipartiikogused_1 (klubi_nimi, partiisid) veeru
partiisid väärtus = selliste partiide arv, kus kas valge või must mängija
on klubi liige (kui mõlemad samast, siis lisandub klubile 1 partii).
 */

CREATE VIEW v_klubipartiikogused_1 AS
SELECT klubi_nimi, SUM(partiid) AS partiisid
FROM (SELECT klubid.nimi       AS klubi_nimi,
             COUNT(partiid.id) AS partiid
      FROM partiid
               JOIN isikud ON partiid.valge = isikud.id
               JOIN klubid ON isikud.klubi = klubid.id
               JOIN isikud AS isik ON partiid.must = isik.id
               JOIN klubid AS klub ON isik.klubi = klub.id
      WHERE klubi_nimi <> klub.nimi
      GROUP BY klubi_nimi
      UNION ALL
      SELECT klubid.nimi AS klubi_nimi, COUNT(partiid.id) AS partiid
      FROM partiid
               JOIN isikud ON partiid.must = isikud.id
               JOIN klubid ON isikud.klubi = klubid.id
               JOIN isikud AS isik ON partiid.valge = isik.id
               JOIN klubid AS klub ON isik.klubi = klub.id
      GROUP BY klubi_nimi
     ) AS peavalu_1
GROUP BY klubi_nimi;

/*
2b. Luua vaade v_klubipartiikogused_2 (klubi_nimi, partiisid) veeru
partiisid väärtus = selliste partiide arv, kus kas valge või must mängija
on klubi liige (kui mõlemad samast, siis lisandub klubile 2 partiid).
*/

CREATE VIEW v_klubipartiikogused_2 AS
SELECT klubi_nimi, SUM(partiid) AS partiisid
FROM (SELECT klubid.nimi AS klubi_nimi, COUNT(partiid.id) AS partiid
      FROM partiid
               JOIN isikud ON partiid.valge = isikud.id
               JOIN klubid ON isikud.klubi = klubid.id
               JOIN isikud AS isik ON partiid.must = isik.id
               JOIN klubid AS klub ON isik.klubi = klub.id
      GROUP BY klubi_nimi
      UNION ALL
      SELECT klubid.nimi AS klubi_nimi, COUNT(partiid.id) AS partiid
      FROM partiid
               JOIN isikud ON partiid.must = isikud.id
               JOIN klubid ON isikud.klubi = klubid.id
               JOIN isikud AS isik ON partiid.valge = isik.id
               JOIN klubid AS klub ON isik.klubi = klub.id
      GROUP BY klubi_nimi
     ) AS peavalu_2
GROUP BY klubi_nimi;

/*
3. Luua vaade v_punktid (partii, turniir, mangija, varv, punkt), kus
oleksid kõigi mängijate kõigi partiide jooksul saadud punktid (viitega
partiile ja turniirile) koos värviga (valge (V), must (M)).
 */

CREATE VIEW v_punktid AS
SELECT partiid.id                  AS partii,
       partiid.turniir             AS turniir,
       isikud.id                   AS mangija,
       'V'                         AS varv,
       partiid.valge_tulemus / 2.0 AS punkt
FROM partiid
         JOIN isikud ON partiid.valge = isikud.id
UNION ALL
SELECT partiid.id                  AS partii,
       partiid.turniir             AS turniir,
       isikud.id                   AS mangija,
       'M'                         AS varv,
       partiid.musta_tulemus / 2.0 AS punkt
FROM partiid
         JOIN isikud ON partiid.must = isikud.id
ORDER BY partii, varv;

/*
 4. Vaate v_punktid ja vaate v_mangijad põhjal teha vaade
v_edetabelid (mangija, turniir, punkte), kus veerus mangija
on mängija nimi (v_mangijad.isik_nimi) ja veerus turniir
on turniiri ID. Punkte arvutatakse iga turniiri jaoks
(mängija punktid sellel turniiril).
 */

CREATE VIEW v_edetabelid AS
SELECT v_mangijad.isik_nimi AS mangija, v_punktid.turniir AS turniir, SUM(v_punktid.punkt) AS punkte
FROM v_punktid
         JOIN v_mangijad ON v_punktid.mangija = v_mangijad.isik_id
GROUP BY mangija, turniir
ORDER BY mangija, turniir;

/*
5. Teha päring paremusjärjestuse saamiseks: Kolm paremat
turniiri “Kolme klubi kohtumine” (turniiri ID = 41)
edetabeli saamiseks (järjekorra number, nimi ja punktid)
ning vormistada see vaatena v_kolmik.
  */

-- variant 1: turniiri ID = 41:
CREATE VIEW v_kolmik AS
SELECT TOP 3 number() AS järjekorra_number, mangija AS nimi, punkte AS punktid
FROM v_edetabelid
WHERE turniir = 41
ORDER BY punktid DESC;

-- variant 2: turniiri Nimetus = 'Kolme klubi kohtumine'
CREATE VIEW v_kolmik AS
SELECT TOP 3 number() AS järjekorra_number, mangija AS nimi, punkte AS punktid
FROM v_edetabelid JOIN turniirid ON v_edetabelid.turniir = turniirid.id
WHERE turniirid.Nimetus = 'Kolme klubi kohtumine'
ORDER BY punktid DESC;
