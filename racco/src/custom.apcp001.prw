#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} APCP001
Formula de lote de produção chamada pelo cadastro de formulas definido no parâmetro MV_FORMLOT
@type function
@version 12.1.2210
@author Thiago Berna
@since 16/10/2023
@return character, Lote
/*/
User Function APCP001() as character
	Local cLote as character
	cLote := ""

	If (FWIsInCallStack("MATA681") .Or. FWIsInCallStack("ACDV025")) .And. SC2->(FieldPos("C2_XLOTE")) > 0

		//Verifica se o lote se trata de lote previamente preenchido a exemplo do processo Herbarium
		If !Empty(SC2->C2_XLOTE) .And. SC2->C2_TPPR == "E" //I=Interna;E=Externa;R=Retrabalho;O=Outros
			//Considera o lote preenchido manualmente para produção externa
			cLote := AllTrim(SC2->C2_XLOTE)
		Else
			//Lote gerado automaticamente
			BeginSql Alias "TMPSH6"
				SELECT
					MAX(SH6.H6_LOTECTL) AS H6_LOTECTL
				FROM 
					%Table:SH6% SH6
				WHERE
					SH6.%NotDel%
					AND SH6.H6_FILIAL = %xFilial:SH6%
					AND SH6.H6_OP = %Exp:SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)%
			EndSql

			If Empty(TMPSH6->H6_LOTECTL)
				cLote := Soma1(SC2->C2_XLOTE)
			Else
				cLote := Soma1(TMPSH6->H6_LOTECTL)
			EndIf

			TMPSH6->(DBCloseArea())
		EndIf
	EndIf

Return(cLote)
