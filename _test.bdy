CREATE OT REPLACE PACKAGE BODY orw_pck_test AS
  g_execution_REC   ORTW_WYKONANIA_ZADAN%ROWTYPE;
  g_execution_NUM4433   NUMBER;
  
  PROCEDURE ver(p_info3 VARCHAR2 DEFAULT NULL);
  PROCEDURE ver(p_info3 VARCHAR2 DEFAULT NULL);
	  FUNCTION ver3(p_info3 VARCHAR2 DEFAULT NULL);
  PROCEDURE ver2(p_info3 VARCHAR2 DEFAULT NULL);
  PROCEDURE ver2(p_info3 VARCHAR2 DEFAULT NULL);  
			  
  FUNCTION ver(p_info3 VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  v_wersja VARCHAR(120)      := '$Revision:: 13 Out                                                                                                  $';
  v_nazwa_pliku VARCHAR(120) := '$Workfile:: cww_pck_task.bdy                                                                                        $';
  v_modyfikacja VARCHAR(120) := '$Modtime:: 25.04.22 16:00                                                                                           $';
  v_uzytkownik VARCHAR(120)  := '$Author:: OCHAL                                                                                                     $';
  v_naglowek VARCHAR(120)    := '$Header:: /wcam/owa/common/ddl/cww_pck_task.bdy 13 Out 1.0.13 25.04.22 16:00 OCHAL                                  $';
  BEGIN
    IF p_info3 IS NULL THEN
      RETURN REPLACE(v_wersja || CHR(10) || v_nazwa_pliku || CHR(10) || v_modyfikacja || CHR(10) || v_uzytkownik || CHR(10) || v_naglowek, '  ', '');
    ELSIF 'revision' LIKE LOWER(p_info3) || '%' THEN
      RETURN v_wersja;
    ELSIF 'workfile' LIKE LOWER(p_info3) || '%' THEN
      RETURN v_nazwa_pliku;
    ELSIF 'modtime' LIKE LOWER(p_info3) || '%' THEN
      RETURN v_modyfikacja;
    ELSIF 'author' LIKE LOWER(p_info3) || '%' THEN
      RETURN v_uzytkownik;
    ELSIF 'header' LIKE LOWER(p_info3) || '%' THEN
      RETURN v_naglowek;
    END IF;
    declare
        v_zmienna_num   NUMBER;
        v_zmienna_txt33   VARCHAR2(2000 CHAR);
        v_zmienna_dat   DATE;
    begin
        v_zmienna_num:=1;
        v_zmienna_txt33:='alamakota';
        v_zmienna_dat:=sysdate;
        v_naglowek:=333;
        g_execution_REC:=23432;
        g_execution_NUM4433:=34534534;
        dbms_output.put_line(v_zmienna_txt33);
        dbms_output.put_line(v_zmienna_num);
        dbms_output.put_line(v_zmienna_dat);
    end;

    RETURN 'Dozwolone parametry: r,w,m,a,h.';
  END ver;
END;

