/**************************************************************************************************
* Project Name         : SiGEPAPP
* PACKAGE SIMILARIDADE : Repons�vel por definir e implementar TIPOS, PROCEDURES e FUN��ES relacionados
					   : com a busca por similaridade. 
					   : APPP_PKG_SIMILARIDADE=> Retorna um n�mero entre 0 e 1 de acordo com a similaridade
					   : local entre dois textos.
* Author               : WeeDo
* History              : 21/04/2009 - Guilherme Wachs Lopes
                       : 10/05/2009 - Guilherme Wachs Lopes: Melhoria na similaridade
					   : 23/05/2009 - Guilherme Wachs Lopes: Alguns Bug consertados
					   : 30/05/2009 - Guilherme Wachs Lopes: Implementado Ordena��o de VETOR_PALAVRAS
***************************************************************************************************/

CREATE OR REPLACE PACKAGE APPP_PKG_SIMILARIDADE AS

    --Types
    TYPE VETOR_PALAVRAS IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
    TYPE INDEXED_PALAVRAS IS TABLE OF  VETOR_PALAVRAS INDEX BY PLS_INTEGER;


    --Procedures
    PROCEDURE ADD_PALAVRA( Indice IN NUMBER, Palavra IN VARCHAR2, VetorIndexed IN OUT NOCOPY INDEXED_PALAVRAS);
    PROCEDURE PREENCHE_LISTA_INDEXADA(Texto IN VARCHAR2,VetorIndexed IN OUT NOCOPY INDEXED_PALAVRAS);
    PROCEDURE PREENCHE_LISTA(Texto IN VARCHAR2, VetorPalavras IN OUT NOCOPY VETOR_PALAVRAS );
    PROCEDURE MAIOR_SUBSTRING(PALAVRA IN VARCHAR2, VETOR_IDX_PALAVRAS IN OUT NOCOPY INDEXED_PALAVRAS, MAX_CARACTER OUT NUMBER, MAX_COMUNS OUT NUMBER);
    PROCEDURE ELIMINAPALPEQ(TEXTO IN OUT NOCOPY VARCHAR2);
    PROCEDURE DEL_INDICE(Indice IN NUMBER, VetorPalavras IN OUT NOCOPY VETOR_PALAVRAS);
    PROCEDURE ORDENA_VETOR_PALAVRAS(vetor_pal IN OUT NOCOPY VETOR_PALAVRAS);
	
    --Functions
    FUNCTION SIMILARIDADE(TEXTO1 IN VARCHAR2, TEXTO2 IN VARCHAR2) RETURN NUMBER;
    FUNCTION PROCURA_PALAVRA(PALAVRA IN VARCHAR2, VETOR IN VETOR_PALAVRAS) RETURN NUMBER;
    FUNCTION QUANTIDADE_DE_PALAVRAS(TEXTO IN VARCHAR2) RETURN NUMBER;

END APPP_PKG_SIMILARIDADE;

/


