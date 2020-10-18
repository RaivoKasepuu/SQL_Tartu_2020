-- Kodune t�� YL4
-- Raivo Kasepuu
/*
1. Leida klubi �Laudnikud� liikmete nimekiri (eesnimi, perenimi) t�hestiku j�rjekorras
(eesnimi, perenimi).
*/
SELECT eesnimi, perenimi FROM isikud JOIN klubid
WHERE klubid.nimi = 'Laudnikud' ORDER BY eesnimi, perenimi;

/*
2. Leida klubi �Laudnikud� liikmete arv.
*/
SELECT COUNT(*) AS klubi_Laudnikud_liikmete_arv 
FROM isikud JOIN klubid WHERE klubid.nimi = 'Laudnikud';

/*
3. Leida V-t�hega algavate klubide M-t�hega algavate eesnimedega isikute perekonnanimed
(ja ei muud).
*/
SELECT perenimi AS V_tahega_algavate_klubide_M_tahega_algavate_eesnimedega_isikute_perekonnanimed 
FROM isikud JOIN klubid WHERE klubid.nimi like 'v%' AND isikud.eesnimi LIKE 'm%';

/*
4. Leida k�ige esimesena alanud partii algusaeg.
*/ 
SELECT TOP 1 algushetk 
AS koige_esimesena_alanud_partii_algusaeg 
FROM partiid ORDER BY algushetk;

/*
5. Leida partiide m�ngijad (viited m�ngijatele (v�ljad: valge ja must)), mis algasid 04.
m�rtsil 2005 aastal ajavahemikus 9:00 kuni 11:00.

[9:58] Jaana Liländer-Koppel
    Tere. Mul olid kõik korras. Jagan soovitud vastust:

SELECT Valge, Must FROM Partiid
WHERE Algushetk BETWEEN '2005-03-04 09:00'
AND '2005-03-04 11:00'

*/
SELECT eesnimi, perenimi 
FROM isikud JOIN partiid 
ON isikud.id = partiid.valge OR isikud.id = partiid.must 
WHERE algushetk BETWEEN 
'2005-03-04 09:00:00.0' AND '2005-03-04 11:00:00.0';
 
/*
6. Leida valgetega v�itnute (valge_tulemus=2) isikute nimed (eesnimi, perenimi), kus partii
kestis 9 kuni 11 minutit (vt funktsiooni Datediff(); Datediff(minute, <algus>, <l�pp>)).
*/
SELECT eesnimi, perenimi FROM isikud JOIN partiid 
ON isikud.id = partiid.valge WHERE valge_tulemus = 2 
AND DATEDIFF(minute, algushetk, lopphetk) BETWEEN 9 AND 11; 

/*
7. Leida tabelis Isikud rohkem kui 1 kord esinevad perekonnanimed (ja ei muud).
*/
SELECT perenimi FROM isikud 
GROUP BY perenimi HAVING COUNT(*) > 1;

/*
8. Leida klubid (nimi ja liikmete arv), kus on alla 4 liikme.
*/
SELECT nimi AS Klubi_nimi, count(*) AS Liikmete_arv 
FROM isikud JOIN klubid ON isikud.klubi = klubid.id 
GROUP BY nimi HAVING Liikmete_arv < 4 ;

/*
9. Leida k�igi Arvode poolt kokku valgetega m�ngitud partiide arv.
*/
SELECT count(*) AS Arvo_valgetega_mangitud_partiide_arv 
FROM isikud JOIN partiid ON isikud.id = partiid.valge 
WHERE eesnimi = 'Arvo';

/*
10. Leida k�igi Arvode poolt kokku valgetega m�ngitud partiide arv turniiride l�ikes
(turniiri id ja partiide arv).
*/
SELECT turniirid.Id AS Turniiri_ID , 
count(*) AS Arvo_valgetega_mangitud_partiide_arv 
FROM turniirid INNER JOIN partiid
ON partiid.turniir = turniirid.id
INNER JOIN isikud
ON isikud.id = partiid.valge WHERE eesnimi = 'Arvo' GROUP BY turniirid.Id  ORDER BY turniirid.Id ;

/*
11. Leida k�igi Mariade poolt kokku mustadega m�ngitud m�ngudest saadud punktide arv
(tulemus = 2 on v�it ja annab �he punkti, tulemus = 1 on viik ja annab pool punkti).
*/
SELECT SUM(musta_tulemus)/2 AS Mariade_poolt_kokku_mustadega_m�ngitud_m�ngudest_saadud_punktide_arv
FROM isikud JOIN partiid  
ON isikud.id = partiid.must 
WHERE eesnimi = 'Maria';

/*
12. Leida partiide keskmine kestvus turniiride kaupa (tulemuseks on tabel 2 veeruga:
turniiri nimi, keskmine partii pikkus).
*/
SELECT turniirid.Nimetus AS Turniiri_nimi, SUM (DATEDIFF(minute, algushetk, lopphetk))/count(*) AS Keskmine_partiide_pikkus 
FROM partiid JOIN turniirid  
ON partiid.turniir = turniirid.Id GROUP BY turniirid.Nimetus;
 
