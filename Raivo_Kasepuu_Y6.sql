-- Kodune töö YL6
-- Raivo Kasepuu

/*
 1. Luua f-n klubiliikmete arvu leidmiseks klubi id põhjal
f_klubisuurus(id)
 */


/*
2. Luua f-n ees- ja perenime kokku liitmiseks eesti ametlikul viisil
("perenimi, eesnimi") f_nimi('Eesnimi' , 'Perenimi').
 */


/*
3. Luua f-n ühe mängija partiide koguarv f_mangija_koormus(id)
 */


/*
4. Luua f-n ühe mängija võitude arv turniiril f_mangija_voite_turniiril(isikud.id, turniirid.id)
 */



/*
5. Luua f-n ühe mängija punktisumma turniiril
f_mangija_punktid_turniiril(isikud.id, turniirid.id)
 */


/*
6. Luua protseduur sp_uus_isik, mis lisab eesnime ja perenimega
määratud isiku etteantud numbriga klubisse ning paneb neljandasse
parameetrisse uue isiku ID väärtuse. (Analoogiline praktikumis tehtuga).
 */


/*
7. Luua tabelit väljastav protseduur sp_infopump()
See peab andma välja unioniga kokku panduna järgmised asjad (kasutades
varemdefineeritud võimalusi):
1) klubi nimi ja tema mängijate arv (kasutada funktsiooni f_klubisuurus)
2) turniiri nimi ja tema jooksul tehtud mängude arv (kasutada group by)
3) mängija nimi ja tema poolt mängitud partiide arv (kasutada f_nimi ja
f_mangija_koormus) ning tulemus sorteerida nii, et klubide info oleks kõige
ees, siis turniiride oma ja siis alles isikud. Iga grupi sees sorteerida nime järgi.
 */


/*
8. Luua tabelit väljastav protseduur sp_top10, millel on üks parameeter -
turniiri id, ja mis kasutab vaadet v_edetabelid ja annab tulemuseks kümme
parimat etteantud turniiril.
 */


/*
9. Luua tabelit väljastav protseduur sp_voit_viik_kaotus, mis väljastab kõigi
osalenud mängijate võitude, viikide ja kaotuste arvu etteantud turniiril. Tabeli
struktuur: id, eesnimi, perenimi, võite, viike, kaotusi
(f_mangija_voite_turniiril jt sarnased funktsioonid oleksid abiks ...)
 */


/*
10. Luua indeks turniiride algusaegade peale.
 */

/*
11. Luua indeksid partiidele kahanevalt valge ja musta tulemuse peale.
 */