create or replace
PACKAGE BODY APPP_PKG_SIMILARIDADE AS

  VetorPalavras APPP_PKG_SIMILARIDADE.VETOR_PALAVRAS;
  Indice Number;
  PalavraComparada VARCHAR(100);
  UltimaPalavraComparada VARCHAR(100);
  MaiorRelacao NUMBER:=0;
  MaiorPalavra NUMBER;
  Flag_Continua boolean:=TRUE;
  TextoTranslated VARCHAR2(3000);
  PalavraEncontrada VARCHAR2(100);
  IndiceNoVetor NUMBER;

  PROCEDURE ADD_PALAVRA( Indice IN NUMBER, Palavra IN VARCHAR2, VetorIndexed IN OUT NOCOPY INDEXED_PALAVRAS) AS
  BEGIN
      IF PROCURA_PALAVRA(Palavra,VetorIndexed(Indice))=-1 THEN
        
        VetorIndexed(Indice) (VetorIndexed(Indice).count+1):=Palavra;
        ordena_vetor_palavras(VetorIndexed(Indice));
        
      END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
        VetorIndexed(Indice)(1):=Palavra;


  END ADD_PALAVRA;

  --Procedure para preencher o vetor de Palavras
  PROCEDURE PREENCHE_LISTA_INDEXADA(Texto IN VARCHAR2,VetorIndexed IN OUT NOCOPY INDEXED_PALAVRAS) AS


  BEGIN
      --Troca caracteres para espa�o para separar palavras.
      TextoTranslated := translate(Texto,'./\@()[]{},!?;:<>#$%�&*-=_+','                          ');
      TextoTranslated:= textotranslated||' ';

      --Separa Palavra por Palavra e Armazena no Vetor.
      while INSTR(TextoTranslated,' ',1)>0 loop
        PalavraEncontrada:=SUBSTR(TextoTranslated,1,INSTR(TextoTranslated,' ',1) - 1);
        if PalavraEncontrada!=' ' then

        --Encontrada a palavra, adicion�-la no indice do vetor que corresponda a sua primeira letra.
            --Descobrir o indice do vetor
            ----dbms_output.put_line(palavraencontrada);
            IndiceNoVetor:=ASCII(SUBSTR(PalavraEncontrada,1,1))-64;
            ----dbms_output.PUT_LINE('Adicionando palavra: '||PalavraEncontrada);
            --Insere a Palavra em sua posi��o correta
            add_palavra(IndiceNoVetor,PalavraEncontrada,VetorIndexed);

        --Elimina palavra do texto para pr�xima itera��o
        end if;
        textotranslated:=SUBSTR(TextoTranslated, INSTR(TextoTranslated,' ',1)+1);

      end loop;

        if (length(TextoTranslated)>=1) then
        IndiceNoVetor:=ASCII(SUBSTR(TextoTranslated,1,1))-64;
        add_palavra(IndiceNoVetor,TextoTranslated,VetorIndexed);
        end if;

      

  END PREENCHE_LISTA_INDEXADA;

  PROCEDURE PREENCHE_LISTA(Texto IN VARCHAR2, VetorPalavras IN OUT NOCOPY VETOR_PALAVRAS ) AS
  BEGIN
    DECLARE
    i NUMBER:=1;
    PalavraEncontrada VARCHAR2(100);
    TextoTranslated VARCHAR2(3000);
    BEGIN
      --Troca caracteres para espa�o para separar palavras.
      TextoTranslated := translate(Texto,'./\@()[]{},!?;:<>#$%�&*-+=_','                          ');
      TextoTranslated := TextoTranslated;
      while INSTR(TextoTranslated,' ',1)>0 loop
        
        PalavraEncontrada:=SUBSTR(TextoTranslated,1,INSTR(TextoTranslated,' ',1) - 1);
        
        if PalavraEncontrada!=' ' and PROCURA_PALAVRA(PalavraEncontrada, VetorPalavras)=-1 then
        VetorPalavras(i):=PalavraEncontrada;
        i:=i+1;

        end if;
        textotranslated:=SUBSTR(TextoTranslated, INSTR(TextoTranslated,' ',1)+1);
      end loop;

      if (length(TextoTranslated)>=1) then
      VetorPalavras(i):=TextoTranslated;
      end if;

      --for i in 1..VetorPalavras.count loop
      -- ----dbms_output.PUT_LINE('i=' || i ||VetorPalavras(i));
      --end loop;

    END;
  END PREENCHE_LISTA;


  --Fun��o respons�vel por achar a maior taxa de similaridade entre o Parametro PALAVRA e o vetor bidimensional VETOR_IDX_PALAVRAS
  PROCEDURE MAIOR_SUBSTRING(PALAVRA IN VARCHAR2, VETOR_IDX_PALAVRAS IN OUT NOCOPY INDEXED_PALAVRAS, MAX_CARACTER OUT NUMBER, MAX_COMUNS OUT NUMBER) AS
  BEGIN
    --Descobre qual o indice do vetor indexado vamos pesquisar
    --Esse indice refere-se � primeira letra da PALAVRA
    --Caso seja A ou a seu indice ser� 1
    --se b ser� 2 e assim por diante
    Indice:= ASCII(SUBSTR(PALAVRA,1,1))-64;

    --Seta o vetor de palavras para iterar
    VetorPalavras:= vetor_idx_palavras(indice);
    --Inicializa vari�veis
    maiorrelacao:=0;
    MAX_CARACTER:=0;
    MAX_COMUNS:=0;
  
    --dbms_output.PUT_LINE('Fui chamado para procurar por: ' || palavra);

    ----dbms_output.PUT_LINE('Ultimo elemento '||VetorPalavras(VetorPalavras.count));
    --Para Cada Palavra que come�a com a mesma letra de Palavra
    for x in 1..VetorPalavras.Count loop

      PalavraComparada:=VetorPalavras(x);
      ----dbms_output.put_line('Palavra Comparada: ' || PalavraComparada);
      --Para cada letra a partir da segunda
        for y in 1..length(PALAVRA) loop
          --Se o encadeamento for satisfat�rio no intervalo 1..y fa�a
          IF (substr(PALAVRA, 1, y)=substr(PalavraComparada, 1, y)) THEN
            --Seleciona o maior tamanho da palavra para descobrir o indice
            MaiorPalavra:=greatest(length(PALAVRA),length(PalavraComparada));
            --Caso o indice novo seja maior que o j� descoberto...
            IF (maiorRelacao < y/MaiorPalavra ) then

              --Seta vari�veis de sa�da.
              MAX_CARACTER:=MaiorPalavra;
              MAX_COMUNS:=y;
              --Seta a rela��o para posterior compara��o
              MaiorRelacao:= y/MaiorPalavra;
              --Armazena a palavra de maior rela��o para remov�-la do vetor no
              --final do algoritmo.
              UltimaPalavraComparada:=PalavraComparada;

            END IF;

          END IF;
        
        end loop;
        --Fim Para Cada Letra
        --Caso j� encontrei uma palavra igual saio do loop
        Exit When MaiorRelacao=1;
    end loop;
    --Fim Para Cada Palavra

    --Elimina Palavra Comparada Do Vetor
    --dbms_output.PUT_LINE('Removendo palavra: '||UltimaPalavraComparada || ' com relacao: ' || MaiorRelacao);
    --vetor_idx_palavras(indice).DELETE(PROCURA_PALAVRA(UltimaPalavraComparada,vetor_idx_palavras(indice)));
    DEL_INDICE(PROCURA_PALAVRA(UltimaPalavraComparada,vetor_idx_palavras(indice)),vetor_idx_palavras(indice));
    
    ----dbms_output.PUT_LINE('Total no vetor: '||vetor_idx_palavras(indice).count || ' indice: ' || indice);        
   
    EXCEPTION
    --Caso n�o tenha nenhuma palavra no indice retorna comuns=0    
    WHEN NO_DATA_FOUND THEN
    
    MAX_CARACTER:=length(PALAVRA);
    MAX_COMUNS:=0;
    
  END MAIOR_SUBSTRING;




