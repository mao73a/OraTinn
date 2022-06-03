CREATE OR REPLACE PACKAGE BODY orw_pck_ksiegowania_pom
AS
 g_wycena_REC      T_Ksiegowany_Portfel_REC;
 g_data_ks_portf   DATE;
 g_typ_portf_kod   VARCHAR2(20 CHAR);
 g_typ_dysp_kod    VARCHAR2(20 CHAR);
 g_typ_wyc_kod     VARCHAR2(20 CHAR);
 g_data_portf_par  DATE;
 g_podmiot_id      PLS_INTEGER;
 g_zrodlo          VARCHAR2(1 CHAR);
 g_ksieguj_naliczenie_jest_pw VARCHAR2(2 CHAR);
 g_ksieguj_naliczenie_tp_kod  VARCHAR2(20 CHAR);
 g_potwierdzone     VARCHAR2(5 CHAR);
 g_data_ost_spl_kon_asm DATE;


 function ver(p_info    VARCHAR2 DEFAULT NULL)
----------------------------------
 return VARCHAR2 is
 v_wersja varchar(120):=     '$Revision:: 225                                                                                                       $';
 v_nazwa_pliku varchar(120):='$Workfile:: ksiegpom.bdy                                                                                              $';
 v_modyfikacja varchar(120):='$Modtime:: 02.06.22 15:49                                                                                             $';
 v_uzytkownik varchar(120):= '$Author:: OCHAL                                                                                                       $';
 v_naglowek varchar(120):=   '$Header:: /orl/ORS/Common/ddl/ksiegpom.bdy 225 1.0.225 02.06.22 15:49 OCHAL                                           $';
