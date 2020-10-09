/*
Ülesanne nr 5
1. Luua vaade v_turniiripartiid (turniir_nimi, partii_id, partii_algus,
partii_lopp).
*/
CREATE VIEW v_turniiripartiid (turniir_nimi, partii_id, partii_algus, partii_lopp)
AS SELECT Nimetus, partiid.id, algushetk, lopphetk
FROM partiid JOIN turniirid ON partiid.turniir = turniirid.id;

/*
 2a. Luua vaade v_klubipartiikogused_1 (klubi_nimi, partiisid) veeru
partiisid väärtus = selliste partiide arv, kus kas valge või must mängija
on klubi liige (kui mõlemad samast, siis lisandub klubile 1 partii).
 */

 /*
2b. Luua vaade v_klubipartiikogused_2 (klubi_nimi, partiisid) veeru
partiisid väärtus = selliste partiide arv, kus kas valge või must mängija
on klubi liige (kui mõlemad samast, siis lisandub klubile 2 partiid).
*/

/*
3. Luua vaade v_punktid (partii, turniir, mangija, varv, punkt), kus
oleksid kõigi mängijate kõigi partiide jooksul saadud punktid (viitega
partiile ja turniirile) koos värviga (valge (V), must (M)).
 */

 /*
  4. Vaate v_punktid ja vaate v_mangijad põhjal teha vaade
v_edetabelid (mangija, turniir, punkte), kus veerus mangija
on mängija nimi (v_mangijad.isik_nimi) ja veerus turniir
on turniiri ID. Punkte arvutatakse iga turniiri jaoks
(mängija punktid sellel turniiril).

  */


/*
5. Teha päring paremusjärjestuse saamiseks: Kolm paremat
turniiri “Kolme klubi kohtumine” (turniiri ID = 41)
edetabeli saamiseks (järjekorra number, nimi ja punktid)
ning vormistada see vaatena v_kolmik.
  */