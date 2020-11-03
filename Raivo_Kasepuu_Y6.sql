-- Kodune töö YL6
-- Raivo Kasepuu

/*
 1. Luua f-n klubiliikmete arvu leidmiseks klubi id põhjal
f_klubisuurus(id)
OK!
 */
CREATE FUNCTION f_klubisuurus(klubid_id INTEGER)
    RETURNS INTEGER
BEGIN
    DECLARE liikmeteArv INTEGER;
    SELECT COUNT(*) INTO liikmeteArv
    FROM isikud WHERE klubi = klubid_id;
    RETURN liikmeteArv;
END;

SELECT f_klubisuurus(51);

/*
2. Luua f-n ees- ja perenime kokku liitmiseks eesti ametlikul viisil
("perenimi, eesnimi") f_nimi('Eesnimi' , 'Perenimi').
OK!
 */
CREATE FUNCTION f_nimi(eesnimi VARCHAR(50), perenimi VARCHAR(50))
    RETURNS VARCHAR(100)
BEGIN
    DECLARE nimi VARCHAR(100);
    SELECT perenimi + ' , ' + eesnimi INTO nimi;
    RETURN nimi;
END;

SELECT f_nimi('Raivo', 'Kasepuu');
/*
3. Luua f-n ühe mängija partiide koguarv f_mangija_koormus(id)
OK!
 */

CREATE FUNCTION f_mangija_koormus(mangija INTEGER)
    RETURNS INTEGER
BEGIN
    DECLARE koormus INTEGER;
    SELECT COUNT(*) INTO koormus
    FROM partiid
    WHERE mangija = valge OR mangija = must;
    RETURN koormus;
END;

SELECT f_mangija_koormus(72);

/*
4. Luua f-n ühe mängija võitude arv turniiril f_mangija_voite_turniiril(isikud.id, turniirid.id)
OK!
*/
CREATE FUNCTION f_mangija_voite_turniiril(isikud_id INTEGER, turniirid_id INTEGER)
    RETURNS INTEGER
BEGIN
    DECLARE wins INTEGER;
    SELECT COUNT(*) INTO wins
    FROM v_punktid
    WHERE mangija = isikud_id AND punkt = 1 AND turniir = turniirid_id;
    RETURN wins;
END;

SELECT f_mangija_voite_turniiril(71,42);

/*
5. Luua f-n ühe mängija punktisumma turniiril
f_mangija_punktid_turniiril(isikud.id, turniirid.id)
OK!
 */
CREATE FUNCTION f_mangija_punktid_turniiril(isikud_id INTEGER, turniirid_id INTEGER)
    RETURNS FLOAT
BEGIN
    DECLARE punktid FLOAT;
    SELECT SUM(punkt) INTO punktid
    FROM v_punktid
    WHERE isikud_id = mangija AND turniirid_id = turniir;
    RETURN punktid;
END;

SELECT f_mangija_punktid_turniiril(72, 42);

/*
6. Luua protseduur sp_uus_isik, mis lisab eesnime ja perenimega
määratud isiku etteantud numbriga klubisse ning paneb neljandasse
parameetrisse uue isiku ID väärtuse. (Analoogiline praktikumis tehtuga).
OK! */
CREATE PROCEDURE sp_uus_isik(IN a_eesnimi VARCHAR(50), IN a_perenimi VARCHAR(50), IN a_klubi INTEGER, OUT a_id INTEGER)
BEGIN
    DECLARE i_id INTEGER;
    INSERT INTO isikud(eesnimi, perenimi, klubi)
    VALUES(a_eesnimi, a_perenimi, a_klubi);
    SELECT @@identity INTO i_id;
    MESSAGE 'Lisatud uus isik klubisse:' || i_id TO CLIENT;
    SET a_id=i_id
END;

CALL sp_uus_isik('Onu', 'Remus', 57);

/*
7. Luua tabelit väljastav protseduur sp_infopump()
See peab andma välja unioniga kokku panduna järgmised asjad (kasutades
varemdefineeritud võimalusi):
1) klubi nimi ja tema mängijate arv (kasutada funktsiooni f_klubisuurus)
2) turniiri nimi ja tema jooksul tehtud mängude arv (kasutada group by)
3) mängija nimi ja tema poolt mängitud partiide arv (kasutada f_nimi ja
f_mangija_koormus) ning tulemus sorteerida nii, et klubide info oleks kõige
ees, siis turniiride oma ja siis alles isikud. Iga grupi sees sorteerida nime järgi.
OK!
 */
