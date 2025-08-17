#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MTALTEMP
Ponto de entrada - Manipula informações para itens de empenho
@type function
@version 12.1.2210
@author Thiago Berna
@since 16/10/2023
@return array, dados de emepnho atualizados
/*/
User Function MTALTEMP() as array
	Local aAreaSB1  as array
	Local aCampoEmp as array
	aAreaSB1    := SB1->(GetArea())
	aCampoEmp   := AClone(PARAMIXB) //{cProduto,cLocal,nQtd,nQtd2UM,cLoteCtl,cNumLote,cLocaliza,cNumSerie,cOp,cTrt,cPedido,cItem,cOrigem,lEstorno,aSalvCols,nSG1}

	If FWIsInCallStack("MATA650")
		SB1->(DBSetOrder(1)) //B1_FILIAL+B1_COD
		SB1->(MsSeek(FWxFilial("SB1")+aCampoEmp[01]))

		If SB1->B1_TIPO == "EM"
			aCampoEmp[03] := Ceiling(aCampoEmp[03])
			aCampoEmp[04] := ConvUM(aCampoEmp[01], aCampoEmp[03], 0, 2)
		EndIf
	EndIf

	RestArea(aAreaSB1)
	FWFreeVar(@aAreaSB1)

Return(aCampoEmp)
