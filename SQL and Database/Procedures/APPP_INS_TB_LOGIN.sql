/**********************************************************************************************************************
* Project Name      : SiGEPAPP
* APPP_INS_TB_LOGIN : Procedure para cria��o de dados de login
*                     vResult( 1=OK; -99=ErroGeral)
* Author            : WeeDo 
* History           : 27/02/2009 - Matheus Gon�alves
***********************************************************************************************************************/
create or replace procedure APPP_INS_TB_LOGIN(vCD_USER  in NUMBER, 
                                              vNM_LOGIN in VARCHAR2, 
                                              vPW_SENHA in VARCHAR2, 
                                              vResult   out number) is
vERRO        VARCHAR2(600);
begin
    
   insert into APPP_TB_LOGIN(cd_user,NM_LOGIN,PW_SENHA)
               values(vcd_user,vNM_LOGIN,vPW_SENHA);
   
   
   vResult := 1; -- OK
   commit;
   
   EXCEPTION
     WHEN OTHERS THEN
        rollback;
        vResult := SQLCODE; -- Erro generico.
        vERRO   := SUBSTR(SQLERRM,600);
               
end APPP_INS_TB_LOGIN;
/
