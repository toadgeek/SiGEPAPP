/**********************************************************************************************************************
* Project Name           : SiGEPAPP
* APPP_DEL_USER_ENDERECO : Procedure para DELETAR dados de ENDERECO DE USU�RIOS
*                          vResult(0=NadaDeletado; 1=OK; -99=ErroGeral)
*                          DEVE-SE PASSAR O CD_USER E O TIPO DO ENDERECO A SER DELETADO
* Author                 : WeeDo 
* History                : 04/03/2009 - Matheus Gon�alves
***********************************************************************************************************************/
create or replace procedure APPP_DEL_USER_ENDERECO(pCD_USER     IN NUMBER  ,
                                                   pTP_ENDERECO IN VARCHAR2,
                                                   vResult   out number) is
vERRO        VARCHAR2(600);     
begin
  
      SELECT COUNT(*) INTO vResult
      FROM APPP_TB_USER_ENDERECO
      WHERE CD_USER  = pCD_USER
      AND   TP_ENDERECO = pTP_ENDERECO;
      
      if vResult > 0 then
      
         DELETE FROM APPP_TB_USER_ENDERECO
         WHERE CD_USER  = pCD_USER
         AND   TP_ENDERECO = pTP_ENDERECO;        
       
        commit;
      end if;   
      
   
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        rollback;
        vResult := 0; -- N�o existe dado a ser deletado. 
        
     WHEN OTHERS THEN
        rollback;
        vResult := SQLCODE; -- Erro generico.
        vERRO   := SUBSTR(SQLERRM,600);
               
end APPP_DEL_USER_ENDERECO;
/