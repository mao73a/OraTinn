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

--Wygenerowane przez O:\orl\ADMIN\wyczysc_zmienne_globalne.sql
PROCEDURE wyczysc_zmienne_globalne
is
BEGIN
  g_saldo_dla_syntetyki_cache := NULL;
  g_wycena_REC := NULL;
  g_data_ks_portf := NULL;
  g_typ_portf_kod := NULL;
  g_typ_dysp_kod := NULL;
  g_typ_wyc_kod := NULL;
  g_data_portf_par := NULL;
  g_podmiot_id := NULL;
  g_zrodlo := NULL;
  g_ksieguj_naliczenie_jest_pw := NULL;
  g_ksieguj_naliczenie_tp_kod := NULL;
  g_data_ost_spl_kon_asm := NULL;
  g_potwierdzone:=NULL;
END;

FUNCTION papier_dla_synt(p_synt_kod VARCHAR2, p_pw_id NUMBER,p_kb_id NUMBER DEFAULT NULL)
------------------------------------------------------------
RETURN VARCHAR2 IS
  CURSOR c_konta(p_instr NUMBER,p_konto_bank VARCHAR2) IS
   SELECT  p.*
    FROM
         ors_synt_kont_ol s,
         ORS_PLAN_KONT h,
         ORT_PODMIOTY_ANALITYK p
   WHERE s.ojciec = p_synt_kod AND
         h.ak_status = 'AKTYWNY' AND
         h.sk_kod = s.lisc AND
         p.anal_knt_id = h.ak_id                              AND
        (p_konto_bank IS NULL OR p.typ_knt_ba_kod = p_konto_bank) AND
        (p_instr IS NULL AND p.instrument_id is NULL
        OR (
         EXISTS
              (SELECT 1 FROM ORS_INSTRUMENTY_OL i WHERE
                 i.ojciec = p.instrument_id AND i.lisc = p_instr)));

  v_wynik    VARCHAR2(1 CHAR);
  v_instr    NUMBER;
  v_pw_id    PLS_INTEGER;
  v_konto    c_konta%ROWTYPE;
  v_typ_kb VARCHAR2(2000 CHAR);
BEGIN
  if orw_pck_admin.g_typ_symulacji is NOT NULL then --PT:39158
    v_pw_id:=orw_pck_uzytki_des04.krotki_pw(p_pw_id);
  else
    v_pw_id:=p_pw_id;
  end if;
  IF v_pw_id is not null then
   SELECT instrument_id INTO v_instr
    FROM ort_papiery_wartosciowe
   WHERE id = v_pw_id;
  end if;
  IF p_kb_id is not null then
   select typ_knt_ba_kod into v_typ_kb
     from ort_konta_bankowe where id =p_kb_id;
  end If;
  OPEN c_konta(v_instr,v_typ_kb);
  FETCH c_konta INTO v_konto;
  LOOP
   IF c_konta%NOTFOUND THEN
    v_wynik :='N';
    EXIT;
   ELSE
    IF v_konto.parametr IS NOT NULL AND
     orw_pck_operacje01.par_an_wart(v_konto.parametr,v_konto.typ_info_kod,v_pw_id,NULL,NULL,p_kb_id)='T'   -- z par an wart:
     THEN
     v_wynik := 'T';
     EXIT;
    ELSIF v_konto.parametr IS  NULL THEN
     v_wynik := 'T';
     EXIT;
    END IF;
   END IF;
   FETCH c_konta INTO v_konto;
  END LOOP;
  CLOSE c_konta;
  RETURN v_wynik;
exception
  WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.papier_dla_synt('||p_synt_kod ||', '||p_pw_id||')');
  WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.papier_dla_synt('||p_synt_kod ||', '||p_pw_id||')');
END;




 function bylo_ksiegowanie(
 ---------------------------
                   p_typ_dysp_kod         VARCHAR2,
                   p_pw_kod       VARCHAR2,
                   p_data         DATE,
                   p_podmiot_id           NUMBER DEFAULT NULL,
                   p_data_waluty_transakcji DATE DEFAULT NULL,
                   p_typ_info_kod         Varchar2 default null, -- w dysp ma byc ten typ info z wartoœci¹ jak poni¿ej
                   p_wartosc              Varchar2 default null  -- chyba ¿e tu NULLe to nie sprawdza tego
               )
 return VARCHAR2 is
  v_pom VARCHAR2(10 CHAR);
  v_cnt NUmber;
  v_owner Varchar2(100 CHAR) := orw_pck_admin.daj_ownera;
 begin
  if p_typ_dysp_kod is NULL then
      return 'T';
  end if;
 --ksiegowanie bez papieru

  if p_pw_kod is NULL then
    if orw_pck_admin.pobierz_global('TINS')='PORTFEL' and
       p_podmiot_id is NOT NULL then
      select dummy into v_pom from dual
      where  exists (select d.id from ort_dyspozycje d
                where d.typ_dysp_kod=p_typ_dysp_kod AND
                  d.potwierdzone='T' AND
                  d.data_waluty=TRUNC(p_data) AND
                  d.data_waluty_transakcji=nvl(trunc(p_data_waluty_transakcji), d.data_waluty_transakcji) AND
                  d.podmiot_id=p_podmiot_id
                  and not exists (select 1 from ort_info_o_dyspozycjach where dysp_id = D.id and typ_info_kod = 'NDAN')
                  and not exists (select 1 from ort_info_o_dyspozycjach where dysp_id = D.id and typ_info_kod = p_typ_info_kod and wartosc<>p_wartosc)
                );
    else
      select dummy into v_pom from dual
      where  exists (select d.id from ort_dyspozycje d
                where d.typ_dysp_kod=p_typ_dysp_kod AND
                  d.potwierdzone='T' AND
                  d.data_waluty=TRUNC(p_data) and
                  d.data_waluty_transakcji=nvl(trunc(p_data_waluty_transakcji), d.data_waluty_transakcji)
                  and not exists (select 1 from ort_info_o_dyspozycjach where dysp_id = D.id and typ_info_kod = 'NDAN')
                  and not exists (select 1 from ort_info_o_dyspozycjach where dysp_id = D.id and typ_info_kod = p_typ_info_kod and wartosc<>p_wartosc)
                );
    end if;
    return 'T';
  end if;
  --ksiegowanie dla papieru
  if orw_pck_admin.pobierz_global('TINS')='PORTFEL' and p_podmiot_id is NOT NULL then
--    if v_owner like 'ORS_CU%'  then
      select /*+ ORDERED INDEX(IOD INF_O_DYS_WARTOSC_I) */ count(d.id)
        into v_cnt
        from ort_info_o_dyspozycjach iod,
             ort_dyspozycje d
        where d.id=iod.dysp_id
          AND d.typ_dysp_kod=p_typ_dysp_kod
          AND d.data_waluty<=orw_pck_raporty01.data_plus_x_r(TRUNC(p_data), 3)
          and d.data_waluty>=orw_pck_raporty01.data_plus_x_r(TRUNC(p_data),-3)
          and d.data_waluty_transakcji=nvl(trunc(p_data_waluty_transakcji), d.data_waluty_transakcji)
          AND iod.typ_info_kod='KODP'
          AND iod.wartosc=p_pw_kod
          AND d.podmiot_id=p_podmiot_id
          and not exists (select 1 from ort_info_o_dyspozycjach where dysp_id = D.id and typ_info_kod = 'NDAN')
          and not exists (select 1 from ort_info_o_dyspozycjach where dysp_id = D.id and typ_info_kod = p_typ_info_kod and wartosc<>p_wartosc) ;
  else
    -- dla ORF-ow - data waluty moze byc do 3 dni wczesniejsza od data ksiegowania z kalendarium
    select /*+ ORDERED INDEX(IOD INF_O_DYS_WARTOSC_I) */ count(d.id)
      into v_cnt
      from ort_info_o_dyspozycjach iod,
           ort_dyspozycje d
      where d.id=iod.dysp_id
        AND d.typ_dysp_kod=p_typ_dysp_kod
        AND d.data_waluty between orw_pck_raporty01.data_plus_x_r(TRUNC(p_data),-3) and TRUNC(p_data)
        and d.data_waluty_transakcji=nvl(trunc(p_data_waluty_transakcji), d.data_waluty_transakcji)
        AND iod.typ_info_kod='KODP'
        AND iod.wartosc=p_pw_kod
        and not exists (select 1 from ort_info_o_dyspozycjach where dysp_id = D.id and typ_info_kod = 'NDAN')
        and not exists (select 1 from ort_info_o_dyspozycjach where dysp_id = D.id and typ_info_kod = p_typ_info_kod and wartosc<>p_wartosc) ;
  end if;
  if v_cnt = 0 then
    return 'N';
  end if;
  return 'T';
 EXCEPTION
  WHEN NO_DATA_FOUND then
   return 'N';
 end bylo_ksiegowanie;

 ------------------------------------------------------------------------------------------
 -- Funkcja zwraca date ostatniej dyspozycj danego typu. Jesli podano PW to sprawdza
 -- dyspozycje dla danego pw. Jesli podano date sprawdza dyspozycje poprzedzajace lub rowne
 -- tej dacie
 --  p_typ_dysp_kod - kod typu dyspozycji
 --  p_pw_id        - kod papieru (moze byc NULLowy)
 --  p_data         - maksymalna data ksiegowan
 --  p_typ          - zwracana data
 --    * DWPIS - data wpisania dyspozycji zaoraglona
 --    * dwpis  - data wpisania niezaokraglona
 --    * DWYST - data wystawienia
 --    * DWAL  - data waluty
 --  p_typ_wyc_kod - kod typu wyceny
 --  p_podmiot_id - id podmiotu - wlasciciela dyspozycji
 ------------------------------------------------------------------------------------------
 function data_ostatniej_dysp(
 ---------------------------------
            p_typ_dysp_kod     VARCHAR2,
            p_pw_id            NUMBER DEFAULT NULL,
            p_data             DATE DEFAULT NULL,
            p_typ              VARCHAR2 DEFAULT 'DWPIS',
            p_typ_wyc_kod      VARCHAR2 DEFAULT null,
            p_podmiot_id       PLS_INTEGER DEFAULT NULL --PT:100033
            )
return date is
 v_pw_kod       VARCHAR2(100 CHAR);
 v_typ_wyc_kod  VARCHAR2(200 CHAR);
 v_data        DATE;
begin

  v_typ_wyc_kod:=p_typ_wyc_kod;
 --sprawdzamy czy buylo ksiegowanie
 if p_data is NULL then
   if v_typ_wyc_kod is NULL or v_typ_wyc_kod='%' then
      select max(DECODE(p_typ,
                        'DWPIS',TRUNC(data_wpisania),
                        'dwpis',data_wpisania,
                        'DWYST',data_wystawienia,
                        'DWAL',data_waluty ) )
      into v_data
      from ort_dyspozycje d
      where typ_dysp_kod=p_typ_dysp_kod AND
            d.dysp_anul_id is NULL AND
            (p_podmiot_id is NULL or d.wlasciciel_id=p_podmiot_id);
   else --PT:64122
      select max(DECODE(p_typ,
                        'DWPIS',TRUNC(data_wpisania),
                        'dwpis',data_wpisania,
                        'DWYST',data_wystawienia,
                        'DWAL',data_waluty ) )
      into v_data
      from ort_dyspozycje d,
           ort_info_o_dyspozycjach iodTYWYC
      where typ_dysp_kod=p_typ_dysp_kod AND
            d.dysp_anul_id is NULL AND
            iodTYWYC.typ_info_kod='TWYCKOD' and
            iodTYWYC.dysp_id=d.id and
            iodTYWYC.wartosc=v_typ_wyc_kod AND
            (p_podmiot_id is NULL or d.wlasciciel_id=p_podmiot_id);
   end if;
 else
   if v_typ_wyc_kod is NULL or v_typ_wyc_kod='%' then
      select max(DECODE(p_typ,
                        'DWPIS',TRUNC(data_wpisania),
                        'dwpis',data_wpisania,
                        'DWYST',data_wystawienia,
                        'DWAL', data_waluty ) )
      into v_data
      from ort_dyspozycje d
      where d.typ_dysp_kod=p_typ_dysp_kod AND
            d.dysp_anul_id is NULL AND
            DECODE(p_typ,
                        'DWPIS',TRUNC(data_wpisania),
                        'dwpis',data_wpisania,
                        'DWYST',data_wystawienia,
                        'DWAL', data_waluty ) <=p_data AND
            (p_podmiot_id is NULL or d.wlasciciel_id=p_podmiot_id) and
            (p_pw_id is NULL or d.pw_krotki_id=p_pw_id); --PT:161597
   else --PT:64122
      select max(DECODE(p_typ,
                        'DWPIS',TRUNC(data_wpisania),
                        'dwpis',data_wpisania,
                        'DWYST',data_wystawienia,
                        'DWAL', data_waluty ) )
      into v_data
      from ort_dyspozycje d,
           ort_info_o_dyspozycjach iodTYWYC
      where typ_dysp_kod=p_typ_dysp_kod AND
          DECODE(p_typ,
                        'DWPIS',TRUNC(data_wpisania),
                        'dwpis',data_wpisania,
                        'DWYST',data_wystawienia,
                        'DWAL', data_waluty ) <=p_data and
          iodTYWYC.typ_info_kod='TWYCKOD' and
          iodTYWYC.dysp_id=d.id and
          d.dysp_anul_id is NULL AND --PT:77509
          iodTYWYC.wartosc=v_typ_wyc_kod AND --PT:64122
         (p_podmiot_id is NULL or d.wlasciciel_id=p_podmiot_id);
   end if;
 end if;
 return v_data;
 exception
    WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.data_ostatniej_dysp');
    WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.data_ostatniej_dysp');
 end;
