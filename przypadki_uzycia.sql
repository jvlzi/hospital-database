/*
1.Zestawienie PACJENT�W niepe�noletnich PLUS um.nazwa,um.rodzaj
*/
SELECT p.imie,p.nazwisko,p.data_urodzenia,
    --CASE WHEN um.nazwa IS NULL THEN 'Brak' ELSE um.nazwa END as "Nazwa us�ugi medycznej",
    NVL(um.nazwa,'Brak')as "Nazwa us�ugi medycznej",
    CASE WHEN um.rodzaj IS NULL THEN 'Brak' ELSE um.rodzaj END as "Rodzaj us�ugi medycznej"
FROM PACJENCI p LEFT OUTER JOIN USLUGI_MEDYCZNE um ON(p.p_id=um.pacjenci_p_id)
WHERE data_urodzenia > SYSDATE - INTERVAL '18' YEAR
ORDER BY p.data_urodzenia;

CREATE VIEW NIEPELNOLETNI_PACJENCI
AS SELECT p.imie,p.nazwisko,p.data_urodzenia,
    NVL(um.nazwa,'Brak')as "Nazwa us�ugi medycznej",
    CASE WHEN um.rodzaj IS NULL THEN 'Brak' ELSE um.rodzaj END as "Rodzaj us�ugi medycznej"
FROM PACJENCI p LEFT OUTER JOIN USLUGI_MEDYCZNE um ON(p.p_id=um.pacjenci_p_id)
WHERE data_urodzenia > SYSDATE - INTERVAL '18' YEAR;
/*
2.Lista lek�w zapisana pacjentowi z ostatnich 3 lat ( 3 tabele po��czone plus sysdate)
*/
SELECT p.imie || ' ' || p.nazwisko as "Pacjent", 
        (SELECT l.nazwa
        FROM LEKI l 
        WHERE r2.leki_l_id = l.l_id) as "Lek", ek.data_wpisu
FROM RELATION_2 r2
    JOIN ELEMENTY_KARTOTEKI ek ON (r2.elementy_kartoteki_ek_id=ek.ek_id)
    JOIN PACJENCI p ON (r2.elementy_kartoteki_ek_id=p.elementy_kartoteki_ek_id)
WHERE data_wpisu > SYSDATE - INTERVAL '3' YEAR
    
;

CREATE VIEW LEKI_3LATA
AS SELECT p.imie || ' ' || p.nazwisko as "Pacjent", 
        (SELECT l.nazwa
        FROM LEKI l 
        WHERE r2.leki_l_id = l.l_id) as "Lek",ek.data_wpisu
FROM RELATION_2 r2
    JOIN ELEMENTY_KARTOTEKI ek ON (r2.elementy_kartoteki_ek_id=ek.ek_id)
    JOIN PACJENCI p ON (r2.elementy_kartoteki_ek_id=p.elementy_kartoteki_ek_id)
WHERE data_wpisu > SYSDATE - INTERVAL '3' YEAR;
/*
3. Dla ka�dego oddzia�u wy�wietl liczb� zatrudnionych tam doktor�w w kolejno�ci od najwiecej lekarzy oraz sume wynagrodzenia i �redni�
*/
SELECT o.nazwa,COUNT(o.lekarze_lek_id) as "Liczba lekarzy",ROUND(SUM(lek.wynagrodzenie),2) as "Suma wynagrodze�",
        ROUND(AVG(lek.wynagrodzenie),2) as "�rednie wynagrodzenie"
FROM ODDZIALY o 
    LEFT OUTER JOIN RELATION_10 r10 ON (r10.lekarze_lek_id=o.lekarze_lek_id)
    LEFT OUTER JOIN LEKARZE lek ON (o.lekarze_lek_id=lek.lek_id)
GROUP BY o.nazwa
ORDER BY 2 DESC,1;

CREATE VIEW DOKTORZY_LICZBY
AS SELECT o.nazwa,COUNT(o.lekarze_lek_id) as "Liczba lekarzy",ROUND(SUM(lek.wynagrodzenie),2) as "Suma wynagrodze�", ROUND(AVG(lek.wynagrodzenie),2) as "�rednie wynagrodzenie"
FROM ODDZIALY o 
    LEFT OUTER JOIN RELATION_10 r10 ON (r10.lekarze_lek_id=o.lekarze_lek_id)
    LEFT OUTER JOIN LEKARZE lek ON (o.lekarze_lek_id=lek.lek_id)