CREATE PROCEDURE sp_infopump()
    RESULT (nimi VARCHAR(50), arv INTEGER)
           BEGIN
SELECT nimi, arv FROM (
                          SELECT nimi AS nimi, f_klubisuurus(id) AS arv, 1 AS filter
                          FROM klubid
                          UNION
                          SELECT turniirid.Nimetus AS nimi, COUNT(*) AS arv, 2 AS filter
                          FROM partiid
                                   JOIN turniirid
                                        ON turniirid.id = partiid.turniirid
                          GROUP BY turniirid.Nimetus
                          UNION
                          SELECT f_nimi(isikud.eesnimi, isikud.perenimi) AS nimi , COUNT(*) AS arv, 3 AS filter
                          FROM isikud
                                   JOIN partiid ON isikud.id = partiid.valge OR isikud.id = partiid.must
                          GROUP BY nimi)
                          AS infopump,
                      ORDER BY filter, nimi
END;

CALL sp_infopump();

/*
8. Luua tabelit väljastav protseduur sp_top10, millel on üks parameeter -
turniiri id, ja mis kasutab vaadet v_edetabelid ja annab tulemuseks kümme
parimat etteantud turniiril.
OK!
 */
CREATE PROCEDURE sp_top10(IN turniir_id INTEGER)
    RESULT (mangija VARCHAR(50))
           BEGIN
SELECT TOP 10 mangija
FROM v_edetabelid
WHERE turniir = turniir_id
ORDER BY punkte DESC;
END;

CALL sp_top10(41);

/*
9. Luua tabelit väljastav protseduur sp_voit_viik_kaotus, mis väljastab kõigi
osalenud mängijate võitude, viikide ja kaotuste arvu etteantud turniiril. Tabeli
struktuur: id, eesnimi, perenimi, võite, viike, kaotusi
(f_mangija_voite_turniiril jt sarnased funktsioonid oleksid abiks ...)
OK!
*/

-- teeme sarnaselt võitude funktsioonile ka funktsioonid kaotuste ja viikide kohta:
CREATE FUNCTION f_mangija_viike_turniiril(isikud_id INTEGER, turniirid_id INTEGER)
    RETURNS INTEGER
BEGIN
    DECLARE viike INTEGER;
    SELECT COUNT(*) INTO viike
    FROM v_punktid
    WHERE mangija = isikud_id AND punkt = 0.5 AND turniir = turniirid_id;
    RETURN viike;
END;

CREATE FUNCTION f_mangija_kaotusi_turniiril(isikud_id INTEGER, turniirid_id INTEGER)
    RETURNS INTEGER
BEGIN
    DECLARE kaotusi INTEGER;
    SELECT COUNT(*) INTO kaotusi
    FROM v_punktid
    WHERE mangija = isikud_id AND punkt = 0 AND turniir = turniirid_id;
    RETURN kaotusi;
END;

-- ja kasutame nüüd neid kolme funktsiooni nõutud protseduuri moodustamises:

CREATE PROCEDURE sp_voit_viik_kaotus (IN turniir_id INTEGER)
RESULT (id INTEGER, eesnimi VARCHAR(50), perenimi VARCHAR(50), võite INTEGER, viike INTEGER, kaotusi INTEGER)
BEGIN
SELECT mangija, isikud.eesnimi, isikud.perenimi,
       f_mangija_voite_turniiril(mangija, turniir) AS 'Võite',
       f_mangija_viike_turniiril(mangija, turniir) AS 'Viike',
       f_mangija_kaotusi_turniiril(mangija, turniir) AS 'Kaotusi'
FROM v_punktid
         JOIN isikud
              ON mangija = isikud.id
WHERE turniir = turniir_id GROUP BY turniir, mangija, perenimi, eesnimi
END

CALL sp_voit_viik_kaotus (41);

/*
10. Luua indeks turniiride algusaegade peale.
OK!
*/
CREATE INDEX index_algusaeg ON turniirid(alguskuupaev);


/*
11. Luua indeksid partiidele kahanevalt valge ja musta tulemuse peale.
OK!
 */
CREATE INDEX index_valge_must_tulemus ON partiid(valge_tulemus DESC, musta_tulemus DESC);