--FIM PROCEDURE MAIOR_SUBSTRING----------------------------------------------------------------------------------------------------

--INICIO DA PROCEDURE DEL_INDICE

PROCEDURE DEL_INDICE(Indice IN NUMBER, VetorPalavras IN OUT NOCOPY VETOR_PALAVRAS) IS

i number:=indice;
BEGIN
    
    for i in indice..VetorPalavras.count-1 loop
      VetorPalavras(i):=VetorPalavras(i+1);
    end loop;
     VetorPalavras.DELETE(VetorPalavras.Last);  
    

END DEL_INDICE;
--FIM DA PROCEDURE DEL_INDICE

FUNCTION PROCURA_PALAVRA(PALAVRA IN VARCHAR2, VETOR IN VETOR_PALAVRAS) RETURN NUMBER AS
BEGIN

  DECLARE
  retorno number:=-1;

  BEGIN
    FOR x IN 1..VETOR.COUNT LOOP

      IF (VETOR(x)=PALAVRA) THEN
      retorno:=x;
      END IF;

      EXIT WHEN retorno>=0;
    END LOOP;

  return retorno;
  END;

END PROCURA_PALAVRA;

----Inicio da Fun��o de Similaridade

  FUNCTION SIMILARIDADE(TEXTO1 IN VARCHAR2, TEXTO2 IN VARCHAR2) RETURN NUMBER AS
  BEGIN

  DECLARE
    Palavras_Indexadas APPP_PKG_SIMILARIDADE.INDEXED_PALAVRAS;
    Vetor_Palavras APPP_PKG_SIMILARIDADE.VETOR_PALAVRAS;

    TEXT1 VARCHAR2(2000):=UPPER(TEXTO1);
    TEXT2 VARCHAR2(2000):=UPPER(TEXTO2);
    TEXT3 VARCHAR2(2000);
    Total NUMBER;
    Comuns NUMBER;
    CaracteresNaoComparados NUMBER:=0;
    SomaTotal NUMBER:=0;
    SomaComuns NUMBER:=0;
      BEGIN

        ----dbms_output.PUT_LINE('Texto1: '||TEXT1);
        ----dbms_output.PUT_LINE('Texto2: '||TEXT2);
        --Elimina palavras com tamanho menor ou igual � 3 caracteres
        ELIMINAPALPEQ(TEXT1);
        --Optamos por comentar a linha abaixo para caso o usuario colocasse uma palavra menor que tres letras
        --na busca...
        --ELIMINAPALPEQ(TEXT2);
        
        --Testa semelhan�a direta do texto ou se os par�metros s�o nulos
        if (TEXT1=TEXT2 or (text1 is null and text2 is null)) then
        return 1;

		     elsif(TEXT1='' or TEXT2='' or TEXT1 is null or TEXT2 is null) then

        return 0;

        else
        --Compara os dois textos para ver qual � maior. Isso deve ser efetuado para
        --setar corretamente o loop externo que varrer� palavra por palavra.
        if quantidade_de_palavras(TEXT1)<quantidade_de_palavras(TEXT2) then
          TEXT3:=TEXT2;
          TEXT2:=TEXT1;
          TEXT1:=TEXT3;
        end if;

        
        
        --Preenche o Vetor Indexado (BiDimensional)
        --Exemplo:
        --[a]= 'Alberto','Amadeu','Alterar'
        --[c]= 'cachorro','caneta'
        --...
        preenche_lista_indexada(TEXT2,Palavras_Indexadas);

        --Abaixo um vetor unidimensional � preenchido sem indexa��o, pois ser� varrido
        --palavra por palavra no "FOR" Externo.
        preenche_lista(TEXT1, Vetor_Palavras);
      
        ordena_vetor_palavras(Vetor_Palavras);
        
        --for i in 1..Vetor_palavras.count loop
        --dbms_output.PUT_LINE(i || '=' ||Vetor_Palavras(i));
        --end loop;
        
        
        --dbms_output.PUT_LINE('Texto1(Loop): '||TEXT1);
        --dbms_output.PUT_LINE('Texto2(Indexado): '||TEXT2);
        --dbms_output.PUT_LINE('Quantidade em VETOR_PALAVRAS: '||Vetor_Palavras.Count);
        
        
        
        --Loop Externo: Palavra por palavra do texto que tem mais palavras
        FOR x in 1..Vetor_Palavras.Count LOOP
          --Encontra a maior rela��o (CharacteresComuns / TotalCaracteres) entre as palavras
          --do vetor indexado.

          maior_substring(Vetor_Palavras(x), Palavras_Indexadas, Total, comuns);
          
          --Os retornos da procedure acima(Total e Comuns) s�o usados para incrementar
          --as vari�ves que ser�o utilizadas para descobrir a taxa total no final
          --do algoritmo

          SomaTotal:=SomaTotal+Total;
          ----dbms_output.PUT_LINE('SomaTotal: '||SomaTotal);
          
          SomaComuns:=SomaComuns+Comuns;
          ----dbms_output.PUT_LINE('SomaComuns: '||SomaComuns);

        END LOOP;


        --Assim que terminada a varredura, vamos buscar as palavras do vetor indexado
        --que n�o foram comparadas e somar seu tamanho no total de caracteres
        --Um exemplo desse caso:
        --Similaridade('teste algoritmo de similaridade','Implementa��o do Algoritmo de similaridade')
        --O segundo texto ser� colocado no Vetor_Palavras por ter mais palavras
        --O primeiro texto ser� o indexado.
        --a palavra "teste" ser� a �nica palavra que ficara no vetor Indexado
        --seu comprimento dever� ser somado ao total de caracteres.


        --Para cada letra do vetor indexado
        FOR i in 1..255 loop

          BEGIN
            --Para cada palavra que comeca do a letra de codigo ASCII i
            FOR j in 1..Palavras_Indexadas(i).count+1 loop
              BEGIN
              --dbms_output.put_line('Palavra nao encontrada(sobrando): ' || Palavras_Indexadas(i)(j));
                --Captura o tamanho da palavra
                CaracteresNaoComparados:=CaracteresNaoComparados + length(Palavras_Indexadas(i)(j));
              EXCEPTION
                --Caso n�o encontre nada continue...
                when NO_DATA_FOUND then
                null;
              END;
            END LOOP;
          EXCEPTION
            --Caso n�o encontre nada continue...
            when NO_DATA_FOUND then

            null;
          END;

        END LOOP;

        --Soma o comprimento das palavras restantes na SomaTotal de caracteres.
        ----dbms_output.put_line('Somando ' || CaracteresNaoComparados);
        SomaTotal:=SomaTotal+CaracteresNaoComparados;
        ----dbms_output.put_line('Soma: ' || SomaTotal || ' Comuns: ' || SomaComuns);
      --Retorna a similaridade
      if SomaTotal!=0 then
      return (SomaComuns/SomaTotal);
      else
      return 0;
      end if;
      end if;
    END;
  END SIMILARIDADE;


  FUNCTION QUANTIDADE_DE_PALAVRAS(TEXTO IN VARCHAR2) RETURN NUMBER AS
  BEGIN

  DECLARE
  i number:=1;
  soma number:=0;
  posicaoEncontrado number:=0;
  PalavrasJaContadas VETOR_PALAVRAS;

  BEGIN

    TextoTranslated := translate(Texto,'./\@()[]{},!?;:<>#$%�&*-=+_','                          ');
      posicaoEncontrado:=INSTR(TextoTranslated,' ',i);
      while posicaoEncontrado>0  loop

        if INSTR(TextoTranslated,' ', posicaoEncontrado+1)!=posicaoEncontrado+1 then
        soma:=soma+1;
        end if;
        i:=posicaoEncontrado+1;
        posicaoEncontrado:=INSTR(TextoTranslated,' ',i);
      end loop;

      if (i<length(TextoTranslated)) then
      Soma:=Soma+1;
      end if;

    RETURN soma;
    END;
  END QUANTIDADE_DE_PALAVRAS;

  --Elimina palavras que tenham tamanho menor ou igual � 3 letras