GROUP BY o.nazwa;
/*
4.Pacjencie z poznania kt�rzy data wpisu > 2018/01/01
*/
SELECT p.imie,p.nazwisko,upper(p.miasto) as "MIASTO"
FROM PACJENCI p JOIN ELEMENTY_KARTOTEKI ek ON (ek.ek_id=p.elementy_kartoteki_ek_id)
WHERE p.miasto LIKE '%Pozna�%'
    AND data_wpisu > TO_DATE('2018/01/01','YYYY/MM/DD');

CREATE VIEW PACJENCI_POZNAN
AS SELECT p.imie,p.nazwisko,upper(p.miasto) as "MIASTO"
FROM PACJENCI p JOIN ELEMENTY_KARTOTEKI ek ON (ek.ek_id=p.elementy_kartoteki_ek_id)
WHERE p.miasto LIKE '%Pozna�%'
    AND data_wpisu > TO_DATE('2018/01/01','YYYY/MM/DD');            
/*
5. wY�WIETL LEKARZA KT�RY WYKONUJ� us�ugi medyczne BADANIE KRWI
*/
SELECT *
FROM LEKARZE
WHERE lek_id = (SELECT lekarze_lek_id
                FROM RELATION_9
                WHERE USLUGI_MEDYCZNE_UM_ID = (SELECT UM_ID
                                                FROM USLUGI_MEDYCZNE
                                                WHERE nazwa = 'Badanie krwi'));

CREATE VIEW LEKARZE_BADANIE_KRWI
AS SELECT *
FROM LEKARZE
WHERE lek_id = (SELECT lekarze_lek_id
                FROM RELATION_9
                WHERE USLUGI_MEDYCZNE_UM_ID = (SELECT UM_ID
                                                FROM USLUGI_MEDYCZNE
                                                WHERE nazwa = 'Badanie krwi'));
/*
6.	 lista piel�gniarek oraz  lista doktor�w dla oddzia��w 
*/
SELECT o.nazwa,lek.imie ||' '||lek.nazwisko AS "Lekarz", pi.imie||' '||pi.nazwisko AS "Piel�gniarka"
FROM ODDZIALY o
    LEFT OUTER JOIN LEKARZE lek ON (lek.oddzialy_o_id=o.o_id)
    LEFT OUTER JOIN PIELEGNIARKI pi ON (o.o_id=pi.oddzialy_o_id)
ORDER BY o.nazwa
;
CREATE VIEW LEKARZE_PIELEGNIARKI
AS SELECT o.nazwa,lek.imie ||' '||lek.nazwisko AS "Lekarz", pi.imie||' '||pi.nazwisko AS "Piel�gniarka"
FROM ODDZIALY o
    LEFT OUTER JOIN LEKARZE lek ON (lek.oddzialy_o_id=o.o_id)
    LEFT OUTER JOIN PIELEGNIARKI pi ON (o.o_id=pi.oddzialy_o_id);
/*
7. Ile lekarzy i pielegniarek na oddzia� ma telefon podany
*/
SELECT o.nazwa, COUNT(pi.telefon) as "Liczba lekarzy z tel",COUNT(pi.telefon) as "Liczba pi�l�gniarek z tel"
FROM ODDZIALY o
    LEFT OUTER JOIN LEKARZE lek ON (lek.oddzialy_o_id=o.o_id)
    LEFT OUTER JOIN PIELEGNIARKI pi ON (o.o_id=pi.oddzialy_o_id)
GROUP BY o.nazwa;

CREATE VIEW telefony
AS SELECT o.nazwa, COUNT(pi.telefon) as "Liczba lekarzy z tel",COUNT(pi.telefon) as "Liczba pi�l�gniarek z tel"
FROM ODDZIALY o
    LEFT OUTER JOIN LEKARZE lek ON (lek.oddzialy_o_id=o.o_id)
    LEFT OUTER JOIN PIELEGNIARKI pi ON (o.o_id=pi.oddzialy_o_id)
GROUP BY o.nazwa;