------------------------------------------------------------------------------------------
-- Funkcja ustawia status na NIEAKTYWNY dla papierow ktore wg kalendarium powinny
-- byc nieaktywne (minela dla nich data wykonia operacji.
--  p_data - data sprawdzania kalendarium
-- RK: jesli instrument ma zdefiniowany ilosc dni od wykupu (np. DEZAKTYW_PW='W3')
--     to unieaktywnaj, niezaleznie czy wykup byl zrobiony, czy nie
-- Zwraca tekst z informacja o wykonanych update'ach
------------------------------------------------------------------------------------------
 function dezaktywacja_pw(p_data DATE)
 -------------------------------------
 return VARCHAR2 is
   v_owner Varchar2(100 CHAR) := orw_pck_admin.daj_ownera;
  cursor c_zdarzenia(cp_data DATE) is
    SELECT  /*+ ORDERED */ -- RK: rozpisane ORV_KALENDARIUM bez sprawdzania, czy papier na kontach
       PW.KOD PW_KOD
      ,PW.ID PW_ID
      ,PW.STATUS STATUS
      ,TIK.TI_OPIS TI_OPIS
      ,substr(TIK.DEZAKTYW_PW,1,1) DEZAKTYW_PW
    FROM
      ort_info_o_pw  ipw,
      ort_papiery_wartosciowe  pw,
      ors_tinfo_kalendar  tik,
      ort_instrumenty i,
      ors_instrumenty_ol iol
    WHERE
      (--length(tik.dezaktyw_pw)>1 OR
         orw_pck_kalendarium.wykonano(tik.typ_dysp_kod,
                                      tik.tdt_typ_info_kod,
                                      pw.kod,
                                      orw_pck_kalendarium.data_plus_x_R(IPW.wartosc_data, orw_pck_kalendarium.opoznienie_kalendarium (ipw.typ_info_kod, pw_id))
                                     ) = 'T') AND
      ipw.typ_info_kod=tik.tdt_typ_info_kod AND
      tik.lev=1 AND
      ipw.pw_id=pw.id AND
      i.id = pw.instrument_id AND
      i.nazwa not like '%z_puli' AND
      IPW.WARTOSC_DATA <= orw_pck_kalendarium.data_plus_x_R(
               TRUNC(cp_data),nvl(-to_number(substr(tik.dezaktyw_pw,2)),-1)) AND
      tik.dezaktyw_pw!='N' and
      iol.ojciec=tik.tdt_instrument_id and
      pw.instrument_id=iol.syn
      and ipw.wartosc_data between add_months(cp_data, -1) and cp_data;
  cursor c_pw_podrz(cp_pw_id NUMBER) is
   select pw_id, pw.kod, pw.status
   from ort_zaleznosci_pw, ort_papiery_wartosciowe pw
   where pw_id_zalezec_od=cp_pw_id AND
      typ_zal_pw_kod IN ('PWKU','PWIM','PWPO') AND
     pw_id=pw.id;
  cursor c_paczki_waluty is
    select pw.id pw_id,pw.kod
      from orx_papiery_wartosciowe PW
      where instrument_id = 98
        and status = 'AKTYWNY'
   minus
   select pw_id,pw.kod
     from orv_salda_aktywne SD,orx_papiery_wartosciowe pw
     where data = trunc(p_data)
       and (symbol like '930 7000%' or symbol like '930 4000%' or symbol like '930 5000%')
       and saldo_wn <> saldo_ma
       and pw.id = SD.pw_id and pw.status = 'AKTYWNY'
       --and exists (select 1 from orx_papiery_wartosciowe where id = SD.pw_id and status = 'AKTYWNY')
   minus
   select  distinct PW.id,pw.kod
     from orv_salda_aktywne SD,
          orx_papiery_wartosciowe lok,
          orv_dziennik_okrojony DOP,
          ort_dyspozycje D,
          orx_papiery_wartosciowe PW
     where SD.data = orw_pck_admin.biezaca_data_ks
       and SD.symbol like '920 1100%'
       and SD.saldo_wn <> SD.saldo_ma
       and lok.id = SD.pw_id
       --and I_NRDY.typ_info_kod = 'NRDY'
       and D.id = DOP.dysp_id
       and D.id = lok.dysp_tworz_id
       and PW.id = DOP.pw_id
       and PW.instrument_id = 98
       and PW.status = 'AKTYWNY'
       and D.dysp_anul_id is null;

  cursor c_lokaty is
   select distinct pw.id, pw.kod,
          count(distinct pw_id) over () ile
     from orv_salda_wszystkie_data s,
          orx_papiery_wartosciowe pw
 	  where data = p_data
   	  and substr(S.symbol, 1, 3) in ('031', '120', '121', '220', '295')
   	  and saldo_wn = saldo_ma
   	  and pw.id = s.pw_id
   	  and PW.instrument_id = 44
   	  and PW.status = 'AKTYWNY';

  cursor c_forwardy(cp_data Date) is
    select PW.*
      from ort_papiery_wartosciowe PW
      where instrument_id = 994
        and status = 'AKTYWNY'
        and to_date(substr(kod, 9, 8), 'DDMMYYYY') <= cp_data;

  cursor c_forwardy_bez_985(cp_data Date) is
    select PW.id pw_id, pw.kod
      from orx_papiery_wartosciowe PW,
           ort_Dyspozycje D
      where instrument_id in (996, 997, 998, 1000, 1015) -- forward umowa, swap, fra, fx-swap umowa, EQS
        and status = 'AKTYWNY'  -- nieaktywnych nie ma co ruszac
        and D.id = PW.dysp_tworz_id
        and D.potwierdzone = 'T'
        and D.data_waluty <= cp_data
    minus
    select pw_id, pw.kod
      from orv_salda_wszystkie_data s,
           orx_papiery_wartosciowe pw
      where symbol like '985 8%'
        and data = cp_data
        and saldo_wn <> saldo_ma
        and pw.id = s.pw_id;

  cursor c_paczki_zerowe is
    select PW.id,pw.kod,PW.instrument_id
      from ors_instrumenty_ol h,
           ort_instrumenty i,
           orx_papiery_wartosciowe pw
          -- orv_salda_wszystkie_Data S
      where h.ojciec = 10
        and i.id = h.lisc
        and i.nazwa like '%z_puli'
        and i.id not in (98) -- mialo byc orginalnie wg GA
        and pw.instrument_id = I.id
        and pw.status = 'AKTYWNY'
        --and S.data = p_data
      --  and S.pw_Id = pw.id
        and pw.id NOT in( SELECT /*+ NO_INDEX(S.K KONTO_SYMBOL_I) */ pw_id FROM  orv_salda_aktywne s where
        (S.symbol like '950%'
             or S.symbol like '926%'
             or S.symbol like '927%'
             or S.symbol like '928%' -- krotka sprzedaz
             or S.symbol like '937%' -- krotka sprzedaz w PZU
             or S.symbol like '940%'
             or S.symbol like '985%'
             or S.symbol like '949%'
             or S.symbol like '939%'
             or S.symbol like '14%'
             or S.symbol like '220%'
             or S.symbol like '225%'
             or S.symbol like '246%'
             or S.symbol like '263%'
             or S.symbol like '266%'
             or S.symbol like '277%'
             or S.symbol like '286%'
             or S.symbol like '280%')
         and S.saldo_wn <> S.saldo_ma
         and S.data = p_data
         AND pw_id IS not NULL
      )
      --group by pw.id
      --having sum(abs(S.saldo_wn - S.saldo_ma)) = 0 -- to nie zwracalo paczek nie majacych wymienionych kont np walut i bylo bardzo wolne
      ;

 v_opis VARCHAR2(2000 CHAR);
 v_bylo VARCHAR2(1 CHAR);
 v_cnt Number;
   v_tins VARCHAR2(100 CHAR);
 v_data Date;
 v_dttr Number;
 v_komunikat1 VARCHAR2(100 CHAR);
 v_komunikat2 VARCHAR2(100 CHAR);
 v_dezpczk   Varchar2(100 CHAR);
 v_mb        Varchar2(100 CHAR);
  -- funkcja sprawdza dla CLa, czy pw jest na kontach:
  FUNCTION mozna(p_pw_id NUMBER, p_data DATE, p_tins VARCHAR2) RETURN BOOLEAN IS
    v_ret BOOLEAN := TRUE;
    v_ile NUMBER;
  BEGIN
    IF p_tins = 'CL' THEN
      select count(*)
      into   v_ile
      from   orv_salda_wszystkie_data swd
      where  swd.saldo_ma > 0
        and  swd.symbol like '1%'
        and  swd.data = trunc(p_data)
        and  swd.pw_id = p_pw_id;
      IF v_ile > 0 THEN
        v_ret := FALSE;
      END IF;
    END IF;
    Return v_ret;
  END;
Begin
  v_tins := orw_pck_uzytki_des08.typ_instalacji;
  v_komunikat1 := orw_pck_tlumacz.komunikat('z_powodu');
  v_komunikat2 := orw_pck_tlumacz.komunikat('stare_dlugie');
  for v_REC in c_zdarzenia(p_data) loop
   --musimy ustawic status papieru (i papierow podrzednych) nieaktywny
   -- dezaktywacja wg kolumny dezaktyw_pw w ORV_KALENDARIUM
   -- N - nic
   -- K - papiery krotkie
   -- W - wszystkie papiery
   -- D - tylko dlugi
   if v_REC.dezaktyw_pw IN ('W','K') then
     if v_REC.status='AKTYWNY' AND mozna(v_REC.pw_id, p_data, v_tins) then
       v_opis:=v_opis||CHR(10)||' -'||v_REC.pw_kod||' '||
         v_komunikat1||' '||substr(v_REC.ti_opis,instr(v_REC.ti_opis,' ')+1);
       orr_pck_public.ort_papiery_wartosciowe_update(v_REC.pw_id,'NIEAKTYWNY');
     end if;
   end if;
   if v_REC.dezaktyw_pw IN ('W','D') then
     v_bylo:='N';
     for v_pod_REC in c_pw_podrz(v_REC.pw_id) loop
       if v_pod_REC.status='AKTYWNY' AND mozna(v_pod_REC.pw_id, p_data, v_tins) then
          orr_pck_public.ort_papiery_wartosciowe_update(v_pod_REC.pw_id,'NIEAKTYWNY');
         v_bylo:='T';
       end if;
     end loop;
     if v_bylo='T' then
       v_opis := v_opis||CHR(10)||' -'||v_REC.pw_kod||'('||v_komunikat2||') '||
         v_komunikat1||' '||substr(v_REC.ti_opis,instr(v_REC.ti_opis,' ')+1);
     end if;
   elsif v_REC.dezaktyw_pw = 'S' then -- S=stare, powinno dotyczyæ splitów, bêd¹ dezaktywowane paczki posiadaj¹ce KODNAST
     for v_pod_REC in c_pw_podrz(v_REC.pw_id) loop
       select count(*)
         into v_cnt
         from ort_info_o_pw
         where pw_id = v_pod_REC.pw_id
           and typ_info_kod = 'KODNAST';
       if v_pod_REC.status='AKTYWNY' and v_cnt > 0 AND mozna(v_pod_REC.pw_id, p_data, v_tins) then
          orr_pck_public.ort_papiery_wartosciowe_update(v_pod_REC.pw_id,'NIEAKTYWNY');
         v_bylo:='T';
       end if;
     end loop;
     if v_bylo = 'T' then
       v_opis := v_opis||CHR(10)||' -'||v_REC.pw_kod||'('||v_komunikat2||') '||
                   v_komunikat1||' '||substr(v_REC.ti_opis,instr(v_REC.ti_opis,' ')+1);
     end if;
   end if;
  end loop;
  -- sprawdzenie, czy jest konto 947 1000 w planie kont
  -- jeœli jest, to robimy dewzaktywacje paczek waluty
  -- wy³¹czone dla aplikacji powierniczych (by WT)
  if substr(v_owner,1,3) not in ('OWD','OWK','ORP') then
    for v_paczki_waluty in c_paczki_waluty loop
      orr_pck_public.ort_papiery_wartosciowe_update(v_paczki_waluty.pw_id, 'NIEAKTYWNY');
      v_opis := substr(v_opis || chr(10) || v_paczki_waluty.kod, 1, 2000);
    end loop;
    v_cnt := 0;
    for v_lokata in c_lokaty loop
      orr_pck_public.ort_papiery_wartosciowe_update(v_lokata.id, 'NIEAKTYWNY');
      if v_lokata.ile < 25 then
        v_opis := substr(v_opis || chr(10) || v_lokata.kod, 1, 2000);
      else
        v_cnt := v_lokata.ile;
      end if;
    end loop;
    if v_cnt > 0 then
      v_opis := substr(v_opis || chr(10) ||orw_pck_tlumacz.komunikat('Lokaty')||': '||v_cnt, 1, 2000);
    end if;

    -- forwardy
    begin
      select wartosc
        into v_dttr
        from ort_info_stale
        where typ_info_kod = 'DTTR';
    exception
      when no_data_found then
        v_dttr := 0;
    end;
    if v_dttr <> 0 then
      v_data := orw_pck_kalendarium.data_plus_x_r(p_data, -v_dttr);
    end if;
    for v_pw in c_forwardy(v_data) loop
      orr_pck_public.ort_papiery_wartosciowe_update(v_pw.id, 'NIEAKTYWNY');
    end loop;
  end if;

  -- dezaktywacja forwardow - info ???
  if nvl(orw_pck_uzytki_des07.parametr_info_o_operacji('DFOTWDN', 'FXDSBL'), 'N') = 'T' then
    for v_pw in c_forwardy_bez_985(p_data) loop
      orr_pck_public.ort_papiery_wartosciowe_update(v_pw.pw_id, 'NIEAKTYWNY');
      v_opis := substr(v_opis || chr(10) || v_pw.kod, 1, 2000);
    end loop;
  end if;
  -- dezaktywacja paczek - info stale DEZPCZK
  begin
    select wartosc
      into v_dezpczk
      from ort_info_stale
        where typ_info_kod = 'DEZPCZK';
  exception
    when no_data_found then
      v_dezpczk := 'N';
  end;
  if v_dezpczk = 'T' then
    for v_pw in c_paczki_zerowe loop
      orr_pck_public.ort_papiery_wartosciowe_update(v_pw.id, 'NIEAKTYWNY');
      if v_pw.instrument_id = 192 then
        -- PT:208105 - sprawdzamy, czy opcja niegieldowa
        begin
          select wartosc
            into v_mb
            from ors_info_o_pw
            where pw_id = orw_pck_uzytki_des04.krotki_pw(v_pw.id)
              and typ_info_kod = 'OPMB';
          if v_mb = 'T' then
            orr_pck_public.ort_papiery_wartosciowe_update(orw_pck_uzytki_des04.krotki_pw(v_pw.id), 'NIEAKTYWNY');
          end if;
        exception
          when no_data_found then
            v_mb := 'N';
        end;
      end if;
      v_opis := substr(v_opis || chr(10) || v_pw.kod, 1, 2000);
    end loop;
  end if;
  --commit;
  return NVL(v_opis,orw_pck_tlumacz.komunikat('brak_pw_do_wylaczenia') ); --'brak papierów do wy³¹czenia'
 exception
  when others then
   return orw_pck_tlumacz.komunikat('niepoprawne');
 end;

 ---------------------------------------------------------------------------------------
 -- Funkcja zwraca date ostatniego ksiegowania portfela wczesniejsza od podanej daty
 --  p_typ_portf_kod - typ portfela
 --  p_typ_dysp_kod  - typ dyspozycji
 --  p_data      - data maksymalna ksiegowan
 --  p_podmiot_id - wlasciciel portfela
 ----------------------------------------------------------------------------------------
 function ost_ksieg_portfela(
 -----------------------------
                  p_typ_portf_kod VARCHAR2,
                  p_typ_dysp_kod  VARCHAR2,
                  p_data    DATE,
                  p_podmiot_id NUMBER
                )
 return DATE is
  v_pom    VARCHAR2(1 CHAR);
  v_pom2   T_Ksiegowany_Portfel_REC;
 begin
   return ost_ksieg_portfela(
                  p_typ_portf_kod,
                  p_typ_dysp_kod,
                  p_data,
                  p_podmiot_id,
                   v_pom,
                   v_pom2
                );
 end;

 ---------------------------------------------------------------------------------------
 -- Funkcja zwraca date ostatniego ksiegowania portfela wczesniejsza od podanej daty
 --  p_typ_portf_kod - typ portfela
 --  p_typ_dysp_kod  - typ dyspozycji
 --  p_data      - data maksymalna ksiegowan
 --  p_podmiot_id - wlasciciel portfela
 --  p_wycena_REC - zwraca "namiary" zaksiegowanej wyceny
 --  p_typ_wyc_kod - typ wyceny dla ktorego zrobiono ksiegowanie
 ----------------------------------------------------------------------------------------
function ost_ksieg_portfela(
 -----------------------------
                  p_typ_portf_kod     VARCHAR2,
                  p_typ_dysp_kod      VARCHAR2,
                  p_data              DATE,
                  p_podmiot_id        NUMBER,
                  p_zrodlo OUT        VARCHAR2,
                  p_wycena_REC IN OUT NOCOPY T_Ksiegowany_Portfel_REC, --MOWA:33793
                  p_typ_wyc_kod       VARCHAR2 DEFAULT '_UZYJ_GLOBALA', --MOWA:33793, przerobione na _UZYJ_GLOBALA dla MOWA:36328
                  p_potwierdzone      VARCHAR2 DEFAULT '' --PT:181879
                )
 return DATE is
  cursor c_ksieg(
                       cp_typ_dysp_kod VARCHAR2,
                       cp_potwierdzone VARCHAR2,
                       cp_portfel_id PLS_INTEGER,
                       cp_typ_wyc_kod  VARCHAR2,
                       cp_data         DATE) is
      select /*+ RULE*/ --/*- ORDERED  INDEX(iod1 INF_O_DYS_DYSP_FK_I)*/ w ORF_CSLP z hintami to zap trwalo 90 s,
         --w CU bez zadnych hintow wykonuje sie ok 18 s; Obecnie najlepiej dziala z RULE.
         --Pewnie trzeba by to zapytanie przepisac na klika prostszych uruchamianych warunkowo PT:40264
               iod2.data data_por,TRUNC(d.data_wystawienia) data_dys, iod3.wartosc portfel_id,
                 iod4.wartosc typ_wyc_kod, iod5.wartosc_data data_wyc, d.id dysp_id,
                 d.data_waluty data_waluty_dysp
      from ort_dyspozycje d,
           ort_info_o_dyspozycjach iod1,
           (select /*- ORDERED  INDEX(iodDPORT INF_O_DYS_DYSP_FK_I) INDEX(iodIDPORT INF_O_DYS_DYSP_FK_I) */
                 iop.wartosc_data data, iodIDPORT.dysp_id dysp_id, iodIDPORT.wartosc portfel_id
            from  ort_dyspozycje d,
                  ort_info_o_dyspozycjach iodDPORT,
                  ort_info_o_dyspozycjach iodIDPORT,
                  ort_info_o_portfelach iop
            where iodDPORT.dysp_id=d.id and
                  iodIDPORT.dysp_id=d.id and
                  iodDPORT.typ_info_kod='DPORT' and
                  iodIDPORT.typ_info_kod='IDPORT' and
                  iop.typ_info_kod='PWYS' and
                  iop.data=iodDPORT.WARTOSC_DATA and
                  iop.portfel_id=iodIDPORT.WARTOSC_LICZBA and
                  d.TYP_DYSP_KOD=cp_typ_dysp_kod
           ) iod2,
           ort_info_o_dyspozycjach iod3,
           ort_info_o_dyspozycjach iod4,
           ort_info_o_dyspozycjach iod5
      where typ_dysp_kod=cp_typ_dysp_kod AND
            d.id=iod1.dysp_id(+) AND
            iod1.typ_info_kod(+)='NDAN' AND
            iod1.wartosc is NULL AND
            TRUNC(NVL(iod2.data,d.data_wystawienia))<=cp_data and
            iod3.dysp_id=d.id and
            iod3.typ_info_kod='IDPORT' and
            (cp_portfel_id is NULL OR cp_portfel_id=iod3.wartosc) and --MOWA:32013
            iod5.dysp_id=d.id and
            iod5.typ_info_kod='DPORT' and
            (potwierdzone='T' OR cp_potwierdzone='N') and
            iod2.dysp_id(+)=d.id and
            iod4.dysp_id(+)=d.id and
            iod4.typ_info_kod(+)='TWYCKOD' and
            (cp_typ_wyc_kod is NULL OR cp_typ_wyc_kod=iod4.wartosc)
      order by NVL(iod2.data,d.data_wystawienia) desc, data_wyc desc; --PT:136798


  cursor c_ksieg_wer2( --PT:42273 - uproszczona wersja zapytania w celu przyspieszenia
                       cp_typ_dysp_kod VARCHAR2,
                       cp_potwierdzone VARCHAR2,
                       cp_portfel_id PLS_INTEGER,
                       cp_typ_wyc_kod  VARCHAR2,
                       cp_data         DATE) is
      select /*+ RULE*/ --/*- ORDERED  INDEX(iod1 INF_O_DYS_DYSP_FK_I)*/ w ORF_CSLP z hintami to zap trwalo 90 s,
         --w CU bez zadnych hintow wykonuje sie ok 18 s; Obecnie najlepiej dziala z RULE.
         --Pewnie trzeba by to zapytanie przepisac na klika prostszych uruchamianych warunkowo PT:40264
               TRUNC(d.data_wystawienia) data_por,TRUNC(d.data_wystawienia) data_dys, iod3.wartosc portfel_id,
                 iod4.wartosc typ_wyc_kod, iod5.wartosc_data data_wyc, d.id dysp_id,
                 d.data_waluty data_waluty_dysp
      from ort_dyspozycje d,
           ort_info_o_dyspozycjach iod1,
           ort_info_o_dyspozycjach iod3,
           ort_info_o_dyspozycjach iod4,
           ort_info_o_dyspozycjach iod5
      where typ_dysp_kod=cp_typ_dysp_kod AND
            d.id=iod1.dysp_id(+) AND
            iod1.typ_info_kod(+)='NDAN' AND
            iod1.wartosc is NULL AND
            d.data_wystawienia<=cp_data and
            iod3.dysp_id=d.id and
            iod3.typ_info_kod='IDPORT' and
            (cp_portfel_id is NULL OR cp_portfel_id=iod3.wartosc) and
            iod5.dysp_id=d.id and
            iod5.typ_info_kod='DPORT' and
            (potwierdzone='T' OR cp_potwierdzone='N') and
            iod4.dysp_id(+)=d.id and
            iod4.typ_info_kod(+)='TWYCKOD' and
            (cp_typ_wyc_kod is NULL OR cp_typ_wyc_kod=iod4.wartosc)
      order by d.data_wystawienia desc, data_wyc desc; --PT:136798

  cursor c_ksieg_wer3( --PT:46003 - jeszcze bardziej uproszczona wersja zapytania w celu przyspieszenia (dla portfela)
                       cp_typ_dysp_kod VARCHAR2,
                       cp_portfel_id   PLS_INTEGER,
                       cp_data         DATE,
                       cp_podmiot_id   PLS_INTEGER) is
      select /*+ ORDERED*/  --INDEX(iod1 INF_O_DYS_DYSP_FK_I)*/ w ORF_CSLP z hintami to zap trwalo 90 s,
         --w CU bez zadnych hintow wykonuje sie ok 18 s; Obecnie najlepiej dziala z RULE.
         --Pewnie trzeba by to zapytanie przepisac na klika prostszych uruchamianych warunkowo PT:40264
         --PT:46323 - przyspieszanie w ING - dorbienie ORDERED
               TRUNC(d.data_wystawienia) data_por,TRUNC(d.data_wystawienia) data_dys, iod3.wartosc portfel_id,
                 '' typ_wyc_kod, iod5.wartosc_data data_wyc, d.id dysp_id,
                 d.data_waluty data_waluty_dysp
      from ort_dyspozycje d,
           ort_info_o_dyspozycjach iod3,
           ort_info_o_dyspozycjach iod5,
           ort_info_o_dyspozycjach iod1
      where D.wlasciciel_id=cp_podmiot_id AND
            typ_dysp_kod=cp_typ_dysp_kod AND
            d.id=iod1.dysp_id(+) AND
            iod1.typ_info_kod(+)='NDAN' AND
            iod1.wartosc is NULL AND
            d.data_wystawienia<=cp_data and
            iod3.dysp_id=d.id and
            iod3.typ_info_kod='IDPORT' and
            cp_portfel_id=iod3.wartosc and
            iod5.dysp_id=d.id and
            iod5.typ_info_kod='DPORT' and
            typ_dysp_kod=cp_typ_dysp_kod AND
            D.wlasciciel_id=cp_podmiot_id
      order by d.data_wystawienia desc, data_wyc desc; --PT:136798

  cursor c_ksieg_wer4( --PT:46323 - wersja wykorzystujaca daty_naliczen
                       cp_typ_dysp_kod VARCHAR2,
                       cp_portfel_id   PLS_INTEGER,
                       cp_data         DATE) is
   select TRUNC(d.data_wystawienia) data_por,TRUNC(d.data_wystawienia) data_dys,
        dn.portfel_id, dn.typ_wyc_kod, dn.data data_wyc, dn.dysp_id,
        d.data_waluty data_waluty_dysp
   From ort_daty_naliczen dn,
        ort_dyspozycje d
   where dn.portfel_id=cp_portfel_id and --PT:79875 - dodanie oblsugi portfela nullowego ze wzgl na CU grp por 17948 PAR2
         d.data_wystawienia<=cp_data and
         dn.dysp_id=d.id and
         d.typ_dysp_kod=cp_typ_dysp_kod
   order by d.data_wystawienia desc, data_wyc desc; --PT:136798

  cursor c_ksieg_wer4_pnull( --PT:46323 - wersja wykorzystujaca daty_naliczen
                       cp_typ_dysp_kod VARCHAR2,
                       cp_data         DATE) is
   select TRUNC(d.data_wystawienia) data_por,TRUNC(d.data_wystawienia) data_dys,
        dn.portfel_id, dn.typ_wyc_kod, dn.data data_wyc, dn.dysp_id,
        d.data_waluty data_waluty_dysp
   From ort_daty_naliczen dn,
        ort_dyspozycje d
   where d.data_wystawienia<=cp_data and
         dn.dysp_id=d.id and
         d.typ_dysp_kod=cp_typ_dysp_kod
   order by d.data_wystawienia desc, data_wyc desc; --PT:136798

  cursor c_ksieg_wer4potw( --PT:46323 - wersja wykorzystujaca daty_naliczen
                       cp_typ_dysp_kod VARCHAR2,
                       cp_portfel_id   PLS_INTEGER,
                       cp_data         DATE) is
   select TRUNC(d.data_wystawienia) data_por,TRUNC(d.data_wystawienia) data_dys,
        dn.portfel_id, dn.typ_wyc_kod, dn.data data_wyc, dn.dysp_id,
        d.data_waluty data_waluty_dysp
   From ort_daty_naliczen dn,
        ort_dyspozycje d
   where dn.portfel_id=cp_portfel_id and --PT:79875 - dodanie oblsugi portfela nullowego ze wzgl na CU grp por 17948 PAR2
         d.data_wystawienia<=cp_data and
         dn.dysp_id=d.id and
         d.potwierdzone='T' and
         d.typ_dysp_kod=cp_typ_dysp_kod
   order by d.data_wystawienia desc, data_wyc desc; --PT:136798

  cursor c_ksieg_wer4potw_pnull( --PT:46323 - wersja wykorzystujaca daty_naliczen
                       cp_typ_dysp_kod VARCHAR2,
                       cp_data         DATE) is
   select TRUNC(d.data_wystawienia) data_por,TRUNC(d.data_wystawienia) data_dys,
        dn.portfel_id, dn.typ_wyc_kod, dn.data data_wyc, dn.dysp_id,
        d.data_waluty data_waluty_dysp
   From ort_daty_naliczen dn,
        ort_dyspozycje d
   where d.data_wystawienia<=cp_data and
         dn.dysp_id=d.id and
         d.potwierdzone='T' and
         d.typ_dysp_kod=cp_typ_dysp_kod
   order by d.data_wystawienia desc, data_wyc desc; --PT:136798

  cursor c_ksieg_wer5potw( --PT:46323 - wersja wykorzystujaca daty_naliczen
                       cp_typ_dysp_kod VARCHAR2,
                       cp_portfel_id   PLS_INTEGER,
                       cp_data         DATE,
                       cp_typ_wyc_kod  VARCHAR2) is
   select TRUNC(d.data_wystawienia) data_por,TRUNC(d.data_wystawienia) data_dys,
        dn.portfel_id, dn.typ_wyc_kod, dn.data data_wyc, dn.dysp_id,
        d.data_waluty data_waluty_dysp
   From ort_daty_naliczen dn,
        ort_dyspozycje d
   where dn.portfel_id=cp_portfel_id and --PT:79875 - dodanie oblsugi portfela nullowego ze wzgl na CU grp por 17948 PAR2
         d.data_wystawienia<=cp_data and
         dn.dysp_id=d.id and
         dn.typ_wyc_kod=cp_typ_wyc_kod and
         d.potwierdzone='T' and
         d.typ_dysp_kod=cp_typ_dysp_kod
   order by d.data_wystawienia desc, data_wyc desc; --PT:136798

  cursor c_ksieg_wer5potw_pnull( --PT:46323 - wersja wykorzystujaca daty_naliczen
                       cp_typ_dysp_kod VARCHAR2,
                       cp_data         DATE,
                       cp_typ_wyc_kod  VARCHAR2) is
   select TRUNC(d.data_wystawienia) data_por,TRUNC(d.data_wystawienia) data_dys,
        dn.portfel_id, dn.typ_wyc_kod, dn.data data_wyc, dn.dysp_id,
        d.data_waluty data_waluty_dysp
   From ort_daty_naliczen dn,
        ort_dyspozycje d
   where d.data_wystawienia<=cp_data and
         dn.dysp_id=d.id and
         dn.typ_wyc_kod=cp_typ_wyc_kod and
         d.potwierdzone='T' and
         d.typ_dysp_kod=cp_typ_dysp_kod
   order by d.data_wystawienia desc, data_wyc desc; --PT:136798

  cursor c_ksieg_pwys_platf4( --PT:64122 - wersja wykorzystujaca daty_naliczen
                       cp_typ_dysp_kod VARCHAR2,
                       cp_potwierdzone VARCHAR2,
                       cp_portfel_id   PLS_INTEGER,
                       cp_data         DATE,
                       cp_typ_wyc_kod  VARCHAR2) is
   select TRUNC(d.data_wystawienia) data_por,TRUNC(d.data_wystawienia) data_dys,
        dn.portfel_id, dn.typ_wyc_kod, dn.data data_wyc, dn.dysp_id,
        d.data_waluty data_waluty_dysp
   From ort_daty_naliczen dn,
        ort_dyspozycje d,
        ort_info_o_portfelach iop
   where dn.portfel_id=cp_portfel_id and --PT:79875 - dodanie oblsugi portfela nullowego ze wzgl na CU grp por 17948 PAR2
         dn.dysp_id=d.id and
         iop.data=dn.data and
         iop.portfel_id=dn.portfel_id and
         iop.wartosc_data<=cp_data and
         iop.typ_info_kod='PWYS' and
         (d.potwierdzone IN ('T', cp_potwierdzone)) and
         (cp_typ_wyc_kod is NULL OR dn.typ_wyc_kod=cp_typ_wyc_kod) and
         d.typ_dysp_kod=cp_typ_dysp_kod
   order by d.data_wystawienia desc, data_wyc desc; --PT:136798

  cursor c_ksieg_pwys_platf4_pnull( --PT:64122 - wersja wykorzystujaca daty_naliczen
                       cp_typ_dysp_kod VARCHAR2,
                       cp_potwierdzone VARCHAR2,
                       cp_data         DATE,
                       cp_typ_wyc_kod  VARCHAR2) is
   select TRUNC(d.data_wystawienia) data_por,TRUNC(d.data_wystawienia) data_dys,
        dn.portfel_id, dn.typ_wyc_kod, dn.data data_wyc, dn.dysp_id,
        d.data_waluty data_waluty_dysp
   From ort_daty_naliczen dn,
        ort_dyspozycje d,
        ort_info_o_portfelach iop
   where dn.dysp_id=d.id and
         iop.data=dn.data and
         iop.portfel_id=dn.portfel_id and
         iop.wartosc_data<=cp_data and
         iop.typ_info_kod='PWYS' and
         (d.potwierdzone IN ('T', cp_potwierdzone)) and
         (cp_typ_wyc_kod is NULL OR dn.typ_wyc_kod=cp_typ_wyc_kod) and
         d.typ_dysp_kod=cp_typ_dysp_kod
   order by d.data_wystawienia desc, data_wyc desc; --PT:136798

  cursor c_ksieg_wer5( --PT:46323 - wersja wykorzystujaca daty_naliczen
                       cp_typ_dysp_kod VARCHAR2,
                       cp_portfel_id   PLS_INTEGER,
                       cp_data         DATE,
                       cp_typ_wyc_kod  VARCHAR2) is
   select TRUNC(d.data_wystawienia) data_por,TRUNC(d.data_wystawienia) data_dys,
        dn.portfel_id, dn.typ_wyc_kod, dn.data data_wyc, dn.dysp_id,
        d.data_waluty data_waluty_dysp
   From ort_daty_naliczen dn,
        ort_dyspozycje d
   where (cp_portfel_id is NULL OR dn.portfel_id=cp_portfel_id) and --PT:79875 - dodanie oblsugi portfela nullowego ze wzgl na CU grp por 17948 PAR2
         d.data_wystawienia<=cp_data and
         dn.dysp_id=d.id and
         dn.typ_wyc_kod=cp_typ_wyc_kod and
         d.typ_dysp_kod=cp_typ_dysp_kod
   order by d.data_wystawienia desc, data_wyc desc; --PT:136798

  cursor c_ksieg_wer5_pnull( --PT:46323 - wersja wykorzystujaca daty_naliczen
                       cp_typ_dysp_kod VARCHAR2,
                       cp_data         DATE,
                       cp_typ_wyc_kod  VARCHAR2) is
   select TRUNC(d.data_wystawienia) data_por,TRUNC(d.data_wystawienia) data_dys,
        dn.portfel_id, dn.typ_wyc_kod, dn.data data_wyc, dn.dysp_id,
        d.data_waluty data_waluty_dysp
   From ort_daty_naliczen dn,
        ort_dyspozycje d
   where d.data_wystawienia<=cp_data and
         dn.dysp_id=d.id and
         dn.typ_wyc_kod=cp_typ_wyc_kod and
         d.typ_dysp_kod=cp_typ_dysp_kod
   order by d.data_wystawienia desc, data_wyc desc; --PT:136798

  cursor c_ksieg_wer_B(cp_typ_dysp_kod VARCHAR2,
                       cp_portfel_id   PLS_INTEGER,
                       cp_data         DATE) is
   select
        TRUNC(MAX(d.data_wystawienia) KEEP (DENSE_RANK FIRST ORDER BY d.data_wystawienia desc, dn.data desc)) data_por,
        TRUNC(MAX(d.data_wystawienia) KEEP (DENSE_RANK FIRST ORDER BY d.data_wystawienia desc, dn.data desc)) data_dys,
        (MAX(dn.portfel_id) KEEP (DENSE_RANK FIRST ORDER BY d.data_wystawienia desc, dn.data desc)) portfel_id,
        (MAX(dn.typ_wyc_kod) KEEP (DENSE_RANK FIRST ORDER BY d.data_wystawienia desc, dn.data desc)) typ_wyc_kod,
        (MAX(dn.data) KEEP (DENSE_RANK FIRST ORDER BY d.data_wystawienia desc, dn.data desc)) data_wyc,
        (MAX(dn.dysp_id) KEEP (DENSE_RANK FIRST ORDER BY d.data_wystawienia desc, dn.data desc)) dysp_id,
        (MAX(d.data_waluty) KEEP (DENSE_RANK FIRST ORDER BY d.data_wystawienia desc, dn.data desc)) data_waluty_dysp
   From ortB_daty_naliczen dn,
        ort_dyspozycje d
   where (cp_portfel_id is NULL OR dn.portfel_id=cp_portfel_id) and
         d.data_wystawienia<=cp_data and
         dn.dysp_id=d.id and
         d.typ_dysp_kod=cp_typ_dysp_kod;

  v_daty_REC       c_ksieg%ROWTYPE;
  v_daty_ORTB_REC  c_ksieg%ROWTYPE;
  v_typ_dysp_kod   VARCHAR2(20 CHAR);
  v_salda_potw     VARCHAR2(10 CHAR);
  v_typ_wyc_kod    VARCHAR2(30 CHAR);
  v_pwys           VARCHAR2(2 CHAR);
  vp_typ_dysp_kod  VARCHAR2(200 CHAR);
  vp_typ_portf_kod VARCHAR2(200 CHAR);
  v_pom            VARCHAR2(200 CHAR);
  v_portfel_id     PLS_INTEGER;
 begin

    if  p_typ_dysp_kod is NULL and p_typ_portf_kod is NULL OR
       p_typ_portf_kod='CZYSC_CACHE' then
       g_typ_portf_kod:=''; g_typ_dysp_kod:=''; g_podmiot_id:=''; g_podmiot_id:=''; g_data_portf_par:=NULL;
       g_potwierdzone:='';
       return NULL;
    end if;

    vp_typ_dysp_kod := orw_pck_admin.pobierz_global('NTDKOD'); --PT:132301
    vp_typ_portf_kod := orw_pck_admin.pobierz_global('NTPKOD');

    if vp_typ_dysp_kod is NULL then
      vp_typ_dysp_kod := p_typ_dysp_kod;
    end if;
    if vp_typ_portf_kod is NULL then
      vp_typ_portf_kod := p_typ_portf_kod;
    end if;

    if orw_pck_portfele.g_aktywna_wyc_REC.data_odniesienia is NOT NULL then
      return orw_pck_portfele.g_aktywna_wyc_REC.data_odniesienia; --PT:46323 - global umozliwia wycene portfeli dla grup i portfeli z jednoczesnym odnoszeniem sie do tej samej daty
                                                                  --global jest ustawiany w orw_pck_portfele.wycen_portfel_inw na poczatku wyceny
    end if;
    if p_typ_wyc_kod='_UZYJ_GLOBALA' then
      --MOWA:36382 - podstawiam wartosc parametry typ_wyc_kod przez dynamicznego SQL
      -- a nie bezposrednio bo u Booksa nie ma gloabla g_aktywna_wyc_REC i jest to
      -- konieczne aby u niego ten pakiet sie kompilowal.
      execute immediate
       'begin  :wynik:=orw_pck_portfele.g_aktywna_wyc_REC.typ_wyc_kod; end;'
      using OUT v_typ_wyc_kod;
    elsif p_typ_wyc_kod is NOT NULL then
      v_typ_wyc_kod:=p_typ_wyc_kod;
    end if;

    --sprawdzamy czy nie mamy tych danych w cache
    if NVL(g_typ_portf_kod,'x')=NVL(vp_typ_portf_kod,'x') and
       NVL(g_typ_dysp_kod,'x')=NVL(vp_typ_dysp_kod,'x') and
       p_data=g_data_portf_par and
       NVL(g_podmiot_id,-1)=NVL(p_podmiot_id,-1) and
       NVL(g_typ_wyc_kod,'x')=NVL(v_typ_wyc_kod,'x') and
       NVL(g_potwierdzone,'x')=NVL(p_potwierdzone,'x') then
        p_zrodlo     := g_zrodlo;
        p_wycena_REC := g_wycena_REC;
    return g_data_ks_portf;
    end if;
    g_data_portf_par:=p_data;
    g_typ_portf_kod:=vp_typ_portf_kod;
    g_typ_dysp_kod:=vp_typ_dysp_kod;
    g_podmiot_id:=p_podmiot_id;
    g_typ_wyc_kod:=v_typ_wyc_kod;
    g_potwierdzone:=p_potwierdzone;

    --
    -- sprawdzamy czy ksiegowanie dla tego typu portfela jest potrzebne i jaki jest kod
    -- typu dyspozycji
    --
    begin
       --jesli brak typu dyspozycji to odszukujemy jedno z ksiegowan podpietych do portfela
       if vp_typ_dysp_kod is NULL then
        SELECT typ_dysp_kod
        into v_typ_dysp_kod
        FROM  orv_portfele_dla_dysp
        where tp_kod=vp_typ_portf_kod AND
              rownum=1;
       else
         v_typ_dysp_kod:=vp_typ_dysp_kod;
       end if;
    exception
        when NO_DATA_FOUND then
            -- zadne ksiegowania nie sa potrzebne
            g_data_ks_portf:=NULL;
            return NULL;
    end;
    --
    -- Sprawdzamy kiedy wykonano to ksiegowanie
    --
    v_salda_potw:=NVL(p_potwierdzone, orw_pck_admin.pobierz_global('ORV_SALDA_WSZYSTKIE_DATA_POTWIERDZONE'));

    if p_podmiot_id is NOT NULL then --PT:110276 - ten warunek jest konieczny dla EFOSow
      begin
        select id into v_portfel_id
        from ort_portfele
        where typ_portf_kod=vp_typ_portf_kod and
              podmiot_id=p_podmiot_id;
      exception
        when NO_DATA_FOUND then  --PT:45410
          g_data_ks_portf:=NULL;
          return NULL;
      end;
    end if;

    --PT:167180 - jesli naliczenie nie posiada typu wyceny to nie uwzgl przekazanego typu wyceny - (moze on pochodzi np z globala g_aktywna_wyc_REC.data_odniesienia)
    begin
      SELECT 'T' into v_pom
      from ORT_typy_dla_Typow_info
      where typ_info_kod='PTYWYC' and
            typ_portf_kod= vp_typ_portf_kod;
    exception
     when NO_DATA_FOUND THEN
        v_typ_wyc_kod:='';
    end;

    begin
      SELECT 'T' into v_pwys
      from ORT_typy_dla_Typow_info
      where typ_info_kod='PWYS' and
            typ_portf_kod= vp_typ_portf_kod;
    exception
     when NO_DATA_FOUND THEN
        v_pwys:='N';
    end;
    if orw_pck_admin.g_platforma>=4 then --PT:46323
      if v_pwys='T' then
        if v_portfel_id is NOT NULL then --PT:92634
          open  c_ksieg_pwys_platf4(v_typ_dysp_kod,v_salda_potw,v_portfel_id,TRUNC(p_data), v_typ_wyc_kod); --PT:115234 - naprawa kolejnosci parametrow
          fetch c_ksieg_pwys_platf4 into v_daty_REC;
          close c_ksieg_pwys_platf4;
        else
          open  c_ksieg_pwys_platf4_pnull(v_typ_dysp_kod,v_salda_potw, TRUNC(p_data), v_typ_wyc_kod); --PT:115234 - naprawa kolejnosci parametrow
          fetch c_ksieg_pwys_platf4_pnull into v_daty_REC;
          close c_ksieg_pwys_platf4_pnull;
        end if;
      elsif v_typ_wyc_kod is NULL then
        if v_salda_potw='T' then
          if v_portfel_id is NOT NULL then --PT:92634
            open  c_ksieg_wer4potw(v_typ_dysp_kod,v_portfel_id, TRUNC(p_data)+1-1/24/60/60); --dzieki temu dzialaniu nie trzeba robic TRUNC w selekcie
            fetch c_ksieg_wer4potw into v_daty_REC;
            close c_ksieg_wer4potw;
          else
            open  c_ksieg_wer4potw_pnull(v_typ_dysp_kod, TRUNC(p_data)+1-1/24/60/60); --dzieki temu dzialaniu nie trzeba robic TRUNC w selekcie
            fetch c_ksieg_wer4potw_pnull into v_daty_REC;
            close c_ksieg_wer4potw_pnull;
          end if;
        else
          if v_portfel_id is NOT NULL then --PT:92634
            open  c_ksieg_wer4(v_typ_dysp_kod,v_portfel_id, TRUNC(p_data)+1-1/24/60/60); --dzieki temu dzialaniu nie trzeba robic TRUNC w selekcie
            fetch c_ksieg_wer4 into v_daty_REC;
            close c_ksieg_wer4;
          else
            open  c_ksieg_wer4_pnull(v_typ_dysp_kod, TRUNC(p_data)+1-1/24/60/60); --dzieki temu dzialaniu nie trzeba robic TRUNC w selekcie
            fetch c_ksieg_wer4_pnull into v_daty_REC;
            close c_ksieg_wer4_pnull;
          end if;
        end if;
      else
        if v_salda_potw='T' then
          if v_portfel_id is NOT NULL then --PT:92634
            open  c_ksieg_wer5potw(v_typ_dysp_kod,v_portfel_id, TRUNC(p_data)+1-1/24/60/60,
               v_typ_wyc_kod); --dzieki temu dzialaniu nie trzeba robic TRUNC w selekcie
            fetch c_ksieg_wer5potw into v_daty_REC;
            close c_ksieg_wer5potw;
          else
            open  c_ksieg_wer5potw_pnull(v_typ_dysp_kod, TRUNC(p_data)+1-1/24/60/60,
               v_typ_wyc_kod); --dzieki temu dzialaniu nie trzeba robic TRUNC w selekcie
            fetch c_ksieg_wer5potw_pnull into v_daty_REC;
            close c_ksieg_wer5potw_pnull;
          end if;
        else
          if v_portfel_id is NOT NULL then --PT:92634
            open  c_ksieg_wer5(v_typ_dysp_kod,v_portfel_id, TRUNC(p_data)+1-1/24/60/60,
               v_typ_wyc_kod); --dzieki temu dzialaniu nie trzeba robic TRUNC w selekcie
            fetch c_ksieg_wer5 into v_daty_REC;
            close c_ksieg_wer5;
          else
            open  c_ksieg_wer5_pnull(v_typ_dysp_kod, TRUNC(p_data)+1-1/24/60/60,
               v_typ_wyc_kod); --dzieki temu dzialaniu nie trzeba robic TRUNC w selekcie
            fetch c_ksieg_wer5_pnull into v_daty_REC;
            close c_ksieg_wer5_pnull;
          end if;
        end if;
      end if;
    else
      if v_pwys='T' then
        open  c_ksieg(v_typ_dysp_kod,v_salda_potw,v_portfel_id, v_typ_wyc_kod, TRUNC(p_data));
        fetch c_ksieg into v_daty_REC;
        close c_ksieg;
      elsif v_typ_wyc_kod is NULL and orw_pck_admin.pobierz_global('TINS')='PORTFEL' then --PT:46003 - wersja dla apl. portfel (przyspieszanie ING)
        open  c_ksieg_wer3(v_typ_dysp_kod,v_portfel_id, TRUNC(p_data)+1-1/24/60/60,
                           p_podmiot_id); --dzieki temu dzialaniu nie trzeba robic TRUNC w selekcie PT:44284
        fetch c_ksieg_wer3 into v_daty_REC;
        close c_ksieg_wer3;
      else --PT:42273 - uproszczona wersja zapytania w celu przyspieszenia
        open  c_ksieg_wer2(v_typ_dysp_kod,v_salda_potw,v_portfel_id, v_typ_wyc_kod, TRUNC(p_data)+1-1/24/60/60); --dzieki temu dzialaniu nie trzeba robic TRUNC w selekcie PT:44284
        fetch c_ksieg_wer2 into v_daty_REC;
        close c_ksieg_wer2;
      end if;
    end if;

    if orw_pck_portfele.naliczenie_posiada_info(vp_typ_portf_kod,'TABB')  and
        (NVL(v_daty_REC.data_por, v_daty_REC.data_dys)<TRUNC(p_data) OR v_daty_REC.data_dys is NULL) then --PT:241260
      open  c_ksieg_wer_B(v_typ_dysp_kod, v_portfel_id, TRUNC(p_data)+1-1/24/60/60);
      fetch c_ksieg_wer_B into v_daty_ORTB_REC;
      close c_ksieg_wer_B;
      if NVL(NVL(v_daty_REC.data_por, v_daty_REC.data_dys), TO_DATE('0001/01/01','yyyy/mm/dd'))<NVL(v_daty_ORTB_REC.data_por, v_daty_ORTB_REC.data_dys) then
        v_daty_REC:=v_daty_ORTB_REC;
      end if;
    end if;

    g_data_ks_portf := NVL(v_daty_REC.data_por, v_daty_REC.data_dys);
    p_wycena_REC.data_wyc    := v_daty_REC.data_wyc; --MOWA:33793
    p_wycena_REC.portfel_id  := v_daty_REC.portfel_id;
    p_wycena_REC.typ_wyc_kod := v_daty_REC.typ_wyc_kod;
    p_wycena_REC.dysp_id     := v_daty_REC.dysp_id;
    p_wycena_REC.data_waluty_dysp := v_daty_REC.data_waluty_dysp;
    p_wycena_REC.data_ks     := g_data_ks_portf;
    g_wycena_REC:=p_wycena_REC;

    if v_daty_REC.data_por is NULL then
      p_zrodlo:='K';
    else
      p_zrodlo:='W';
    end if;
    p_zrodlo:=p_zrodlo;
    return g_data_ks_portf;
 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ost_ksieg_portfela('||p_typ_portf_kod||','||p_typ_dysp_kod||','||TO_CHAR(p_data,'dd/mm/yyyy')||','||
                      p_podmiot_id||',OUT, OUT, '||p_typ_wyc_kod||'->'||v_typ_wyc_kod||') - '||vp_typ_dysp_kod||';'||vp_typ_portf_kod);
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.ost_ksieg_portfela('||p_typ_portf_kod||','||p_typ_dysp_kod||','||TO_CHAR(p_data,'dd/mm/yyyy')||','||
                      p_podmiot_id||',OUT, OUT, '||p_typ_wyc_kod||'->'||v_typ_wyc_kod||') - '||vp_typ_dysp_kod||';'||vp_typ_portf_kod);
 end;


 ------------------------------------------------------------------------------
 -- Funkcja zwraca date naliczenia ksiegowanego wg zadanych parametrow
 --  p_typ_portf_kod - typ portfela
 --  p_typ_dysp_kod  - typ dyspozycji
 --  p_data      - data maksymalna ksiegowan
 --  p_podmiot_id - wlasciciel portfela
 --  p_typ_wyc_kod - typ wyceny dla ktorego zrobiono ksiegowanie
 --  p_potwierdzone - czy szukac tylko dysp potwierdzonych (T) czy wszystkich (N)
 -- Zwraca rekord typu T_Ksiegowany_Portfel_REC zawierajacy namiary zaksiegowanej
 -- wyceny.
 ----------------------------------------------------------------------------------------
 function ost_nal_ksiegowane(
 ------------------------------------------
                  p_typ_portf_kod     VARCHAR2,
                  p_typ_dysp_kod      VARCHAR2,
                  p_data              DATE,
                  p_podmiot_id        NUMBER,
                  p_typ_wyc_kod       VARCHAR2 DEFAULT '_UZYJ_GLOBALA',
                  p_potwierdzone      VARCHAR2 DEFAULT NULL --PT:181879
                )
 return T_Ksiegowany_Portfel_REC
 is
   v_wycena_REC  T_Ksiegowany_Portfel_REC;
   v_tmp         DATE;
   v_zrodlo      VARCHAR2(200 CHAR);
   v_typ_wyc_kod VARCHAR2(50 CHAR);
 begin
   if p_typ_wyc_kod='_UZYJ_GLOBALA' then
     --MOWA:36382 - podstawiam wartosc parametry typ_wyc_kod przez dynamicznego SQL
     -- a nie bezposrednio bo u Booksa nie ma gloabla g_aktywna_wyc_REC i jest to
     -- konieczne aby u niego ten pakiet sie kompilowal.
     execute immediate
      'begin  :wynik:=orw_pck_portfele.g_aktywna_wyc_REC.typ_wyc_kod; end;'
     using OUT v_typ_wyc_kod;
   elsif p_typ_wyc_kod is NOT NULL then
     v_typ_wyc_kod:=p_typ_wyc_kod;
   end if;
   v_tmp:=ost_ksieg_portfela(
                  p_typ_portf_kod,
                  p_typ_dysp_kod,
                  p_data,
                  p_podmiot_id,
                  v_zrodlo,
                  v_wycena_REC,
                  v_typ_wyc_kod,
                  p_potwierdzone
                );
    return  v_wycena_REC;
 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ost_nal_ksiegowane('||p_typ_portf_kod||','||p_typ_dysp_kod||','||TO_CHAR(p_data,'dd/mm/yyyy')||','||
                      p_podmiot_id||', '||p_typ_wyc_kod||'->'||v_typ_wyc_kod||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.ost_nal_ksiegowane('||p_typ_portf_kod||','||p_typ_dysp_kod||','||TO_CHAR(p_data,'dd/mm/yyyy')||','||
                      p_podmiot_id||', '||p_typ_wyc_kod||')');
 end;

 function ost_nal_ksiegowane_data_wyc(
 ------------------------------------------
                  p_typ_portf_kod     VARCHAR2,
                  p_typ_dysp_kod      VARCHAR2,
                  p_data              DATE,
                  p_podmiot_id        NUMBER,
                  p_typ_wyc_kod       VARCHAR2 DEFAULT '_UZYJ_GLOBALA' -- przerobione na _UZYJ_GLOBALA dla MOWA:36328
                )
 return DATE
 is
   v_wyn         T_Ksiegowany_Portfel_REC;
   v_typ_wyc_kod VARCHAR2(50 CHAR);
 begin
   if p_typ_wyc_kod='_UZYJ_GLOBALA' then
     --MOWA:36382 - podstawiam wartosc parametry typ_wyc_kod przez dynamicznego SQL
     -- a nie bezposrednio bo u Booksa nie ma gloabla g_aktywna_wyc_REC i jest to
     -- konieczne aby u niego ten pakiet sie kompilowal.
     execute immediate
      'begin  :wynik:=orw_pck_portfele.g_aktywna_wyc_REC.typ_wyc_kod; end;'
     using OUT v_typ_wyc_kod;
   elsif p_typ_wyc_kod is NOT NULL then
     v_typ_wyc_kod:=p_typ_wyc_kod;
   end if;
   v_wyn:=ost_nal_ksiegowane(p_typ_portf_kod,p_typ_dysp_kod,p_data,p_podmiot_id,v_typ_wyc_kod,'');
   return v_wyn.data_wyc;
 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ost_nal_ksiegowane_data_wyc('||p_typ_portf_kod||','||p_typ_dysp_kod||','||TO_CHAR(p_data,'dd/mm/yyyy')||','||
                      p_podmiot_id||', '||p_typ_wyc_kod||'->'||v_typ_wyc_kod||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.ost_nal_ksiegowane_data_wyc('||p_typ_portf_kod||','||p_typ_dysp_kod||','||TO_CHAR(p_data,'dd/mm/yyyy')||','||
                      p_podmiot_id||', '||p_typ_wyc_kod||'->'||v_typ_wyc_kod||')');
 end;


  function wew_czy_byl_split_na_koncie(
  --------------------------------------
          pp_symbol   VARCHAR2,
          pp_data_od  DATE,
          pp_data_do  DATE)
  return VARCHAR is
    vv_tmp    NUMBER;
  begin
    if pp_symbol is NULL then
      return 'T';
    end if;

    if g_data_ost_spl_kon_asm is NULL then
      select max(data_waluty) into g_data_ost_spl_kon_asm
      From ort_dyspozycje
      where typ_dysp_kod IN ('AINAD','KINKD','SINSD') and
            dysp_anul_id is NULL;
    end if;

    if g_data_ost_spl_kon_asm is NULL then
      --orw_pck_bledy.zglos('blad_wewnetrzny','l=1262');
      g_data_ost_spl_kon_asm:=TO_DATE('0001/01/01','yyyy/mm/dd');
      return 'N';
    end if;

    if g_data_ost_spl_kon_asm>=pp_data_od then
      --sprawdzenie czy split dotyczy papieru z aktualnie przetwarzanego konta
      select /*+ ORDERED FIRST_ROWS*/ 1 into vv_tmp
      From ort_dyspozycje d,
           ort_info_o_dyspozycjach iod
      where typ_dysp_kod IN ('AINAD','KINKD','SINSD') and
            data_waluty >= pp_data_od and data_waluty <= pp_data_do and
            dysp_anul_id is NULL and
            d.id=iod.dysp_id and
            iod.typ_info_kod IN ('KODPN','KODP')  and
            pp_symbol like '%'||iod.wartosc||'%' and
            rownum=1;
      return 'T';
    end if;
    return 'N';
  exception
    when NO_DATA_FOUND then
        return 'N';
  end;


 ------------------------------------------------------------------------------
 -- Funkcja zwraca wartosc ksiegowan, ktore zostana wykonane przez ksiegowania
 -- nierozliczone po podanej dacie
 --  p_konto_id - konto ktorego ksiegowania sprawdzamy
 --  p_data     - data po ktorej wybieramy ksiegowania nierozliczone
 -- Zwraca sume ksiegowan na konto
 ------------------------------------------------------------------------------
 function ksieg_nieroz_data(
 ---------------------------
    p_konto_id           NUMBER,
    p_data	             DATE,
    p_przyszle_dozwolone VARCHAR2,
    p_uwzg_split_konw    VARCHAR2 DEFAULT 'N', --PT:46418, 47625
    p_symbol             VARCHAR2 DEFAULT NULL --PT:126797
  )
 return NUMBER is
   cursor c_dysp_nierozliczone(
              cp_konto_id NUMBER,
              cp_data DATE,
              cp_przyszle_dozwolone VARCHAR2) is
     select /*+ ORDERED*/
            DECODE(strona,'MA',-ks1.kwota,+ks1.kwota) kwota,
            d.data_waluty, d.data_waluty_transakcji,
            d.typ_dysp_kod
     from ort_ksiegowania ks1,
          ort_operacje_ksiegowania ok1,
          ort_dyspozycje d,
--          ort_info_o_dyspozycjach iod,
          ort_dyspozycje dr
     where ok1.id=ks1.oper_ks_id
       and ks1.konto_id =cp_konto_id
       and d.dysp_real_id=dr.id(+)
       and (dr.data_waluty>cp_data or dr.data_waluty is null OR
              dr.potwierdzone is NULL or dr.potwierdzone='N') --PT:161579
       and d.id=ok1.dyspozycja_id
       and not exists  (SELECT typ_dysp_kod FROM ORS_KONFIG_MENU  WHERE operacja_kod IN ('EWIDANP','DFANLOP') and typ_dysp_kod=d.typ_dysp_kod) -- nie anulujaca
       and d.dysp_anul_id is NULL  --PT:83090
       and d.typ_dysp_kod not in ('KINKD','WYKD', --konwersja
             'AINAD','SINSD','RINRD', --asymilacja, split, reczne ksiegowanie
             'KINPD',  --kupno na rynku pierwotnym sybskr.
             'KINPP',  --Kupno z wykorzystaniem prawa poboru
             'NPPAD',  --Nabycie praw poboru/Przydzielenie praw poboru
             'UPPAD',  --Umorzenie praw poboru
             'WKPPD',  --Wykonanie praw poboru
             'KWOSS',  --MOWA:25866
             'SPINOFF')
       and (cp_przyszle_dozwolone='T' or d.data_waluty<=cp_data);--badanie przyszylch ze wzgledu na ujednolicenie metod ILKUBR i WANOR przy okazji MOWA:29294

   cursor c_dysp_niepotwierdzone(
              cp_konto_id NUMBER,
              cp_data DATE,
              cp_przyszle_dozwolone VARCHAR2) is
     select DECODE(sd.strona,'MA',-TO_NUMBER(SD.wartosc, J.format),
                +TO_NUMBER(SD.wartosc, J.format)) kwota,
            d.data_waluty, d.data_waluty_transakcji,
            d.typ_dysp_kod
     from ort_konta k,
          ort_skladowe_dyspozycji SD,
          ort_operacje_na_zdarzeniach ONZ,
          ort_dyspozycje D,
          ort_analityki_kont AK,
          ort_jednostki J,
          ort_info_o_dyspozycjach IOD
     where d.dysp_anul_id is NULL --nie anulowana  --PT:83090
       and not exists  (SELECT typ_dysp_kod FROM ORS_KONFIG_MENU  WHERE operacja_kod IN ('EWIDANP','DFANLOP') and typ_dysp_kod=d.typ_dysp_kod) -- nie anulujaca
       and sd.inf_o_oper_zd_id=onz.id
       and ak.id=sd.anal_knt_id
       and j.kod=ak.jednostka_kod
       and d.potwierdzone='N'
       and d.id=onz.dysp_id
       and k.id=cp_konto_id
       and k.symbol=sd.konto
       and iod.dysp_id(+)=d.id
       and iod.typ_info_kod(+)='DREA'
       and iod.wartosc is null
       and d.typ_dysp_kod not in ('KINKD','WYKD', --konwersja
             'AINAD','SINSD','RINRD', --asymilacja, split, reczne ksiegowanie
             'KINPD',  --kupno na rynku pierwotnym sybskr.
             'KINPP',  --Kupno z wykorzystaniem prawa poboru
             'NPPAD',  --Nabycie praw poboru/Przydzielenie praw poboru
             'UPPAD',  --Umorzenie praw poboru
             'WKPPD', --Wykonanie praw poboru
             'KWOSS')
       and (cp_przyszle_dozwolone='T' OR d.data_waluty<=cp_data);

    cursor c_split_konw_asym(
               cp_konto_id NUMBER,
               cp_data_od  DATE,
               cp_data_do  DATE) is
      select /*+ ORDERED */
             iod.wartosc_liczba stosun, d.typ_dysp_kod
      from ort_konta k,
           ort_zaleznosci_pw zpw,
           ort_dyspozycje d,
           ort_info_o_dyspozycjach iod_kodp,
           ort_info_o_dyspozycjach iod,
           ort_papiery_wartosciowe pw
      where k.id=cp_konto_id
        and zpw.pw_id=k.pw_id
        and d.typ_dysp_kod in ('AINAD','KINKD','SINSD')
        and ((k.podmiot_id is null) or
             (k.podmiot_id is not null and d.wlasciciel_id=k.podmiot_id))
        and d.data_waluty >= cp_data_od and d.data_waluty <= cp_data_do
        and d.dysp_anul_id is NULL  --PT:83090
        and iod_kodp.typ_info_kod='KODP'
        and iod_kodp.dysp_id=d.id
        and iod_kodp.wartosc=pw.kod
        and pw.id=zpw.pw_id_zalezec_od
        and iod.typ_info_kod='STOSUN'
        and iod.dysp_id=d.id
      order by typ_dysp_kod;

  v_saldo                 NUMBER:=0;
  v_pom                   NUMBER:=0;
  v_dysp_niepotwierdzone  NUMBER:=0;
  v_stosun                NUMBER;
  v_split_konw_asym_rec   c_split_konw_asym%rowtype;

 begin
   --dyspozycje nierozliczone
   for v_REC in c_dysp_nierozliczone(p_konto_id,p_data,p_przyszle_dozwolone)
   loop
     if p_uwzg_split_konw='T' and v_REC.typ_dysp_kod='SINWD' and
        wew_czy_byl_split_na_koncie(p_Symbol, v_REC.data_waluty+1, v_REC.data_waluty_transakcji)='T' then --PT:126797 splity, kowersje, asym. robi sie rzadko, wiec warto wczesniej sprawdzic czy trzeba to wykonac
       open c_split_konw_asym(p_konto_id,v_REC.data_waluty+1,v_REC.data_waluty_transakcji);
       fetch c_split_konw_asym into v_split_konw_asym_rec;

       if c_split_konw_asym%notfound then
         v_stosun:=1;
       else
         if v_split_konw_asym_rec.typ_dysp_kod='SINSD' then
           v_stosun:=v_split_konw_asym_rec.stosun;
         else
           v_stosun:=0;
         end if;
       end if;
       close c_split_konw_asym;
       --PT:46418 - jesli pomiedzy data sprzedazy a data rozliczenia wystapil split
       --to ilosc ze sprzedazy mnozona przez stosunek splitu
       v_pom:=v_pom+v_stosun*v_REC.kwota;
     else
       v_pom:=v_pom+v_REC.kwota;
     end if;
   end loop;

    --dyspozycje nierozliczone i niepotweirdzone
   if Orw_Pck_admin.pobierz_global('ORV_SALDA_WSZYSTKIE_DATA_POTWIERDZONE')='N' THEN --MOWA:29294
     for v_REC in c_dysp_niepotwierdzone(p_konto_id,p_data,p_przyszle_dozwolone)
     loop
       if p_uwzg_split_konw='T' and v_REC.typ_dysp_kod='SINWD' and
          wew_czy_byl_split_na_koncie(p_Symbol, v_REC.data_waluty+1, v_REC.data_waluty_transakcji)='T' then --PT:126797 splity, kowersje, asym. robi sie rzadko, wiec warto wczesniej sprawdzic czy trzeba to wykonac
         open c_split_konw_asym(p_konto_id,v_REC.data_waluty+1,v_REC.data_waluty_transakcji);
         fetch c_split_konw_asym into v_split_konw_asym_rec;

         if c_split_konw_asym%notfound then
           v_stosun:=1;
         else
           if v_split_konw_asym_rec.typ_dysp_kod='SINSD' then
             v_stosun:=v_split_konw_asym_rec.stosun;
           else
             v_stosun:=0;
           end if;
         end if;
         close c_split_konw_asym;
         --PT:46418 - jesli pomiedzy data sprzedazy a data rozliczenia wystapil split
         --to ilosc ze sprzedazy mnozona przez stosunek splitu
         v_dysp_niepotwierdzone:=v_dysp_niepotwierdzone+v_stosun*v_REC.kwota;
       else
         v_dysp_niepotwierdzone:=v_dysp_niepotwierdzone+v_REC.kwota;
       end if;
     end loop;
   end if;
   return v_saldo+v_pom+v_dysp_niepotwierdzone;
 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ksieg_nieroz_data ('||p_konto_id||','||TO_CHAR(p_data,'dd/mm/yyyy')||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.ksieg_nieroz_data ('||p_konto_id||','||TO_CHAR(p_data,'dd/mm/yyyy')||')');
 end;

------------------------------------------------------------------------------
 -- Funkcja zwraca saldo nierozliczonych transakcji sprzedazy papieru
 -- przed konwersja/asymilacja dla papierow z konwersji/asymilacji
 --  p_konto_id - konto ktorego ksiegowania sprawdzamy
 --  p_data     - data wg ktorej wybieramy ksiegowania nierozliczone
 ------------------------------------------------------------------------------
 function ksieg_nieroz_pw_konw_asym(
 -----------------------------------
			   p_konto_id NUMBER,
			   p_data	    DATE,
         p_symbol   VARCHAR2)
 return NUMBER is
   cursor c_konw_asym(cp_konto_id NUMBER) is
     select
            knt_p.id konto_id,
            d.data_waluty,
            iod_stosun.wartosc_liczba stosun
     from ort_konta knt,
          ort_papiery_wartosciowe pw,
          ort_info_o_pw ipw_kodnast,
          ort_konta knt_p,
          ort_zaleznosci_pw zpw,
          ort_papiery_wartosciowe pw_p,
          ort_info_o_dyspozycjach iod_kodp,
          ort_dyspozycje d,
          ort_info_o_dyspozycjach iod_stosun
     where knt.id=cp_konto_id
       and pw.id=knt.pw_id
       and ipw_kodnast.typ_info_kod='KODNAST'
       and ipw_kodnast.wartosc=pw.kod
       and knt_p.pw_id=ipw_kodnast.pw_id
       and knt_p.anal_knt_id=knt.anal_knt_id
       and zpw.pw_id=knt_p.pw_id
       and pw_p.id=zpw.pw_id_zalezec_od
       and iod_kodp.typ_info_kod='KODP'
       and iod_kodp.wartosc=pw_p.kod
       and d.typ_dysp_kod in ('AINAD','KINKD')
       and d.id=iod_kodp.dysp_id
       and d.dysp_anul_id is NULL
       and d.potwierdzone='T'
       and (knt_p.podmiot_id is null or d.wlasciciel_id=knt_p.podmiot_id)
       and iod_stosun.typ_info_kod='STOSUN'
       and iod_stosun.dysp_id=d.id
       and d.data_waluty<=p_data;

   v_saldo         NUMBER:=0;
   v_konw_asym_rec c_konw_asym%rowtype;
 begin
   if wew_czy_byl_split_na_koncie(p_Symbol, p_data-7, p_data)='T' then --PT:134991 - sprawdzam czy w ciagku ostatnich 7 dni (ustalone z K. Saborem) byla konw/asymilacja bo dalsze zapytania sa b. wolne
     open c_konw_asym(p_konto_id);
     fetch c_konw_asym into v_konw_asym_rec;

     if c_konw_asym%notfound then
       v_saldo:=0;
     else
       select /*+ ORDERED USE_NL(ks1 ok1) USE_NL(ok1 d) USE_NL(d iod)*/
              v_konw_asym_rec.stosun*
              NVL(SUM(DECODE(strona,'MA',-ks1.kwota,+ks1.kwota)),0) kwota
       into v_saldo
       from ort_ksiegowania ks1,
            ort_operacje_ksiegowania ok1,
            ort_dyspozycje d,
            ort_info_o_dyspozycjach iod
       where ks1.konto_id=v_konw_asym_rec.konto_id
         and ok1.id=ks1.oper_ks_id
         and iod.dysp_id(+)=ok1.dyspozycja_id
         and iod.typ_info_kod(+)='DREA'
         and iod.wartosc is null
         and d.id=ok1.dyspozycja_id
         and d.typ_dysp_kod='SINWD'
         and not exists  (SELECT typ_dysp_kod FROM ORS_KONFIG_MENU  WHERE operacja_kod IN ('EWIDANP','DFANLOP') and typ_dysp_kod=d.typ_dysp_kod) -- nie anulujaca
         and d.dysp_anul_id is NULL
         and d.data_waluty<=p_data
         and d.data_waluty<v_konw_asym_rec.data_waluty
         and d.data_waluty_transakcji>=v_konw_asym_rec.data_waluty;
     end if;
     close c_konw_asym;
   end if;
   return v_saldo;
 exception
   when orw_pck_bledy.blad then
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ksieg_nieroz_pw_konw_asym ('||p_konto_id||','||TO_CHAR(p_data,'dd/mm/yyyy')||')');
   when OTHERS then
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.ksieg_nieroz_pw_konw_asym ('||p_konto_id||','||TO_CHAR(p_data,'dd/mm/yyyy')||')');
 end;


 ------------------------------------------------------------------------------
 -- Funkcja zwraca kod podanego PW sklejony z nazwa instrumentu. Uzywana
 -- przy obsludze bledow
 --  p_pw_id - id papieru
 ------------------------------------------------------------------------------
 function daj_opis_pw(p_pw_id NUMBER)
 ------------------------------------
 return VARCHAR2 is
  v_wynik VARCHAR2(500 CHAR);
 begin
   if orw_pck_admin.g_typ_symulacji is NULL then --PT:39158
     SELECT kod||' ('|| i.opis||')' INTO v_wynik
     FROM ort_papiery_wartosciowe pw,
          ort_instrumenty i
     WHERE pw.id=p_pw_id AND
           pw.instrument_id=i.id;
   else
     begin
       SELECT kod||' ('|| i.opis||')' INTO v_wynik
       FROM ort_papiery_wartosciowe pw,
            ort_instrumenty i
       WHERE pw.id=p_pw_id AND
             pw.instrument_id=i.id;
     exception
       when NO_DATA_FOUND then
         SELECT 'SYM-'||pwkod.kod||'-'||p_pw_id||' ('|| i.opis||')' INTO v_wynik
         FROM orv_sym_pw pw,
              ort_instrumenty i,
              ort_papiery_Wartosciowe pwkod
         WHERE pw.id=p_pw_id AND
               pw.instrument_id=i.id and
               pw.krotki_pw=pwkod.id;
     end;
   end if;
   RETURN v_wynik;
 exception
   WHEN NO_DATA_FOUND then
      return '?PW='||p_pw_id||'?';
   WHEN OTHERS THEN
      return '*PW='||p_pw_id||'*';
 end;

 function daj_opis_kontrahenta(p_kontrahent_id NUMBER)
 -----------------------------------------------------
 return VARCHAR2 is
  v_wynik VARCHAR2(500 CHAR);
 begin
    select nazwa into v_wynik
    From orv_podmioty_rach_dep_kontr
    where kontr_id=p_kontrahent_id;
    return v_wynik;
 exception
   WHEN NO_DATA_FOUND then
      return '?KONTR='||p_kontrahent_id||'?';
   WHEN OTHERS THEN
      return '*KONTR='||p_kontrahent_id||'*';
 end;

 function daj_opis_rachunku(
 ----------------------------
    p_rachunek_id     NUMBER,
    p_podmiot_id      NUMBER  DEFAULT NULL)
 return VARCHAR2 is
  v_wynik VARCHAR2(500 CHAR);
 begin
    select nazwa into v_wynik
    From orv_podmioty_rach_dep_kontr
    where (rachunek_id=p_rachunek_id or podmiot_id=p_podmiot_id);
    return v_wynik;
 exception
   WHEN NO_DATA_FOUND then
      return '?RACH='||p_rachunek_id||'?';
   WHEN OTHERS THEN
      return '*RACH='||p_rachunek_id||'*';
 end;

 function saldo_dla_syntetyki(
 ------------------------------
            p_data          DATE,
            p_symbol_like   VARCHAR2,
            p_pw_id         NUMBER,
            p_lista_podm    VARCHAR2 default NULL,
            p_konto_ba_id   PLS_INTEGER default NULL,
            p_typ_wyc_kod   VARCHAR2 default NULL,
            p_krotki_pw     VARCHAR2 default 'N' )
 return NUMBER is
  v_konto_id     NUMBER;
  v_anal_knt_id  NUMBER;
  v_saldo        NUMBER;
  v_typ_wyc_kod  VARCHAR2(30 CHAR);
  v_pw_id        PLS_INTEGER;
  v_symbol_like  VARCHAR2(200 CHAR);
  v_kod_pw       VARCHAR2(200 CHAR);
  v_wynik        NUMBER;
  v_klucz        VARCHAR2(2000 CHAR);
  v_tw_kod       VARCHAR2(200 CHAR);
 begin
   if g_saldo_dla_syntetyki_cache='T' then
     begin
       v_klucz:=p_krotki_pw||'@'||p_symbol_like||'@'||p_pw_id||'@'||p_typ_wyc_kod||'@'||p_konto_ba_id||'@'||p_lista_podm||'@'||TO_CHAR(p_data,'dd/mm/yyyy');
       v_wynik:=orw_pck_oracle_wersje.CACHE_CZYTAJ('SDSYN',v_klucz);
       return v_wynik;
     exception
       when NO_DATA_FOUND then
         null; --trzeba to odczytac
     end;
   end if;
   begin

     if p_pw_id is NOT NULL and p_krotki_pw='T' then --PT:39158
       v_pw_id:=orw_pck_uzytki_des04.krotki_pw(p_pw_id);
       begin
         select kod into v_kod_pw
         from ort_papiery_wartosciowe
         where id=v_pw_id;
       exception
         when others then
           orw_pck_bledy.zglos('blad_wewnetrzny','l=921');
       end;
       v_symbol_like:=p_symbol_like||'%'||v_kod_pw||'%';
     else
       v_symbol_like:=p_symbol_like;
     end if;

     if p_krotki_pw='SUM_ALL' then --PT:181982
        EXECUTE IMMEDIATE
          'select NVL(SUM(s.saldo_ma-s.saldo_wn),0),max(anal_knt_id) anal_knt_id
          from orv_salda_wszystkie_data s
          where s.data=:data and '||
                'symbol like :symbol_like'
        INTO v_saldo,v_anal_knt_id
        USING p_data,v_symbol_like;
        if v_anal_knt_id is NOT NULL and v_saldo<>0 then
          v_wynik:= v_saldo*Orw_Pck_Operpom2.znak_analityki(v_anal_knt_id);
        end if;
     elsif p_lista_podm is NULL and p_krotki_pw='N' then
       if p_pw_id is NOT NULL then
         begin
         select /*+ INDEX(k KONTO_PW_FK_I)*/ k.id, k.anal_knt_id --PT:223771 - zwykle p_pw_id to paczka a p_symbol_like to pocz¹tek konta i jest ma³o selektywny; dlatego wymuszam korzystanie z indeksu na PW
         into v_konto_id, v_anal_knt_id
         from ort_konta k
         where k.symbol like p_symbol_like and
               k.pw_id=p_pw_id;
         exception
           when too_many_rows then
            --orw_pck_automat.info('paw'||p_symbol_like||';'||orw_pck_admin.pobierz_global('TYP_WYC_KOD'));
            v_tw_kod:=orw_pck_admin.pobierz_global('TYP_WYC_KOD');
            if v_tw_kod is NOT NULL then
              select /*+ INDEX(k KONTO_PW_FK_I)*/ k.id, k.anal_knt_id --PT:223771
              into v_konto_id, v_anal_knt_id
              from ort_konta k
              where k.symbol like p_symbol_like and
                    k.pw_id=p_pw_id and
                    k.typ_wyc_kod =v_tw_kod;
            else --PT:152698
              EXECUTE IMMEDIATE
                'select NVL(SUM(s.saldo_ma-s.saldo_wn),0),max(anal_knt_id) anal_knt_id
                from orv_salda_wszystkie_data s
                where s.data=:data and '||
                      'symbol like :symbol_like and '||
                       's.PW_ID=:pw_id'
              INTO v_saldo,v_anal_knt_id
              USING p_data,v_symbol_like, p_pw_id;
              if v_anal_knt_id is NOT NULL and v_saldo<>0 then
                v_wynik:= v_saldo*Orw_Pck_Operpom2.znak_analityki(v_anal_knt_id);
              else
                v_wynik:= 0;
              end if;
            end if;
         end;
       elsif p_konto_ba_id is NOT NULL then
         select k.id, k.anal_knt_id
         into v_konto_id, v_anal_knt_id
         from ort_konta k
         where k.symbol like p_symbol_like and
              k.konta_ba_id=p_konto_ba_id;
       else
         select k.id, k.anal_knt_id
         into v_konto_id, v_anal_knt_id
         from ort_konta k
         where k.symbol like p_symbol_like;
       end if;

       if v_wynik is NULL then
         v_wynik:= orw_pck_uzytki_des04.saldo_na_dzien(v_konto_id,p_data)*
           orw_pck_operpom2.znak_analityki(v_anal_knt_id);
       end if;
     elsif p_lista_podm = '(<tab>)' then
        select NVL(SUM(s.saldo_ma-s.saldo_wn),0),max(anal_knt_id) anal_knt_id
        INTO v_saldo,v_anal_knt_id
        from orv_salda_wszystkie_data s
        where s.data=p_data and
              symbol like v_symbol_like and
             (podmiot_id is NULL OR
               podmiot_id IN
                 (select liczba01 from ORT_BUFORY_01_OCPR where kod='PODMIOT_ID')) AND
             (p_krotki_pw='T' OR s.PW_ID=p_pw_id);
        if v_anal_knt_id is NOT NULL and v_saldo<>0 then
          v_wynik:= v_saldo*Orw_Pck_Operpom2.znak_analityki(v_anal_knt_id);
        else
          v_wynik:= 0;
        end if;
     else
        EXECUTE IMMEDIATE
          'select NVL(SUM(s.saldo_ma-s.saldo_wn),0),max(anal_knt_id) anal_knt_id
          from orv_salda_wszystkie_data s
          where s.data=:data and '||
                'symbol like :symbol_like and '||
                '(podmiot_id is NULL OR podmiot_id IN '||p_lista_podm||') and '||
                 '(:krotki=''T'' OR s.PW_ID=:pw_id)'
        INTO v_saldo,v_anal_knt_id
        USING p_data,v_symbol_like,p_krotki_pw, p_pw_id;
        if v_anal_knt_id is NOT NULL and v_saldo<>0 then
          v_wynik:= v_saldo*Orw_Pck_Operpom2.znak_analityki(v_anal_knt_id);
        else
          v_wynik:= 0;
        end if;
     end if;
   exception
     WHEN NO_DATA_FOUND then
       v_wynik:=NULL;
   end;
   if g_saldo_dla_syntetyki_cache='T' then
     orw_pck_oracle_wersje.CACHE_DODAJ('SDSYN',v_klucz,v_wynik);
   end if;
   return v_wynik;
 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.saldo_dla_syntetyki ('||p_symbol_like||','||p_pw_id||','||p_lista_podm||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.saldo_dla_syntetyki ('||p_symbol_like||','||p_pw_id||','||p_lista_podm||')');
 end;

FUNCTION daj_date_roz(
  p_pw_id               NUMBER,
  p_rynek_kod           VARCHAR2,
  p_data                DATE,
  p_zglos_wyjatek       VARCHAR2 DEFAULT 'N'
  )
RETURN DATE
IS
  v_dnidor              NUMBER;
  v_data_roz            DATE;
  v_nazwa_rynku         VARCHAR2(200 CHAR);
BEGIN
  -- wybieram iloœæ dni do rozliczenia
  BEGIN
    if orw_pck_admin.pobierz_global('TINSR')='PORTFEL' then
      SELECT  infk3.wartosc_liczba
      INTO v_dnidor
      FROM  ort_przynaleznosci_pw ppw
        ,ort_info_o_kontrahentach infk1
        ,ort_info_o_kontrahentach infk2
        ,ort_info_o_kontrahentach infk3
      WHERE
        ppw.pw_id = p_pw_id
        AND ppw.rynek_kod = p_rynek_kod
        AND ppw.data_od <= TRUNC(p_data)
        AND NVL(ppw.data_do,TRUNC(p_data)) >= TRUNC(p_data)
        AND infk1.typ_info_kod = 'RYNORG'
        AND infk1.wartosc = ppw.rynek_kod
        AND infk2.typ_info_kod = 'RYNSEG'
        AND infk2.wartosc = ppw.SEGMENT
        AND infk2.inf_o_kontr_id = infk1.id
        AND infk3.typ_info_kod = 'DNIDOR'
        AND infk3.inf_o_kontr_id = infk2.id;
    else --rejestry EFOS
      begin --nowa koncepcja
        SELECT infk2.wartosc_liczba
        INTO v_dnidor
        FROM ort_przynaleznosci_pw ppw
          ,ort_info_o_kontrahentach infk1
          ,ort_info_o_kontrahentach infk2
          ,ort_info_o_kontrahentach infk3
        WHERE
          ppw.pw_id = p_pw_id
          AND ppw.rynek_kod = p_rynek_kod
          AND ppw.data_od <= TRUNC(p_data)
          AND NVL(ppw.data_do,TRUNC(p_data)) >= TRUNC(p_data)
          AND infk1.typ_info_kod = 'RYNORG'
          AND infk1.wartosc = ppw.rynek_kod
          AND infk2.typ_info_kod = 'DNIDOR'
          AND infk2.inf_o_kontr_id = infk1.id
          AND infk3.wartosc = ppw.SEGMENT
          AND infk3.typ_info_kod = 'RYNSEG'
          AND infk3.inf_o_kontr_id = infk2.id;
      exception
         WHEN NO_DATA_FOUND
           then null;
      end;

      --efos - stara koncepcja
      if v_dnidor is NULL then
        select wartosc_liczba into v_dnidor
        from ort_info_o_rynkach ior
        where ior.RYNEK_KOD=p_rynek_kod and
              ior.typ_info_kod='DNIR';
      end if;
    end if;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF p_zglos_wyjatek = 'T' THEN
        --pobieramy opis rynku
        BEGIN
          SELECT opis INTO v_nazwa_rynku
          FROM ort_rynki
          WHERE kod = p_rynek_kod;
        EXCEPTION
          WHEN OTHERS THEN
            v_nazwa_rynku := 'NULL';
        END;
        Orw_Pck_Bledy.zglos('brak_daty_roz', orr_pck_operpom2.daj_opis_pw(p_pw_id),
          '"'||v_nazwa_rynku||'"', TO_CHAR(p_data,'dd/mm/yyyy'));
      ELSE
        RETURN NULL;
      END IF;
    WHEN OTHERS THEN
      IF p_zglos_wyjatek = 'T' THEN
        Orw_Pck_Bledy.zglosp('orw_pck_ksiegowania_pom.daj_date_roz_0');
      ELSE
        RETURN NULL;
      END IF;
  END;
  BEGIN
    -- pobieram datê rozliczenia
    v_data_roz := Orw_Pck_operpom3.data_plus_x_r_nal(p_data, v_dnidor, null, null, 'T', p_rynek_kod);
    -- zwracam datê rozliczenia
  EXCEPTION
    WHEN Orw_Pck_Bledy.blad THEN
      IF p_zglos_wyjatek = 'T' THEN
        Orw_Pck_Bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.daj_date_roz_2');
      ELSE
        RETURN NULL;
      END IF;
    WHEN OTHERS THEN
      IF p_zglos_wyjatek = 'T' THEN
        Orw_Pck_Bledy.zglosp('orw_pck_ksiegowania_pom.daj_date_roz_2');
      ELSE
        RETURN NULL;
      END IF;
  END;

  RETURN v_data_roz;
EXCEPTION
  WHEN Orw_Pck_Bledy.blad THEN
    Orw_Pck_Bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.daj_date_roz');
  WHEN OTHERS THEN
    Orw_Pck_Bledy.zglosp('orw_pck_ksiegowania_pom.daj_date_roz');
END;

 -----------------------------------------------------------------------------------
 --Wywoluje funkcje orw_pck_operacj01.wartosc_nominalna na date rozliczenia z rynku
 --do ktorego przypisany jest papier. MOWA:35829
 --  p_ilosc - ilosc
 --  p_pw_id - krotki pw
 --  p_data  - data na ktora bedzie badany rynek i do ktorej dodana zostanie liczba
 --   dni do rozliczenia na tym rynku w celu uzyskania daty odczytania wsp indeksacji nominalu
 --  p_zglos_blad - czy zglaszac blad
 -- W razie napotakania pw nienominalowego funkcja powodujej blad Orw_Pck_Operacje01.exc_ins_bez_nominalu
 -----------------------------------------------------------------------------------
 FUNCTION wartosc_nominalna_rozl(
 -------------------------------
        p_ilosc      NUMBER,
        p_pw_id      NUMBER,
        p_data       DATE,
        p_podmiot_id PLS_INTEGER,
        p_zglos_blad VARCHAR2 DEFAULT 'T',
        p_czy_pob_date_z_rynku VARCHAR2 DEFAULT 'N',
        p_kod_nominalu  VARCHAR2 DEFAULT 'NOMI' )
 RETURN NUMBER
 is
   v_data  DATE;
   v_nominal NUMBER;
   v_log    VARCHAR2(2000 CHAR);
   v_indeks VARCHAR2(10 CHAR);
 begin
    --obliaczam date rozliczenia dla pw na jego obecnym rynku
    -- gdy na liscie wartosci ROKUP jest dostepna wartosc 'Indeksowana';
    --Wczesniejs sprawdzalem OOBAM=T ale nie dzialalo w ORF_PZU_PTE wiec teraz na wniosek
    --A. Tynor PT:40918, warunek zostal zmieniony
   if p_czy_pob_date_z_rynku='T' then
     v_indeks := 'T';
   elsif v_indeks is NULL then
     v_indeks:=orw_pck_admin.pobierz_global('NOMINDR'); --PT:177059

     --fixme: dla zgodnosci wstecz pozostawiam stary sposob pobierania parametru
     --w razie gdyby admin.bdy 189 nie zostal zainstalowany.
     --W przyszlosci nalezy usunac ponizszy blok if-endif (MO, 2012-02-21)
     -----<-- poczatek
     if v_indeks is NULL then
        BEGIN
          begin
            select 'T' into v_indeks
            from ort_typy_dla_Typow_info
            where typ_info_kod='ROPR' and
                  parametr like '%''INDEKSOWANE''%' and --PT:43460
                  rownum=1;
          exception
            when NO_DATA_FOUND THEN
              select 'T' into v_indeks
              from ort_typy_dla_Typow_info
              where typ_info_kod='ROKUP' and
                    parametr like '%''Indeksowana''%' and
                    rownum=1;
          end;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           v_indeks := 'N';
       END;
     end if;
     -----<-- koniec

   end if;
   if v_indeks='T' then
     --PT:38601 - tylko wtedy gdy na aplikacji oblsuga wsp indeksacji jest wlaczona
     --to pobieram date rozliczenia na rynku pw
     v_data:=daj_date_roz(
             p_pw_id,
             Orw_Pck_Operpom2.rynek_dla_pw (p_pw_id, p_data, p_podmiot_id,p_zglos_blad),
             p_data, 'N');
     v_log:=' RN='||TO_CHAR(p_data,'dd/mm/yyyy')||'+'||NVL(v_data-p_data,0);
   else
     v_data:=p_data;
   end if;

   v_nominal:= Orw_Pck_Operacje01.wartosc_nominalna(p_ilosc,p_pw_id,NVL(v_data,p_data),p_zglos_blad, p_ti_kod=>p_kod_nominalu);
   orw_pck_debug.pisz('N='||v_nominal||v_log);   --PT:170979 - poprawa logow
   return v_nominal;
 exception
  WHEN Orw_Pck_Operacje01.exc_ins_bez_nominalu THEN
    raise;
  WHEN Orw_Pck_Bledy.blad THEN
    Orw_Pck_Bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.wartosc_nominalna_rozl('||p_ilosc||', '||p_pw_id||', '||TO_CHAR(p_data,'dd/mm/yyyy')||', '||p_podmiot_id||', '||p_zglos_blad||')');
  WHEN OTHERS THEN
    Orw_Pck_Bledy.zglosp('orw_pck_ksiegowania_pom.wartosc_nominalna_rozl('||p_ilosc||', '||p_pw_id||', '||TO_CHAR(p_data,'dd/mm/yyyy')||', '||p_podmiot_id||', '||p_zglos_blad||')');
 end;


 -------------------------------------------------------------------------------------
 -- Zwraca ID dyspozycji pierwotnej dla przekazanej dyspozycji. MOWA:35778
 -------------------------------------------------------------------------------------
 function dyspozycja_pierwotna(p_dysp_id         PLS_INTEGER)
 -------------------------------------------------------------
 return NUMBER is
   v_dysp_id NUMBER;
 begin
  begin
    select d1.id
    into v_dysp_id
    From ort_info_o_dyspozycjach iod_drea,
         ort_dyspozycje d,
         ort_dyspozycje d1
    where iod_drea.typ_info_kod='DREA' and
          iod_drea.wartosc=d.numer and
          d.id=p_dysp_id and
          iod_drea.dysp_id=d1.id and
          d1.typ_dysp_kod<>'KINZZB';
  exception
    when TOO_MANY_ROWS then
      orw_pck_bledy.zglos('blad_wewnetrzne','l=1106; TMR');
    when NO_DATA_FOUND then
      return NULL;
  end;
  return v_dysp_id;
 exception
  WHEN Orw_Pck_Bledy.blad THEN
    Orw_Pck_Bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.dyspozycja_pierwotna('||p_dysp_id||')');
  WHEN OTHERS THEN
    Orw_Pck_Bledy.zglosp('orw_pck_ksiegowania_pom.wartosc_nominalna_rozl('||p_dysp_id||')');
 end;

 ---------------------------------------------------------------------------------------
 -- Funkcja zwraca date naliczenia wyceny wstepnej, uzytego przez SUWAK w dniu p_data
 ---------------------------------------------------------------------------------------
 function naliczenie_ost_suwaka(
 --------------------------------
             p_data          DATE,
             p_typ_wyc_kod   VARCHAR2,
             p_portfel_id    PLS_INTEGER,
             p_komentarz  IN OUT  VARCHAR2)
 return DATE is
   cursor c_ksiegowania_suw(
                cp_data                DATE,
                cp_potwierdzone        VARCHAR2,
                cp_portfel_id          PLS_INTEGER,
                cp_typ_wyc_kod         VARCHAR2
              )
   is
      select /*+ RULE*/ -- ORDERED  INDEX(iod1 INF_O_DYS_DYSP_FK_I)*/-- PT:42273 - uproszczenie zapytania w celu przyspieszenia
               TRUNC(d.data_waluty) data_dys,
                 iod4.wartosc typ_wyc_kod, iod5.wartosc_data data_wyc
      from ort_dyspozycje d,
           ort_info_o_dyspozycjach iod1,
           ort_info_o_dyspozycjach iod3,
           ort_info_o_dyspozycjach iod4,
           ort_info_o_dyspozycjach iod5
      where typ_dysp_kod IN ('TRAWIR','TRARZE') AND
            d.id=iod1.dysp_id(+) AND
            iod1.typ_info_kod(+)='NDAN' AND
            iod1.wartosc is NULL AND
            d.data_waluty<=cp_data and
            iod3.dysp_id=d.id and
            iod3.typ_info_kod='SUWPID' and
            (cp_portfel_id is NULL OR cp_portfel_id=iod3.wartosc) and --MOWA:32013
            iod5.dysp_id=d.id and
            iod5.typ_info_kod='SUWDAT' and
            (potwierdzone='T' OR cp_potwierdzone='N') and
            iod4.dysp_id(+)=d.id and
            iod4.typ_info_kod(+)='TWYCKOD' and
            (cp_typ_wyc_kod is NULL OR cp_typ_wyc_kod=iod4.wartosc)
      order by d.data_waluty desc;

   v_ks_REC  c_ksiegowania_suw%ROWTYPE;
 begin
   open c_ksiegowania_suw(
                TRUNC(p_Data),
                orw_pck_admin.pobierz_global('ORV_SALDA_WSZYSTKIE_DATA_POTWIERDZONE'),
                p_portfel_id,
                ''
              );
   fetch c_ksiegowania_suw into v_ks_REC;
   if c_ksiegowania_suw%FOUND then
     close c_ksiegowania_suw;
     p_komentarz:=TO_CHAR(v_ks_REC.data_wyc,'dd/mm/yyyy hh24:mi:ss')||' ('||v_ks_REC.data_dys||')';
     return v_ks_REC.data_wyc;
   end if;
   close c_ksiegowania_suw;
   return NULL;
 exception
  WHEN Orw_Pck_Bledy.blad THEN
    Orw_Pck_Bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.naliczenie_ost_suwaka('||
         TO_CHAR(p_data,'dd/mm/yyyy')||','||p_typ_wyc_kod||','||p_portfel_id||')');
  WHEN OTHERS THEN
    Orw_Pck_Bledy.zglosp('orw_pck_ksiegowania_pom.naliczenie_ost_suwaka('||
         TO_CHAR(p_data,'dd/mm/yyyy')||','||p_typ_wyc_kod||','||p_portfel_id||')');
 end;


 function ost_dwal_portfela(
 ---------------------------
             p_data          DATE,
             p_podmiot_id    PLS_INTEGER,
             p_typ_portf_kod VARCHAR2)
 return DATE is
   v_wyn          DATE;
   v_typ_wyc_kod  VARCHAR2(50 CHAR);
 begin
   v_typ_wyc_kod := Orw_Pck_Portfele.pobierz_global('TYP_WYC_KOD');
   if orw_pck_admin.g_platforma>=4 then --PT:92634
     select /*+ ORDERED*/  MAX(dn.data_waluty) into v_wyn
     From ort_portfele p,
          ort_daty_naliczen dn
     where p.typ_portf_kod=p_typ_portf_kod and
        p.podmiot_id=p_podmiot_id and
        p.id=dn.portfel_id and
        dn.data_waluty<=p_data and dn.data_waluty_do>=p_data and
        (orw_pck_portfele.g_aktywna_wyc_REC.data is NULL  OR
            dn.data<>orw_pck_portfele.g_aktywna_wyc_REC.data) and
        (v_typ_wyc_kod is NULL OR dn.typ_wyc_kod IS NULL OR dn.typ_wyc_kod=v_typ_wyc_kod);

   else
     select max(wartosc_Data) into v_wyn
     from  ort_info_o_portfelach iop,
           ort_portfele por
     where iop.portfel_id=por.id and
           iop.typ_info_kod='PPAP' and
           por.typ_portf_kod=p_typ_portf_kod and
           por.podmiot_id=p_podmiot_id and
           iop.wartosc_Data<=p_data and
           (orw_pck_portfele.g_aktywna_wyc_REC.data is NULL  OR
            iop.data<>orw_pck_portfele.g_aktywna_wyc_REC.data) and
           (v_typ_wyc_kod is NULL OR iop.typ_wyc_kod IS NULL OR iop.typ_wyc_kod=v_typ_wyc_kod); --PT:67056
   end if;
   return v_wyn;
 exception
  WHEN Orw_Pck_Bledy.blad THEN
    Orw_Pck_Bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ost_dwal_portfela('||
         TO_CHAR(p_data,'dd/mm/yyyy')||','||p_podmiot_id||','||p_typ_portf_kod||')');
  WHEN OTHERS THEN
    Orw_Pck_Bledy.zglosp('orw_pck_ksiegowania_pom.ost_dwal_portfela('||
         TO_CHAR(p_data,'dd/mm/yyyy')||','||p_podmiot_id||','||p_typ_portf_kod||')');
 end;

 -------------------------------------------------------------------------------
 -- Ksieguje naliczenie. Zwraca id dyspozycji. PT:43671
 -------------------------------------------------------------------------------
 function ksieguj_naliczenie(
 -----------------------------
        p_typ_portf_kod         VARCHAR2,
        p_podmiot_id            PLS_INTEGER,
        p_typ_dysp_kod          VARCHAR2,
        p_data                  DATE,
        p_potwierdz             VARCHAR2,
        p_rodz_podmiotu         VARCHAR2, --PORTFEL/GRUPA/STRATEGIA
        p_numer     IN OUT      VARCHAR2,
        p_typ_wyc_kod           VARCHAR2,
        p_data_pom DATE DEFAULT null,
        p_data_rozl DATE DEFAULT null,
        p_poziom_grupy VARCHAR2 DEFAULT NULL, --PT:97397
        p_data_wyceny DATE      DEFAULT NULL, --PT:170339
        p_opis                  ORT_DYSPOZYCJE.OPIS%TYPE DEFAULT NULL,--PT:178792
        p_ksieguj               VARCHAR2 DEFAULT 'T')
 return NUMBER is

   cursor c_pw_nal_id(cp_podmiot_id	    PLS_INTEGER,
                      cp_typ_portf_kod  VARCHAR2)
    is
       SELECT DISTINCT(pw.id) pw_id
       FROM ort_info_o_portfelach iop ,
             ort_portfele p,
             ort_papiery_wartosciowe pw
       WHERE p.typ_portf_kod = cp_typ_portf_kod
       AND p.podmiot_id=cp_podmiot_id
       AND iop.portfel_id = p.id
       AND iop.wartosc = pw.kod
       AND iop.typ_info_kod = 'PKPW'
       AND iop.data in (SELECT MAX(iop1.data)
                         FROM  ort_info_o_portfelach iop1
                         WHERE iop1.portfel_id = p.id);

   v_portfel_REC orw_pck_portfele.TPortfelRec;
   v_portfel_ARR orw_pck_portfele.TPortfeleArr;
   v_dysp_id     PLS_INTEGER;
   v_pw_id       PLS_INTEGER;
   v_onz_id      PLS_INTEGER;
   v_portfel_id  PLS_INTEGER;
   v_idx         PLS_INTEGER;
   v_czas_id     NUMBER;
   v_agreguj     BOOLEAN;
   v_grupowa     VARCHAR2(20 CHAR);
   v_numer       VARCHAR2(200 CHAR);
   v_data_pom    DATE;
   v_data_rozl   DATE;

 begin
   begin
     select id into v_portfel_id
     from ort_portfele
     where typ_portf_kod=p_typ_portf_kod and
           podmiot_id=p_podmiot_id;
   exception
     when NO_DATA_FOUND THEN
       orw_pck_bledy.zglos('blad_wewnetrzny','l=1429 tp='||p_typ_portf_kod||' pod='||p_podmiot_id);
   end;
   if g_ksieguj_naliczenie_jest_pw is NULL or
      g_ksieguj_naliczenie_tp_kod<>p_typ_portf_kod then
     begin
       g_ksieguj_naliczenie_tp_kod:=p_typ_portf_kod;
       select 'T' into g_ksieguj_naliczenie_jest_pw
       from ort_typy_dla_typow_info
       where typ_portf_kod=p_typ_portf_kod and
             typ_info_kod='PKPW';
     exception
       when NO_DATA_FOUND THEN
         g_ksieguj_naliczenie_jest_pw:='N';
     end;
   end if;

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

   p_numer:='';
   IF orw_pck_portfele.otworz_kursor_GRST(v_portfel_ARR, v_portfel_id, v_agreguj,
       v_grupowa, p_data) THEN --PT:46323 global ustawiony przez poprzednia wycene - informuje czy grupe ksiegowac rachunkami skladowymi czy jako podmiot
    v_idx:=v_portfel_ARR.First;
    LOOP
      EXIT WHEN v_idx is NULL;
      v_portfel_REC:=v_portfel_ARR(v_idx);
      v_idx:=v_portfel_ARR.next(v_idx);

      v_czas_id := orw_pck_admin.czas_sys_start('DFWYLIC', 'N',
         'TYP_DYSP_KOD='||p_typ_dysp_kod||';TPKOD='||p_typ_portf_kod||';PODMIOT_ID='||v_portfel_rec.podmiot_id||';', orw_pck_admin.daj_usera, 'SYSTEM',orw_pck_tlumacz.komunikat('lbKsiegowanie'));

      v_pw_id:=NULL;
      if g_ksieguj_naliczenie_jest_pw='T' then
       open c_pw_nal_id(v_portfel_rec.podmiot_id, p_typ_portf_kod);
       fetch c_pw_nal_id into v_pw_id;
       close c_pw_nal_id;
      end if;

      v_onz_id:=NULL; v_dysp_id:=NULL;

      v_data_pom:=p_data_pom;
      if v_data_pom is null then
        v_data_pom:= p_data;
      end if;
      v_data_rozl:=p_data_rozl;
      if v_data_rozl is null then
        v_data_rozl:= p_data;
      end if;

      if NVL(orw_pck_bledy.g_rollback_po_bledzie,false)<>TRUE then --PT:124949
       orw_pck_bledy.zglos('blad_wewnetrzny','l=2031');
      end if;
      v_dysp_id:=orw_pck_operacje14.wpisz_dyspozycje(p_typ_dysp_kod, NULL, v_pw_id,
          v_portfel_rec.podmiot_id, p_data, v_data_pom, v_data_rozl, p_opis, v_onz_id/*OUT*/, p_typ_wyc_kod);

      if v_dysp_id=-1 then  --PT:201442
        orw_pck_debug.dopisz('  #     ksiegowanie niepotrzebne PT:201442');
        return v_dysp_id;
      end if;

      if v_dysp_id is NULL then
       orw_pck_bledy.zglos('blad_wewnetrzny','l=1434');
      end if;

      if p_ksieguj='T' then
        orw_pck_operacje14.ksieguj_portfel(p_typ_portf_kod,v_portfel_rec.podmiot_id,
                p_data,v_onz_id, p_data_wyceny); --PT:170339
      end if;
      if p_potwierdz='T' then
        v_numer:=orw_pck_ksiegowanie.ksieguj_dyspozycje(v_dysp_id);
        IF Orw_Pck_Operacje00.czytaj_info_stale('ZPR') <> 'N' then --PT:244936 na wniosek Agresta
          v_numer:=orw_pck_ksiegowanie.ksieguj_dyspozycje_bez(v_dysp_id);
        END IF;
      else
        v_numer:=orw_pck_ksiegowanie.ksieguj_dyspozycje(v_dysp_id);
      end if;
      if v_numer is NULL then
        orw_pck_bledy.zglos('blad_wewnetrzny','l=1441');
      end if;
      v_numer:=replace(v_numer, Orw_Pck_Tlumacz.komunikat('wprowadzono_dyspozycje')||' ','');
      begin
        p_numer:=p_numer||', '||v_numer;--PT:248175 na potrzeby ksiegowania grup
      exception
        when VALUE_ERROR then
           null;
      end;
      orw_pck_admin.czas_sys_zakoncz(v_czas_id);
    END LOOP;
   END IF;
   p_numer:=substr(p_numer, 3);
   return v_dysp_id; --id ostatniej dyspozycji - dla ksiegowan grup dorobie wpisywanie do buforow obliczen
 exception
  WHEN Orw_Pck_Bledy.blad THEN
    --CLOSE v_cur_hdl;
    Orw_Pck_Bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ksieguj_naliczenie('||
       p_typ_portf_kod||', p_podmiot_id='||p_podmiot_id||', p_typ_dysp_kod='||p_typ_dysp_kod||', p_data='||TO_CHAR(p_data,'dd/mm/yyyy')||', p_potwierdz='||p_potwierdz||', p_rodz_podmiotu='||p_rodz_podmiotu||', p_numer='||p_numer||', p_typ_wyc_kod='||p_typ_wyc_kod||', p_data_pom='||TO_CHAR(p_data_pom,'dd/mm/yyyy')||', p_data_rozl='||TO_CHAR(p_data_rozl,'dd/mm/yyyy')||', p_poziom_grupy='||p_poziom_grupy||',p_data_wyceny='||TO_CHAR(p_data_wyceny,'dd/mm/yyyy hh24:mi:ss')||')-'||v_grupowa);
  WHEN OTHERS THEN
    --CLOSE v_cur_hdl;
    Orw_Pck_Bledy.zglosp('orw_pck_ksiegowania_pom.ksieguj_naliczenie('||
       p_typ_portf_kod||', p_podmiot_id='||p_podmiot_id||', p_typ_dysp_kod='||p_typ_dysp_kod||', p_data='||TO_CHAR(p_data,'dd/mm/yyyy')||', p_potwierdz='||p_potwierdz||', p_rodz_podmiotu='||p_rodz_podmiotu||', p_numer='||p_numer||', p_typ_wyc_kod='||p_typ_wyc_kod||', p_data_pom='||TO_CHAR(p_data_pom,'dd/mm/yyyy')||', p_data_rozl='||TO_CHAR(p_data_rozl,'dd/mm/yyyy')||', p_poziom_grupy='||p_poziom_grupy||',p_data_wyceny='||TO_CHAR(p_data_wyceny,'dd/mm/yyyy hh24:mi:ss')||')-'||v_grupowa);
 end ksieguj_naliczenie;

 --funkcja porownujaca czy przekazana wycena ma parametry tozsame z parametrami przekazymi jako p_param_list
 function  tozsame_parametry_wyceny(
 ------------------------------------
    p_wycena_REC    orw_pck_ksiegowania_pom.T_Ksiegowany_Portfel_REC,
    p_param_list    VARCHAR2)
 return BOOLEAN is
 begin
   if p_param_list is NOT NULL then
     for v_REC IN (
       select iop.typ_info_kod, iop.wartosc
        from ort_info_o_portfelach iop,
        		 ort_portfele por,
        		 ort_typy_dla_Typow_info tdt
        where iop.portfel_id=p_wycena_REC.portfel_id and
        			iop.data=p_wycena_REC.data_Wyc and
        			iop.portfel_id=por.id and
        			por.typ_portf_kod=tdt.typ_portf_kod and
        			iop.typ_info_kod=tdt.typ_info_kod and
        			tdt.parametr like 'T%' and
        			tdt.ukryty='N'
      ) loop
        if v_REC.wartosc<>orw_pck_portfele.czytaj_param(p_param_list, v_REC.typ_info_kod) then
          return False;
        end if;
      end loop;
    end if;
    return True;
 exception
  WHEN Orw_Pck_Bledy.blad THEN
    Orw_Pck_Bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.tozsame_parametry_wyceny(p_wycena_REC.portfel_id='||
       p_wycena_REC.portfel_id||', p_wycena_REC.data_Wyc='||TO_CHAR(p_wycena_REC.data_Wyc,'dd/mm/yyyy hh24:mi:ss')||', p_param_list='||p_param_list||')');
  WHEN OTHERS THEN
    Orw_Pck_Bledy.zglosp('orw_pck_ksiegowania_pom.tozsame_parametry_wyceny(p_wycena_REC.portfel_id='||
       p_wycena_REC.portfel_id||', p_wycena_REC.data_Wyc='||TO_CHAR(p_wycena_REC.data_Wyc,'dd/mm/yyyy hh24:mi:ss')||', p_param_list='||p_param_list||')');
 end tozsame_parametry_wyceny;

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
    LOOP
      EXIT WHEN v_idx is NULL;
      v_portfel_REC:=v_portfel_ARR(v_idx);
      v_idx:=v_portfel_ARR.next(v_idx);
      v_czas_id := orw_pck_admin.czas_sys_start('DFWYLIC', 'N',
         'TYP_DYSP_KOD='||p_typ_dysp_kod||';TPKOD='||p_typ_portf_kod||';PODMIOT_ID='||v_portfel_rec.podmiot_id||';', orw_pck_admin.daj_usera, 'SYSTEM',orw_pck_tlumacz.komunikat('dfanlopAnulacja'));

      v_licznik:=0; v_anul:=0;
      LOOP --ide w petli i anuluje wszyskie ksiegownia naliczenia na ten dzien
        v_dysp_id:=NULL;  v_data_ks_nal:=NULL; v_wycena_REC.dysp_id:=NULL;
        v_licznik:=v_licznik+1;
        --czyszczenie kesza
        g_typ_portf_kod:='';
        g_typ_dysp_kod:='';
        g_data_portf_par:='';
        g_podmiot_id:='';
        g_typ_wyc_kod:='';

        v_data_ks_nal:=ost_ksieg_portfela(
          'CZYSC_CACHE',
          '',
          p_data,
          v_portfel_REC.podmiot_id,
          v_zrodlo,
          v_wycena_REC);

        v_data_ks_nal:=ost_ksieg_portfela(
          p_typ_portf_kod,
          p_typ_dysp_kod,
          p_data,
          v_portfel_REC.podmiot_id,
          v_zrodlo,
          v_wycena_REC,
          p_typ_wyc_kod); --PT:247501 - anulujemy dyposycjê z przekazanego typu wyceny a nie dowolnego

        --jesli nie ma dyspozycji ksiegujacej naliczenie albo (PT:98276) jest na
        --date rozna przekazanej daty waluty to wychodze
        EXIT WHEN v_data_ks_nal is NULL or v_wycena_REC.dysp_id is NULL or
              NVL(v_wycena_REC.data_waluty_dysp, p_data-1)<>p_data OR v_licznik>100; --jesl pow 100 dysp w ciagu dnia na naliczenie 1 portfela to cos chyba nie tak
        p_komentarz:=substr(p_komentarz||CHR(10)||'  #    anul? #1 nal: '||TO_CHAR(v_wycena_REC.data_wyc,'dd/mm/yyyy hh24:mi:ss')||' dwal_dysp='||v_wycena_REC.data_waluty_dysp, 1,2000);
        if v_wycena_REC.data_waluty_dysp=p_data then
          p_komentarz:=substr(p_komentarz||CHR(10)||'  #    anul? #2 v_wycena_REC.portfel_id='||v_wycena_REC.portfel_id, 1,2000);
          if p_param_list is NULL or
             tozsame_parametry_wyceny(v_wycena_REC, p_param_list) then --PT:201442 - anuluje naliczenie tylko wtedy gdy ma takie same (tozsame) parametry jak przekazane w p_param_List
            v_anul:=v_anul+1;
            begin
              select numer, potwierdzone into v_dysp_pierw_nr, v_dysp_pierw_potw
              From ort_dyspozycje
              where id=v_wycena_REC.dysp_id;
            exception
              when NO_DATA_FOUND then
                v_dysp_pierw_nr:='?';
            end;
            if NVL(orw_pck_bledy.g_rollback_po_bledzie,false)<>TRUE then --PT:124949
              orw_pck_bledy.zglos('blad_wewnetrzny','l=2167');
            end if;
            v_dysp_id := orw_pck_operacje10.anuluj_dyspozycje(
                              NULL,
                              v_wycena_REC.dysp_id,
                              NVL(p_oznaczenie,v_dysp_pierw_nr), --PT:48566
                              v_portfel_REC.podmiot_id,
                              p_data,
                              p_data,
                              NULL,
                              NVL(p_typ_storna,'CZARNY'));

            if p_komentarz is NOT NULL then
              p_komentarz:=substr(p_komentarz||CHR(10), 1, 2000);
            end if;
            p_komentarz:=substr(p_komentarz||'  #    anulowano: '||v_dysp_pierw_nr||' nal: '||TO_CHAR(v_wycena_REC.data_wyc,'dd/mm/yyyy hh24:mi:ss'), 1,2000);

            if v_dysp_id is NOT NULL then
               if v_dysp_pierw_potw='T' then
                  v_dysp_nr:=orw_pck_ksiegowanie.ksieguj_dyspozycje_bez(v_dysp_id);
               end if;
            else
              v_dysp_id:=v_wycena_REC.dysp_id; --PT:170063 jesli anulacja dot dysp niepotw. to nie powstaje specjalna dysp anulacji tylko dysp_anul_id wskazuje na sama siebie
              v_dysp_nr:='nic';
              --orw_pck_bledy.zglos('blad_wewnetrzny','l=1483');
            end if;
            if v_dysp_nr is NULL then
              orw_pck_bledy.zglos('blad_wewnetrzny','l=1486');
            end if;
          elsif p_param_list is NOT NULL then
            --parametry wycen nie byly tozsame: Aby nastepna iteracja ost_ksieg_portfela znalazla wczesniejsza dyspozycje
            --tymczasowo usuwam powiazanie naliczenia z dyspozycji w ostatnio znalezionym

            if NVL(orw_pck_admin.g_platforma, 3)<4 then
              orw_pck_bledy.zglos('blad_wewnetrzny','l=2494; ta funkcjonalnosc wymaga zainstlaowania platformy 4');
            end if;

            SELECT DYSP_ID, ROWID INTO v_dysp_pop_id, v_ROWID
            from ORT_DATY_NALICZEN
            WHERE PORTFEL_ID=v_wycena_REC.portfel_id and
                  DATA=v_wycena_REC.data_wyc
            FOR UPDATE;

            UPDATE ORT_DATY_NALICZEN
            set DYSP_ID=NULL
            WHERE ROWID=v_ROWID;
            if v_dysp_pop_id is NULL then
              orw_pck_bledy.zglos('blad_wewnetrzny','l=2506 ROWID='||v_ROWID);
            end if;
            v_wykluczenia_ROWID_ARR(v_wykluczenia_ROWID_ARR.count+1):=v_ROWID;
            v_wykluczenia_DYSP_ID_ARR(v_wykluczenia_DYSP_ID_ARR.count+1):=v_dysp_pop_id;
          end if;
        end if;
      END LOOP;
    END LOOP;
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


 -------------------------------------------------------------------------------
 -- Poniera dane ostatniego naliczenia i dyspozycji ktora go zaksiegowala.
 -- Uzywane w DF_WYLIC PT:44679
 -------------------------------------------------------------------------------
 function ost_ksieg_portfela(
 -----------------------------
			      p_typ_portf_kod     VARCHAR2,
			      p_typ_dysp_kod      VARCHAR2,
			      p_data	            DATE,
			      p_podmiot_id        NUMBER,
            p_typ_wyc_kod       VARCHAR2 DEFAULT '_UZYJ_GLOBALA', --MOWA:33793, przerobione na _UZYJ_GLOBALA dla MOWA:36328
            p_dysp_id       OUT PLS_INTEGER,
            p_data_waluty   OUT DATE,
            p_data_naliczenia OUT DATE,
            p_data_ks       OUT DATE,
            p_data_waluty_dys OUT DATE
			    )
 return BOOLEAN is
  v_pom      VARCHAR2(1 CHAR);
  v_dane_nal T_Ksiegowany_Portfel_REC;
  v_wyn      BOOLEAN;
 begin
   if p_typ_dysp_kod is NOT NULL then
      p_data_waluty:= ost_ksieg_portfela(
                    p_typ_portf_kod,
                    p_typ_dysp_kod,
                    p_data,
                    p_podmiot_id,
                    v_pom,
                    v_dane_nal,
                    p_typ_wyc_kod
                  );
      p_dysp_id          := v_dane_nal.dysp_id;
      p_data_naliczenia  := v_dane_nal.data_wyc;
      p_data_ks          := v_dane_nal.data_ks;
      p_data_waluty_dys  := v_dane_nal.data_waluty_dysp;
      if p_data_waluty is NOT NULL then
        v_wyn:=True;
      else
        v_wyn:=False;
      end if;
   else
      p_data_naliczenia:=orw_pck_portfele_grupy.data_dla_portfela(
                         p_typ_portf_kod,
                         p_podmiot_id,
                         p_data,
                         'M',
                         '',
                         p_typ_wyc_kod
                         );
      begin
        select data_waluty into p_data_waluty
        from ort_daty_naliczen dn,
             ort_portfele p
        where dn.portfel_id=p.id and
              dn.data=p_data_naliczenia and
              p.typ_portf_kod=p_typ_portf_kod and
              p.podmiot_id=p_podmiot_id;
      exception
        when NO_DATA_FOUND then
          begin
            select wartosc_data into p_data_waluty
            from ort_info_o_portfelach iop,
                 ort_portfele p
            where typ_info_kod='PPAP' and
                  iop.portfel_id=p.id and
                  p.typ_portf_kod=p_typ_portf_kod and
                  p.podmiot_id=p_podmiot_id and
                  iop.data=p_data_naliczenia and
                  (p_typ_wyc_kod is NULL or p_typ_wyc_kod=iop.typ_wyc_kod);
          exception
            when NO_DATA_FOUND THEN
              null;
          end;
      end;

      if p_data_naliczenia is NOT NULL then
        v_wyn:=True;
      else
        v_wyn:=False;
      end if;
   end if;
   return v_wyn;
 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ost_ksieg_portfela3('||p_typ_portf_kod||','||p_typ_dysp_kod||','||TO_CHAR(p_data,'dd/mm/yyyy')||','||
                      p_podmiot_id||',OUT, OUT, '||p_typ_wyc_kod||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.ost_ksieg_portfela3('||p_typ_portf_kod||','||p_typ_dysp_kod||','||TO_CHAR(p_data,'dd/mm/yyyy')||','||
                      p_podmiot_id||',OUT, OUT, '||p_typ_wyc_kod||')');
 end;

 procedure daj_stan(p_stan_id Number, p_stan IN OUT Varchar2, p_uzytkownik IN OUT Varchar2)
 is
 begin
   p_stan := Null;
   p_uzytkownik := Null;
   select stan, uzytkownik
     into p_stan, p_uzytkownik
     from ort_historie_stanow_dysp
    where id = p_stan_id;
 exception
   WHEN no_data_found THEN
     null;
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.daj_stan('||p_stan_id||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.daj_stan('||p_stan_id||')');
 end;

 function zmien_stan_dyspozycji_f(
 --------------------------------
      p_obecny_stan_id  NUMBER,
      p_dysp_id         NUMBER,
      p_stan            VARCHAR2,
      p_opis            VARCHAR2,
      p_data            DATE DEFAULT SYSDATE
     )
 return Number is
   v_obecny_stan_id NUMBER;
   v_ret            Number;
   v_inf_o_dys_id   Number;
   v_trpotw         Varchar2(1 CHAR);
   v_akt_wg_stanu_1_PW   VARCHAR2(20 CHAR);
   v_akt_wg_stanu_1_CASH VARCHAR2(20 CHAR);
   v_akt_wg_stanu_2_PW   VARCHAR2(20 CHAR);
   v_akt_wg_stanu_2_CASH VARCHAR2(20 CHAR);
   v_numer_dysp          Varchar2(50 CHAR);
   v_obecny_stan    VARCHAR2(30 CHAR);
   v_uzytkownik     VARCHAR2(30 CHAR);
   v_cofniete       Varchar2(1 CHAR);
 begin

   if p_stan is null or p_stan = 'N' then
     return null;
   end if;

   --update rozpoczyna sekcje krytyczna (koniec na commicie); zabezpieczam przed sytuacja w ktorej
   --2 uzytkownikow podmienia sobie rownoczesnie stany; poniewaz do stanow tylko sie INSERTUJE, brak blokady
   --mogloby doprowadzic do beldow logicznych (2 stany ostatni=T)
   update ORT_HISTORIE_STANOW_DYSP
   set OSTATNI='N'
   where dysp_id=p_dysp_id;

   select max(id) into v_obecny_stan_id
   from ORT_HISTORIE_STANOW_DYSP
   where dysp_id=p_dysp_id;

   if p_obecny_stan_id<>v_obecny_stan_id then
     --konfilkt 2 uzytkownikow przy zmianie stanu dysp
     select numer into v_numer_dysp
         from ort_dyspozycje where id=p_dysp_id;

     if orw_pck_uzytki_des07.parametr_info_o_operacji('DFWBUFR', 'AUTDCU')='T' then

       daj_stan(v_obecny_stan_id, v_obecny_stan, v_uzytkownik);

       if (p_stan = 'SDPPOT') and (v_obecny_stan = 'SDPPOT') then
         orw_pck_bledy.zglos('trans_przyjeta_do_II_autoryzacji', v_numer_dysp, v_uzytkownik);
       else
         orw_pck_bledy.zglos('trans_przejeta_inny_uzytkownik', v_numer_dysp);
       end if;
     else
       orw_pck_bledy.zglos('aktualny_stan_dysp_zmieniony', v_numer_dysp);
     end if;
   end if;

   daj_stan(p_obecny_stan_id, v_obecny_stan, v_uzytkownik);

   if v_obecny_stan='SDZAKS' and p_stan='SDZAREJ' then
     orw_pck_bledy.zglos('blad_wewnetrzny','l=2773-niedozwolone-'||v_obecny_stan||'->'||p_stan);
   end if;

   v_cofniete := Null;
   if orw_pck_uzytki_des07.parametr_info_o_operacji('DFWBUFR', 'AUTDCU')='T'
   and (v_obecny_stan='SDAUTR' and p_stan='SDWSTPO'
        or v_obecny_stan='SDWSTPO' and p_stan='SDZAREJ'
        or v_obecny_stan='SDPAUT' and p_stan='SDZAREJ'
        or v_obecny_stan='SDPPOT' and p_stan='SDWSTPO') then
     v_cofniete := 'C';
   end if;

   insert into ORT_HISTORIE_STANOW_DYSP (DYSP_ID, DATA, STAN, OPIS, OSTATNI, cofniete)
   VALUES (p_dysp_id, p_data, p_stan, substr(p_opis, 1, 2000),'T', v_cofniete)
   returning id into v_ret ;

   ORW_PCK_PULPIT_ZLECENIA.OZNACZ_ZMIANY(p_dysp_id);

   --PT:144311 PT:151892 bugfix PT:217476
   if v_obecny_stan is not null then
     orw_pck_ksiegowania_limity.ustal_aktywnosc_stanu_dysp(v_obecny_stan, v_akt_wg_stanu_1_PW, v_akt_wg_stanu_1_CASH);
     orw_pck_ksiegowania_limity.ustal_aktywnosc_stanu_dysp(p_stan, v_akt_wg_stanu_2_PW, v_akt_wg_stanu_2_CASH);
     if v_akt_wg_stanu_1_PW<>v_akt_wg_stanu_2_PW OR v_akt_wg_stanu_1_CASH<>v_akt_wg_stanu_2_CASH then
       orw_pck_portfele_online.ponowna_analiza_dyspozycji(null, p_dysp_id, p_commit=>False);
     end if;
   end if;

   return v_ret;

 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.zmien_stan_dyspozycji_f('||p_obecny_stan_id||', '||p_dysp_id||','||p_stan||','||p_opis||','||TO_CHAR(p_data,'dd/mm/yyyy')||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.zmien_stan_dyspozycji_f('||p_obecny_stan_id||', '||p_dysp_id||','||p_stan||','||p_opis||','||TO_CHAR(p_data,'dd/mm/yyyy')||')');
 end;

 procedure zmien_stan_dyspozycji(
 --------------------------------
      p_obecny_stan_id  NUMBER,
      p_dysp_id         NUMBER,
      p_stan            VARCHAR2,
      p_opis            VARCHAR2,
      p_data            DATE DEFAULT SYSDATE
     )
 is
   v_id Number;
 begin
   v_id := zmien_stan_dyspozycji_f(p_obecny_stan_id, p_dysp_id, p_stan, p_opis, p_data);
 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.zmien_stan_dyspozycji('||p_obecny_stan_id||', '||p_dysp_id||','||p_stan||','||p_opis||','||TO_CHAR(p_data,'dd/mm/yyyy')||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.zmien_stan_dyspozycji('||p_obecny_stan_id||', '||p_dysp_id||','||p_stan||','||p_opis||','||TO_CHAR(p_data,'dd/mm/yyyy')||')');
  end;

function daj_opis_ti(p_kod Varchar2)
return Varchar2 is
  v_ret Varchar2(2000 CHAR);
begin
  begin
    v_ret := '';
    select opis into v_ret
      from ort_typy_info where kod=p_kod;
  exception
    when no_data_found then
      null;
  end;
  return v_ret;
end;

 ----------------------------------
 --  return: NULL - nie rob nic
 --          N - przejscie zabronione, nie rob nic
 --          BLAD:tekst - nie mozna zrobic przejscia - wyswietlenie komunikatu
 --          INNY  - mozna ustawic zwracany stan
 ----------------------------------
 function dostepny_stan_dyspozycji(
 ----------------------------------
      p_obecny_stan_id  NUMBER,
      p_operacja_kod    Varchar2,
      p_dysp_id         NUMBER,
      p_stan            VARCHAR2
     )
 return Varchar2 is
   v_obecny_stan    Varchar2(30 CHAR);
   v_ret            Varchar2(2000 CHAR);
   v_SDZAREJ        Varchar2(2000 CHAR);
   v_typ_dysp_kod   Varchar2(7 CHAR);
   v_kodr           Varchar2(50 CHAR);
   v_pom_nmbr       Number;
   v_waluta_rynku   Varchar2(50 CHAR);
   v_potwierdzone   Varchar2(1 CHAR);
   v_trans          Varchar2(50 CHAR);
   v_AUTDCU         Boolean;
   v_przejscie      Varchar2(30 CHAR);
 begin

   -- PT:149965
   v_AUTDCU := (nvl(orw_pck_uzytki_des07.parametr_info_o_operacji('DFWBUFR', 'AUTDCU'), 'N') = 'T');
   if p_operacja_kod is null then
     v_przejscie := 'POCZATKOWE';
   elsif p_operacja_kod = 'DFAUTTR'
   -- PT:149965 dla automatycznej autoryzacji w AVI (i byæ mo¿e jeszcze gdzieœ)(f. ustaw_st_pocz_d_autoryz_autom) byæ mo¿e przez
   -- przypadek a mo¿e celowo wchodzi³o zawsze SDZAREJ, w CU na infie (¿eby przypadkiem nie zepsuæ AVI) robiê obs³uge jak dla autoryzacji
   or p_operacja_kod = 'DFNALIN' and v_AUTDCU then
     v_przejscie :=  'AUTORYZACJA';
   elsif p_operacja_kod = 'DFWBUFR' then
     v_przejscie :=  'BUFOR';
   elsif p_operacja_kod = 'DFROZLF' then
     v_przejscie :=  'ROZLICZENIE';
   end if;

   if p_obecny_stan_id is not null then
     select stan into v_obecny_stan
       from ort_historie_stanow_dysp
      where id=p_obecny_stan_id;
   else
     begin
       select stan into v_obecny_stan
         from ort_historie_stanow_dysp
        where dysp_id=p_dysp_id
          and ostatni='T';
     exception
       when no_data_found then
         null;
     end;
   end if;

   --PT:142556 - blokuje przejscia zerowe
   if v_obecny_stan=p_stan then
     return 'N';
   end if;

   if v_przejscie =  'AUTORYZACJA' then --PT:142556.13
     if v_obecny_stan NOT IN ('SDDOAUT','SDDOMOD','SDODRZU') then
      return 'N';
     end if;
   end if;

   -- domyslnie stan pozytywny - zakladamy ze to co uzytkownik chce to moze
   -- a dopiero ponizej sa szczegolne przypadki w ktorych moze wyjsc ze jednak
   --  co innego niz przekazal, lub ze nie mozna wogole nadac stanu
   v_ret := p_stan;

   if p_stan = 'SDZWER' then
     select typ_dysp_kod into v_typ_dysp_kod
       from ort_dyspozycje
      where id=p_dysp_id;
     if v_obecny_stan = 'SDZAREJ'
     and (v_typ_dysp_kod in ('KINWZL', 'SINZLWT', 'KINWPT', 'SINWDPT')
            and orw_pck_operpom2.czytaj_info('AKTYW', p_dysp_id) <> 'O'
          or v_typ_dysp_kod in ('KINPOS', 'KINPZL')) then
       v_ret := p_stan;
     else
       v_ret := null;
     end if;
   end if;

   -- miedzybank, gieldowki, autoryzacja (ogolnie poczatkowy stan pozytywny)
   -- wszystko poza autoryzacja idzie ze zdarzenia bez operacji
   if (p_stan = 'SDZAREJ') and (v_przejscie = 'POCZATKOWE') and v_obecny_stan is null
   or (p_stan = 'SDZAREJ') and (v_przejscie =  'AUTORYZACJA') and v_obecny_stan IN ('SDDOAUT','SDDOMOD','SDODRZU') then
     v_ret := p_stan;
     select typ_dysp_kod, potwierdzone into v_typ_dysp_kod, v_potwierdzone
       from ort_dyspozycje
      where id=p_dysp_id;
     if v_typ_dysp_kod = 'KINWM' or (v_potwierdzone='T') and v_typ_dysp_kod not in ('KINPD', 'KINPPD', 'KINWD', 'SINWD','KINWZL', 'SINZLWT', 'KINWPT', 'SINWDPT', 'KINPOS', 'KINPZL','KINZZB', 'SINZZB') then
       v_ret := 'SDZAKS';
     elsif v_typ_dysp_kod in ('KINPD', 'KINPPD') then
       v_ret := 'SDPOTW';
     elsif v_typ_dysp_kod in ('KINWD', 'SINWD', 'OOPDD', 'OOPKD', 'OIPDD', 'OIPKD') then
       v_trans := nvl(orw_pck_operpom2.czytaj_info('TRANS', p_dysp_id), 'ZWYKLA');
       if v_AUTDCU and (v_trans='REPO_Z') then
         v_ret := 'SDPOTW';
       else
         v_kodr := orw_pck_operpom2.czytaj_info('KODR', p_dysp_id);
         select count(*) into v_pom_nmbr
           from ort_rynki r,
                ort_info_o_rynkach ir_typr,
                ort_typy_rynkow tr
          where r.kod=v_kodr
            and ir_typr.typ_info_kod = 'TYPR'
            and ir_typr.rynek_kod = r.kod
            and ir_typr.wartosc like 'regulowany%'
            and tr.kod = r.typ_rynku_kod
            and tr.nazwa = 'wtorny';
         -- trans gieldowa
         if (v_trans = 'ZWYKLA') and v_pom_nmbr>0 then
           select pw.kod
             into v_waluta_rynku
             from ort_info_o_rynkach ir,
                  ors_papiery_wartosciowe pw
            where ir.rynek_kod=v_kodr
              and ir.typ_info_kod='WALUTR'
              and pw.id=ir.wartosc_liczba;
           if v_AUTDCU then
             v_ret := 'SDPOTW';
             if v_waluta_rynku <> orw_pck_admin.daj_defwal(null) then
               v_ret := 'SDZAREJ';
             end if;
           else
             if v_waluta_rynku = orw_pck_admin.daj_defwal(null) or not orw_pck_rejestracja_transakcji.istnieje_typ_info('SDWSTPO') then
               v_ret := 'SDPOTW';
             else
               v_ret := 'SDWSTPO';
             end if;
           end if;
         end if;
       end if;
     elsif v_typ_dysp_kod='FRADYSP' then
       if nvl(orw_pck_operpom2.czytaj_info('TTERM', p_dysp_id), 'X')<>'FX' then
         v_ret := 'SDPOTW';
       end if;
     end if;
   end if;

   -- bufor
   if v_przejscie =  'BUFOR' then
     if p_stan = 'SDWSTPO' and v_obecny_stan = 'SDZAREJ' then
       v_ret := p_stan;
     else
       select opis into v_SDZAREJ
         from ort_typy_info
        where kod='SDZAREJ';
       v_ret := 'BLAD:'||orw_pck_tlumacz.komunikat('zaznaczenie_pola_nie_mozliwe_bo_dysp_ma_status_inny_niz', v_SDZAREJ);
     end if;
   end if;

   -- rozliczenie
   if v_przejscie =  'ROZLICZENIE' then
     if p_stan = 'SDROZL' and v_obecny_stan = 'SDZAKS' then
       v_ret := p_stan;
     elsif v_obecny_stan <> 'SDZAKS' then
       -- Status dyspozycji do rozliczenia powinien byæ SDZAKS, jest %1
       orw_pck_bledy.zglos('status_dysp_do_rozl_powinien_byc', daj_opis_ti('SDZAKS'), daj_opis_ti(v_obecny_stan));
     else
       orw_pck_bledy.zglos('blad_wewnetrzny','l=2848'); -- w rozliczeniach mozliwe tylko przejscie SDZAKS -> SDROZL
     end if;
   end if;

   if p_stan = 'SDNIEAK' then
     if v_obecny_stan is null then
       v_ret := null;
     else
       v_ret := p_stan;
     end if;
   end if;

   return v_ret;

 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.dostepny_stan_dyspozycji('||p_obecny_stan_id||', '||p_operacja_kod||', '||p_dysp_id||','||p_stan||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.dostepny_stan_dyspozycji('||p_obecny_stan_id||', '||p_operacja_kod||', '||p_dysp_id||','||p_stan||')');
 end;

 procedure ustaw_stan_dyspozycji(
 --------------------------------
      p_operacja_kod            Varchar2,
      p_dysp_id                 NUMBER,
      p_typ_dysp_kod            Varchar2 default null,
      p_anulacja_nast_dysp      Varchar2 default null
     )
 is
   v_obecny_stan_id Number;
   v_stan VARCHAR2(30 CHAR);
   v_rynek_kod Varchar2(10 CHAR);
   v_inf_o_dys_id Number;
   v_stan_id Number;
   v_typ_dysp_kod ort_dyspozycje.typ_dysp_kod%type;
   v_obecny_stan ort_historie_stanow_dysp.stan%type;
   v_kontynuuj Boolean;
 begin

   -- rozliczenie
   v_stan := 'SDROZL';
   if p_operacja_kod = 'DFROZLF' and orw_pck_rejestracja_transakcji.istnieje_typ_info(v_stan)  then
     v_obecny_stan_id := null;
     begin
       select id into v_obecny_stan_id
         from ort_historie_stanow_dysp
        where dysp_id=p_dysp_id
          and ostatni='T';
     exception
       when no_data_found then
         null;
     end;
     if v_obecny_stan_id is not null then
       zmien_stan_dyspozycji(v_obecny_stan_id, p_dysp_id, dostepny_stan_dyspozycji(v_obecny_stan_id, p_operacja_kod, p_dysp_id, v_stan), null);
     end if;
   end if;

   -- anulacja
   v_stan := 'SDANUL';
   if nvl(p_anulacja_nast_dysp,'N') = 'N' and p_operacja_kod='DFANLOP' and orw_pck_rejestracja_transakcji.istnieje_typ_info(v_stan) then
     v_obecny_stan_id := null;
     begin
       select id into v_obecny_stan_id
         from ort_historie_stanow_dysp
        where dysp_id=p_dysp_id
          and ostatni='T';
     exception
       when no_data_found then
         null;
     end;
     if v_obecny_stan_id is not null then
       zmien_stan_dyspozycji(v_obecny_stan_id, p_dysp_id, v_stan, null);
     end if;
   end if;

   -- anulacja dyspozycji nastepnej w ciagu transakcyjnym,
   -- ustawiam status ktory jest przedostatni (jezeli jest)
   if p_anulacja_nast_dysp='T' and p_operacja_kod='DFANLOP' then
     v_obecny_stan_id := null;
     begin
       select id, stan into v_obecny_stan_id, v_obecny_stan
         from ort_historie_stanow_dysp
        where dysp_id=p_dysp_id
          and ostatni='T';
     exception
       when no_data_found then
         null;
     end;
     select typ_dysp_kod into v_typ_dysp_kod
       from ort_dyspozycje
      where id=p_dysp_id;
     if v_obecny_stan_id is not null then
       -- nie do konca wszystko jest taie proste, bo zlecenia i propozycje trans
       -- moga byc realizowane czastkowo, dlatego SDZWER moze przejsc na SDZAREJ
       -- tylko wtedy jesli AKTYW=O
       if v_typ_dysp_kod in ('KINWZL', 'SINZLWT', 'KINWPT', 'SINWDPT') then
         v_kontynuuj := (v_obecny_stan='SDZWER') and
           (orw_pck_operpom2.czytaj_info('AKTYW', p_dysp_id) = 'O');
       end if;
       v_stan := null;
       if v_kontynuuj then
         begin
           select stan into v_stan
             from ort_historie_stanow_dysp
            where id = (select max(id)
                          from ort_historie_stanow_dysp
                         where dysp_id=p_dysp_id
                           and id <> v_obecny_stan_id);
         exception
           when no_data_found then
             null;
         end;
       end if;
       if v_stan is not null then
         zmien_stan_dyspozycji(v_obecny_stan_id, p_dysp_id, v_stan, null);
       end if;
     end if;
   end if;

 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ustaw_stan_dyspozycji('||p_operacja_kod||', '||p_dysp_id||','||p_typ_dysp_kod||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.ustaw_stan_dyspozycji('||p_operacja_kod||', '||p_dysp_id||','||p_typ_dysp_kod||')');
 end;

 function bufor_mozna_potw(
      p_obecny_stan_id  NUMBER,
      p_dysp_id         NUMBER)
 return Varchar2 is
   v_ret Varchar2(2000 CHAR);
 begin
   -- nastapula zmiana koncepcji - tymczasowo anihilluje ta funkcje
   return null;
   if p_obecny_stan_id is null then
     return null;
   end if;
   v_ret := dostepny_stan_dyspozycji(p_obecny_stan_id, 'DFWBUFR', p_dysp_id, 'SDWSTPO');
   if v_ret = 'SDWSTPO' then
     v_ret := null;
   else
     v_ret := replace(v_ret, 'BLAD:', '');
   end if;
   return v_ret;
 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.bufor_mozna_potw('||p_obecny_stan_id||', '||p_dysp_id||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.bufor_mozna_potw('||p_obecny_stan_id||', '||p_dysp_id||')');
 end;

 procedure ustaw_stan_poczatkowy_dysp(p_dysp_id Number)
 is
   v_dysp_anul_id       Number;
   v_pom_nmbr           Number;
   v_obecny_stan_id     Number;
   v_nowy_stan_id       Number;
   v_numer              ort_dyspozycje.numer%type;
   v_obecny_stan_kod    ort_historie_stanow_dysp.stan%type;
   v_nowy_stan_kod      ort_historie_stanow_dysp.stan%type;
 begin

   if not orw_pck_rejestracja_transakcji.istnieje_typ_info('SDZAREJ') then return; end if;

   -- Funkcja wolana ze zdarzenia LimOn.Zatwierdz.
   -- Trzeba wykluczyc anulacje.
   select dysp_anul_id, numer
     into v_dysp_anul_id, v_numer
     from ort_dyspozycje
    where id=p_dysp_id;
   if v_dysp_anul_id is not null then return; end if;

   -- Jezeli LimOn wstawily jakis status (SDDOAUT) to nie robie nic
   select count(*) into v_pom_nmbr
     from ort_historie_stanow_dysp
    where dysp_id = p_dysp_id;
   if v_pom_nmbr=0 then
     zmien_stan_dyspozycji(null, p_dysp_id, dostepny_stan_dyspozycji(null, null, p_dysp_id, 'SDZAREJ'), null);
     if orw_pck_admin.pobierz_global('TINS') = 'PORTFEL' then
       execute immediate 'begin orw_pck_transakcje2.aktualizuj_zreal_lt(:p_dysp_id, null, null); end;'
       using p_dysp_id;
     end if;
   end if;

   -- dodatkowo dla zlec, prop trans i rozl ofert z rynku pierw gdy wstawiana trans jest realizacja - wstawiam SDZWER
   -- powiazanie jest przez DREA
   for v_rec in (select d.id id_pooprz
                   from ort_info_o_dyspozycjach drea,
                        ort_dyspozycje d
                  where drea.typ_info_kod='DREA'
                    and drea.wartosc=v_numer
                    and d.id=drea.dysp_id
                    and d.typ_dysp_kod in ('KINWZL', 'SINZLWT', 'KINWPT', 'SINWDPT', 'KINPOS', 'KINPZL')) loop
     v_obecny_stan_id := null;
     begin
       select id, stan into v_obecny_stan_id, v_obecny_stan_kod
         from ort_historie_stanow_dysp
        where dysp_id=v_rec.id_pooprz
          and ostatni='T';
     exception
       when no_data_found then
         null;
     end;
     if v_obecny_stan_id is not null then
       zmien_stan_dyspozycji(v_obecny_stan_id, v_rec.id_pooprz, dostepny_stan_dyspozycji(v_obecny_stan_id, null, v_rec.id_pooprz, 'SDZWER'), null);

       select max(id) into v_nowy_stan_id
         from ort_historie_stanow_dysp
        where dysp_id = p_dysp_id;

       if v_nowy_stan_id <> v_obecny_stan_id then
         select stan into v_nowy_stan_kod
           from ort_historie_stanow_dysp
          where id = v_nowy_stan_id;

         if orw_pck_admin.pobierz_global('TINS') = 'PORTFEL' then
           execute immediate 'begin orw_pck_transakcje2.aktualizuj_zreal_lt(:p_dysp_id, :v_obecny_stan_kod, :v_nowy_stan_kod); end;'
           using p_dysp_id, v_obecny_stan_kod, v_nowy_stan_kod;
         end if;
      end if;
     end if;
   end loop;

 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ustaw_stan_poczatkowy_dysp('||p_dysp_id||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.ustaw_stan_poczatkowy_dysp('||p_dysp_id||')');
 end;

 procedure ustaw_stan_nieaktywny_dysp(p_dysp_id Number)
 is
   v_obecny_stan_id     Number;
   v_obecny_stan_kod    ort_historie_stanow_dysp.stan%type;
   v_nowy_stan_kod      ort_historie_stanow_dysp.stan%type;
   v_nowy_stan_id       Number;
 begin

   if not orw_pck_rejestracja_transakcji.istnieje_typ_info('SDNIEAK') then return; end if;

   v_obecny_stan_id := null;
   begin
     select id, stan into v_obecny_stan_id, v_obecny_stan_kod
       from ort_historie_stanow_dysp
      where dysp_id=p_dysp_id
        and ostatni='T';
   exception
     when no_data_found then
       null;
   end;

   if v_obecny_stan_id is not null then
     zmien_stan_dyspozycji(v_obecny_stan_id, p_dysp_id, dostepny_stan_dyspozycji(v_obecny_stan_id, null, p_dysp_id, 'SDNIEAK'), null);
     select max(id) into v_nowy_stan_id
       from ort_historie_stanow_dysp
      where dysp_id = p_dysp_id;

     if v_nowy_stan_id <> v_obecny_stan_id then
       select stan into v_nowy_stan_kod
         from ort_historie_stanow_dysp
        where id = v_nowy_stan_id;

       if orw_pck_admin.pobierz_global('TINS') = 'PORTFEL' then
         execute immediate 'begin orw_pck_transakcje2.aktualizuj_zreal_lt(:p_dysp_id, :v_obecny_stan_kod, :v_nowy_stan_kod); end;'
         using p_dysp_id, v_obecny_stan_kod, v_nowy_stan_kod;
       end if;
     end if;
   end if;

 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ustaw_stan_nieaktywny_dysp('||p_dysp_id||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.ustaw_stan_nieaktywny_dysp('||p_dysp_id||')');
 end;

 procedure ksieguj_dysp_stan_dysp(p_dysp_id Number)
 is
   v_obecny_stan_id     Number;
   v_obecny_stan        Varchar2(30 CHAR);
   v_typ_dysp_kod       Varchar2(7 CHAR);
 begin

   if not orw_pck_rejestracja_transakcji.istnieje_typ_info('SDZAKS') then return; end if;

   v_obecny_stan_id := null;
   begin
     select id, stan into v_obecny_stan_id, v_obecny_stan
       from ort_historie_stanow_dysp
      where dysp_id=p_dysp_id
        and ostatni='T';
   exception
     when no_data_found then
       null;
   end;

   select typ_dysp_kod into v_typ_dysp_kod
     from ort_dyspozycje
    where id=p_dysp_id;

   if v_obecny_stan_id is not null and v_obecny_stan='SDZAREJ' and v_typ_dysp_kod not in ('KINPD', 'KINPPD', 'KINWD', 'SINWD','KINWZL', 'SINZLWT', 'KINWPT', 'SINWDPT', 'KINPOS', 'KINPZL') then
     zmien_stan_dyspozycji(v_obecny_stan_id, p_dysp_id, 'SDZAKS', null);
   end if;
 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ksieguj_dysp_stan_dysp('||p_dysp_id||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.ksieguj_dysp_stan_dysp('||p_dysp_id||')');
 end;

 -------------------------------------------------------------------------------
 --Funkcja zwraca stan dyspozycji na podana date. Jesli nie podano daty to zwraca
 --stan aktualny. PT:144311
 -------------------------------------------------------------------------------
 function daj_stan_dyspozycji(
 -----------------------------
          p_dysp_id NUMBER,
          p_data    DATE,
          p_zglos_blad  VARCHAR2 DEFAULT 'T')
 RETURN VARCHAR2
 is
   v_stan_kod VARCHAR2(20 CHAR);
 begin
    begin
      if p_data is NULL then
        select stan into v_stan_kod
        From ort_historie_stanow_dysp hd1
        where dysp_id=p_dysp_id and
              ostatni='T';
      else
        select stan into v_stan_kod From ort_historie_stanow_dysp hd1
        where dysp_id=p_dysp_id and
              data=(select max(data)
                    from ort_historie_stanow_dysp
                    where dysp_id=hd1.dysp_id and
                          data<=p_data);
      end if;
    exception
      WHEN NO_DATA_FOUND then
        if p_zglos_blad='T' then
          raise;
        end if;
    end;
    return v_stan_kod;
 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.daj_stan_dyspozycji('||p_dysp_id||', '||p_data||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.ustaw_stan_nieaktywny_dysp('||p_dysp_id||', '||p_data||')');
 end;

 procedure ustaw_st_pocz_d_autoryz_autom(p_dysp_id Number)
 is
 begin
   if not orw_pck_rejestracja_transakcji.istnieje_typ_info('SDZAREJ') then return; end if;
   zmien_stan_dyspozycji(null, p_dysp_id, dostepny_stan_dyspozycji(null, 'DFNALIN', p_dysp_id, 'SDZAREJ'), null);
 exception
   WHEN orw_pck_bledy.blad THEN
     orw_pck_bledy.rejestruj_przejscie('orw_pck_ksiegowania_pom.ustaw_st_pocz_d_autoryz_autom(p_dysp_id='||p_dysp_id||')');
   WHEN OTHERS THEN
     orw_pck_bledy.zglosp('orw_pck_ksiegowania_pom.ustaw_st_pocz_d_autoryz_autom(p_dysp_id='||p_dysp_id||')');
 end;

 --PT:255330
 function daj_schemat_rks(p_dysp_id  NUMBER, p_typ_dysp_kod VARCHAR2, p_typ_dysp_opis VARCHAR2 DEFAULT NULL)
 RETURN VARCHAR2
 is
    v_IDSCHRK_id    NUMBER;
    v_wynik         VARCHAR2(4000 CHAR);
    v_td_opis       VARCHAR2(4000 CHAR);
 begin
    if p_typ_dysp_opis is NOT NULL then
      v_td_opis := p_typ_dysp_opis;
    else
      select opis into v_td_opis
      from   ort_typy_dyspozycji
      where  kod=p_typ_dysp_kod;
    end if;      
    if p_typ_dysp_kod IN ('RINRD','RINRA') then
      if orw_pck_walidacja.istnienie_typ_info('IDSCHRK')='T' then
        v_IDSCHRK_id := orw_pck_operpom2.czytaj_info_liczba('IDSCHRK', p_dysp_id);
      end if;
  
      if v_IDSCHRK_id is NOT NULL and p_typ_dysp_kod = 'RINRD' then
         execute immediate 'select sch.opis from ort_schematy_rks sch where id = :v_IDSCHRK_id' into v_wynik
         using v_IDSCHRK_id;
         
      elsif v_IDSCHRK_id is NOT NULL and p_typ_dysp_kod = 'RINRA' then
         execute immediate 'select sch.opis from ort_schematy_rks sch where id = :v_IDSCHRK_id' into v_wynik
         using  v_IDSCHRK_id;                         
         v_wynik :=  substr(v_td_opis, 0, instr(v_td_opis, ' ')) || v_wynik;

      elsif orw_pck_walidacja.istnienie_typ_info('OPSTDS')='N' then
        v_wynik := v_td_opis;
                    
      elsif p_typ_dysp_kod = 'RINRD' then
         v_wynik := orw_pck_operpom2.czytaj_info('OPSTDS', p_dysp_id);
         
      elsif p_typ_dysp_kod = 'RINRA' then
         v_wynik := orw_pck_operpom2.czytaj_info('OPSTDS', p_dysp_id);
         v_wynik :=  substr(v_td_opis, 0, instr(v_td_opis, ' ')) || v_wynik;       
      end if;
    end if;  
    return NVL(v_wynik, v_td_opis);
 end;  
  
end orw_pck_ksiegowania_pom;
/