begin
if p_info is NULL then return replace(v_wersja||CHR(10)||v_nazwa_pliku||CHR(10)||v_modyfikacja||CHR(10)||
        v_uzytkownik||CHR(10)||v_naglowek,' ','');
 elsif 'revision' LIKE LOWER(p_info)||'%' then
    return v_wersja;
 elsif 'workfile' LIKE LOWER(p_info)||'%' then
    return v_nazwa_pliku;
 elsif 'modtime' LIKE LOWER(p_info)||'%' then
    return v_modyfikacja;
 elsif 'author' LIKE LOWER(p_info)||'%' then
    return v_uzytkownik;
 elsif 'header' LIKE LOWER(p_info)||'%' then
    return v_naglowek;
 end if;
 return 'Dozwolone parametry: r,w,m,a,h.';
 end ver;
 --------------------------------------------------------------------------------
 -- Anuluje ksiegowanie portfela i zwraca numer dyspozycji  PT:43671
 -------------------------------------------------------------------------------
 function anuluj_ksieg_portfela(
 -------------------------------
            p_typ_portf_kod VARCHAR2,
            p_podmiot_id    PLS_INTEGER,
            p_typ_dysp_kod  VARCHAR2,
            p_oznaczenie    VARCHAR2,
            p_data          DATE,
            p_typ_storna    VARCHAR2, --CZARNY/CZERWONY
            p_typ_wyc_kod   VARCHAR2,
            p_komentarz OUT VARCHAR2,
            p_poziom_grupy  VARCHAR2 DEFAULT NULL, --PT:97397
            p_potwierdz     VARCHAR2 DEFAULT 'N', -- GA: ten parametr jest niepotrzebny, potwierdzanie anulacji ma zalezec
                                                --  tylko i wylacznie od tego, czy dyspozycja anulowana jest potwierdzona
            p_param_list    VARCHAR2 DEFAULT NULL
           )
 return NUMBER is
   v_wycena_REC   orw_pck_ksiegowania_pom.T_Ksiegowany_Portfel_REC;
   v_portfel_REC  orw_pck_portfele.TPortfelRec;
   v_portfel_ARR  ORW_PCK_PORTFELE.TPortfeleArr;
   v_dysp_id      NUMBER;
   v_portfel_id   NUMBER;
   v_licznik      PLS_INTEGER;
   v_anul         PLS_INTEGER;
   v_idx          PLS_INTEGER;
   v_czas_id      NUMBER;
   v_dysp_nr      VARCHAR2(200 CHAR);
   v_zrodlo       VARCHAR2(200 CHAR);
   v_dysp_pierw_nr VARCHAR2(200 CHAR);
   v_grupowa      VARCHAR2(20 CHAR);
   v_dysp_pierw_potw VARCHAR2(20 CHAR);
   v_data_ks_nal  DATE;
   v_agreguj      BOOLEAN;
   v_wykluczenia_ROWID_ARR      dbms_sql.VARCHAR2_table;
   v_wykluczenia_DYSP_ID_ARR    dbms_sql.NUMBER_table;
   v_ROWID        VARCHAR2(50 CHAR);
   v_dysp_pop_id  NUMBER;

 begin
   begin
     select id into v_portfel_id
     from ort_portfele
     where typ_portf_kod=p_typ_portf_kod and
           podmiot_id=p_podmiot_id;
   exception
     when NO_DATA_FOUND THEN
       orw_pck_bledy.zglos('blad_wewnetrzny','l=1429');
   end;
   v_grupowa:=p_poziom_grupy;
   if v_grupowa is NULL then --PT:97397
     begin
       select 'T' into v_grupowa
       from ort_typy_dla_typow_info
       where typ_info_kod='PWYCGR' and
             typ_portf_kod=p_typ_portf_kod;
     exception
       when NO_DATA_FOUND then
         v_grupowa:='N';
     end;
   end if;

   --Ide po skladowych grup/strategi lub portfelu i wykonuje anulacje o ile jest co anulowac
   IF orw_pck_portfele.otworz_kursor_GRST(v_portfel_ARR, v_portfel_id, v_agreguj,
         v_grupowa, p_data) THEN --PT:46323  informuje czy grupe ksiegowac rachunkami skladowymi czy jako podmiot
    v_idx:=v_portfel_ARR.First;

    orw_pck_admin.czas_sys_zakoncz(v_czas_id);
   END IF;
   if  p_param_list is NOT NULL then
     --sprzatanie: przywracam pierwtne wartosci powiazan miedzy analizownymi naliczeniami a dyspozycjami
     FORALL v_idx IN 1..v_wykluczenia_ROWID_ARR.COUNT
          UPDATE ORT_DATY_NALICZEN
          set DYSP_ID=v_wykluczenia_DYSP_ID_ARR(v_idx)
          WHERE ROWID=v_wykluczenia_ROWID_ARR(v_idx);
   end if;
   return v_dysp_id;
 exception
  WHEN Orw_Pck_Bledy.blad THEN
    Orw_Pck_Bledy.rejestruj_przejscie(
      'orw_pck_ksiegowania_pom.anuluj_ksieg_portfela(p_typ_portf_kod='||p_typ_portf_kod||', p_podmiot_id='||p_podmiot_id||', p_typ_dysp_kod='||p_typ_dysp_kod||', p_oznaczenie='||p_oznaczenie||', p_data='||TO_CHAR(p_data,'dd/mm/yyyy')||', p_typ_storna='||p_typ_storna||', p_typ_wyc_kod='||p_typ_wyc_kod||', p_komentarz='||p_komentarz||', p_poziom_grupy='||p_poziom_grupy||', p_potwierdz='||p_potwierdz||' p_param_list='||p_param_list||')-'||v_wycena_REC.dysp_id);
  WHEN OTHERS THEN
    Orw_Pck_Bledy.zglosp('orw_pck_ksiegowania_pom.anuluj_ksieg_portfela(p_typ_portf_kod='||p_typ_portf_kod||', p_podmiot_id='||p_podmiot_id||', p_typ_dysp_kod='||p_typ_dysp_kod||', p_oznaczenie='||p_oznaczenie||', p_data='||TO_CHAR(p_data,'dd/mm/yyyy')||', p_typ_storna='||p_typ_storna||', p_typ_wyc_kod='||p_typ_wyc_kod||', p_komentarz='||p_komentarz||', p_poziom_grupy='||p_poziom_grupy||', p_potwierdz='||p_potwierdz||' p_param_list='||p_param_list||')-'||v_wycena_REC.dysp_id);
 end;
   
end orw_pck_ksiegowania_pom;
/

