#include "totvs.ch"

//----------------------------------------------
/*/{Protheus.doc} CHGX5FIL
Numeração de notas fiscais de forma exclusiva

@type function
@version 1.0
@author Consultoria

@since 19/11/2022

@return Character, Filial
/*/
//----------------------------------------------
User Function CHGX5FIL() as character
Return cFilAnt


//----------------------------------------------
//TRATAMENTO PARA GERACAO DE NF NA BAIXA DO ATIVO
//----------------------------------------------


User Function A036VLDSER()

Local oModel := PARAMIXB[1]
Local lRet := .T.

if(oModel:GetValue("FN6_GERANF") == '1' .And. Alltrim(POSICIONE("SX5",1,cFilAnt+"01"+oModel:GetValue("FN6_SERIE"),"X5_CHAVE"))==Alltrim(oModel:GetValue("FN6_SERIE")))
lRet := .T.
else
lRet := .F.
endif

Return lRet
