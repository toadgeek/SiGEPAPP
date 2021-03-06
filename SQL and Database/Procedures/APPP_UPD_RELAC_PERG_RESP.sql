/**********************************************************************************************************************
* Project Name             : SiGEPAPP
* APPP_UPD_RELAC_PERG_RESP : Procedure para cria��o de dados de RESPOSTA X PERGUNTAS
*                            vResult( 1=OK; -99=ErroGeral)
* Author                   : WeeDo 
* History                  : 06/03/2009 - Matheus Gon�alves
***********************************************************************************************************************/
create or replace procedure APPP_UPD_RELAC_PERG_RESP(pCD_PERGUNTA   IN NUMBER,
                                                     pCD_RESPOSTA   IN NUMBER,
                                                     pNR_VALOR_RESP IN NUMBER,
                                                     vResult     out number) is
vERRO        VARCHAR2(600);
begin
    
   IF pCD_RESPOSTA IS NOT NULL AND pNR_VALOR_RESP IS NOT NULL THEN 
      
      UPDATE APPP_TB_RELAC_PERG_RESP 
      SET NR_VALOR_RESP = pNR_VALOR_RESP
      WHERE CD_PERGUNTA = pCD_PERGUNTA
      AND   CD_RESPOSTA = pCD_RESPOSTA;

      commit;   
   
   ELSIF pCD_RESPOSTA IS NOT NULL THEN

      UPDATE APPP_TB_RELAC_PERG_RESP 
      SET CD_RESPOSTA = pCD_RESPOSTA
      WHERE CD_PERGUNTA = pCD_PERGUNTA;

      commit;

   END IF;   
   
   vResult := 1; -- OK
   
   
   EXCEPTION
     WHEN OTHERS THEN
        rollback;
        vResult := SQLCODE; -- Erro generico.
        vERRO   := SUBSTR(SQLERRM,600);
               
end APPP_UPD_RELAC_PERG_RESP;
/
