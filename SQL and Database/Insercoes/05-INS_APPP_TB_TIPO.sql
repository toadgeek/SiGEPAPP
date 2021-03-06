REM INSERTING into APPP_TB_TIPO

INSERT INTO APPP_TB_TIPO(NM_TIPO,DS_TIPO,FL_EXP_REG) VALUES('Texto Alphanumerico','VARCHAR2','N');
INSERT INTO APPP_TB_TIPO(NM_TIPO,DS_TIPO,FL_EXP_REG) VALUES('N�mero Inteiro','NUMBER','N');
INSERT INTO APPP_TB_TIPO(NM_TIPO,DS_TIPO,FL_EXP_REG) VALUES('N�mero Decimal','NUMBER','N');
INSERT INTO APPP_TB_TIPO(NM_TIPO,DS_TIPO,FL_EXP_REG) VALUES('Data','DATE','N');
INSERT INTO APPP_TB_TIPO(NM_TIPO,DS_TIPO,FL_EXP_REG) VALUES('Texto Descritivo','VARCHAR2','N');
INSERT INTO APPP_TB_TIPO(NM_TIPO,DS_TIPO,FL_EXP_REG) VALUES('Hiperlink','https?://([-\w\.]+)+(:\d+)?(/([\w/_\.]*(\?\S+)?)?)?','S');
INSERT INTO APPP_TB_TIPO(NM_TIPO,DS_TIPO,FL_EXP_REG) VALUES('E-Mail','"([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]" + "{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z\\-]+\\.)+))" + "([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)"','S');
INSERT INTO APPP_TB_TIPO(NM_TIPO,DS_TIPO,FL_EXP_REG) VALUES('CPF','"^[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}$"','S');
INSERT INTO APPP_TB_TIPO(NM_TIPO,DS_TIPO,FL_EXP_REG) VALUES('Telefone','"^\d{4}-\d{4}$"','S');
INSERT INTO APPP_TB_TIPO(NM_TIPO,DS_TIPO,FL_EXP_REG) VALUES('CEP','"^\d{5}-\d{3}$"','S');
INSERT INTO APPP_TB_TIPO(NM_TIPO,DS_TIPO,FL_EXP_REG) VALUES('RG','"^[0-9]{1,3}\.[0-9]{3}\.[0-9]{3}-[0-9]$"','S');

commit;