PROCEDURE ELIMINAPALPEQ(TEXTO IN OUT NOCOPY VARCHAR2) IS
BEGIN
DECLARE

posicaoInicioPal number:=1;
posicaoFimPal number:=1;


  BEGIN

      Texto := translate(Texto,'./\@()[]{},!?;:<>#$%�&*-=+_','                          ');

      posicaoFimPal:=INSTR(Texto,' ',1);

      while (posicaoFimPal>0) loop
        
        IF (posicaoFimPal-posicaoInicioPal<=3) THEN
          Texto:=substr(Texto,1,posicaoInicioPal-1) || substr(Texto,posicaoFimPal+1);
        ELSE
          posicaoInicioPal:=posicaoFimPal+1;
        END IF;
          posicaoFimPal:=INSTR(Texto,' ',posicaoInicioPal+1);

      END LOOP;

      IF (length(Texto)-posicaoInicioPal<3) THEN
          Texto:=substr(Texto,1,posicaoInicioPal-2) || substr(Texto,length(Texto)+1);
      END IF;

  END;
END ELIMINAPALPEQ;
--Procedure para ordenar palavras em um VETOR_PALAVRAS
PROCEDURE ordena_vetor_palavras(vetor_pal in out nocopy vetor_palavras) is

type vetor_pal_sort_type is table of varchar2(100) index by varchar2(100);
vetor_pal_sort vetor_pal_sort_type;

indice_sort varchar2(100);
indice_vet_pal NUMBER(5):=1;
begin

for i in 1..vetor_pal.count
loop
vetor_pal_sort(vetor_pal(i)):=vetor_pal(i);
end loop;

indice_sort:= vetor_pal_sort.first;

loop

vetor_pal(indice_vet_pal):=vetor_pal_sort(indice_sort);
indice_sort:=vetor_pal_sort.next(indice_sort);
indice_vet_pal:=indice_vet_pal+1;
exit when indice_sort is null;
end loop;

end ordena_vetor_palavras;

END APPP_PKG_SIMILARIDADE;

/
