CREATE OT REPLACE PACKAGE BODY orw_pck_test AS
  g_execution_REC   ORTW_WYKONANIA_ZADAN%ROWTYPE;
  
  function start_execution_job(
      p_execution_id NUMBER,
      p_OPERATION_TYPE VARCHAR2,
      p_TYPE_CODE    VARCHAR2,
      p_OPERATOR       VARCHAR2,
      p_comment IN OUT VARCHAR2)            
  return VARCHAR2;  
  procedure direct_execution(p_execution_id NUMBER);  

  FUNCTION ver(p_info VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  v_wersja VARCHAR(120)      := '$Revision:: 13 Out                                                                                                  $';
  v_nazwa_pliku VARCHAR(120) := '$Workfile:: cww_pck_task.bdy                                                                                        $';
  v_modyfikacja VARCHAR(120) := '$Modtime:: 25.04.22 16:00                                                                                           $';
  v_uzytkownik VARCHAR(120)  := '$Author:: OCHAL                                                                                                     $';
  v_naglowek VARCHAR(120)    := '$Header:: /wcam/owa/common/ddl/cww_pck_task.bdy 13 Out 1.0.13 25.04.22 16:00 OCHAL                                  $';
  BEGIN
    IF p_info IS NULL THEN
      RETURN REPLACE(v_wersja || CHR(10) || v_nazwa_pliku || CHR(10) || v_modyfikacja || CHR(10) || v_uzytkownik || CHR(10) || v_naglowek, '  ', '');
    ELSIF 'revision' LIKE LOWER(p_info) || '%' THEN
      RETURN v_wersja;
    ELSIF 'workfile' LIKE LOWER(p_info) || '%' THEN
      RETURN v_nazwa_pliku;
    ELSIF 'modtime' LIKE LOWER(p_info) || '%' THEN
      RETURN v_modyfikacja;
    ELSIF 'author' LIKE LOWER(p_info) || '%' THEN
      RETURN v_uzytkownik;
    ELSIF 'header' LIKE LOWER(p_info) || '%' THEN
      RETURN v_naglowek;
    END IF;
    declare
        v_zmienna_num   NUMBER;
        v_zmienna_txt   VARCHAR2(2000 CHAR);
        v_zmienna_dat   DATE;
    begin
        v_zmienna_num:=1;
        v_zmienna_txt:='alamakota';
        v_zmienna_dat:=sysdate;
        v_naglowek:=333;
        g_execution_REC:=23432;
        dbms_output.put_line(v_zmienna_txt);
        dbms_output.put_line(v_zmienna_num);
        dbms_output.put_line(v_zmienna_dat);
    end;

    RETURN 'Dozwolone parametry: r,w,m,a,h.';
  END ver;
END;

