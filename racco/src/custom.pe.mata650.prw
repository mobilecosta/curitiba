#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} A650ALTD4
Ponto de Entrada para ajuste da tela de empenho
@type function
@version 12.1.2210
@author Thiago Bena
@since 24/10/2023
/*/
User Function A650ALTD4
	Local aAreaSB1      as array
	Local nCount        as numeric
    Local nPosCod       as numeric
    Local nPosQuant     as numeric
    Local nPosQtSegum   as numeric
	aAreaSB1    := SB1->(GetArea())
	nCount      := 0
    nPosCod     := AScan(aHeader, {|x| AllTrim(x[2]) == "G1_COMP"})
    nPosQuant   := AScan(aHeader, {|x| AllTrim(x[2]) == "D4_QUANT"})
    nPosQtSegum := AScan(aHeader, {|x| AllTrim(x[2]) == "D4_QTSEGUM"})

	If FWIsInCallStack("MATA650")
		SB1->(DBSetOrder(1)) //B1_FILIAL+B1_COD

		For nCount := 1 To Len(aCols)
			SB1->(MsSeek(FWxFilial("SB1")+aCols[nCount, nPosCod]))

			If SB1->B1_TIPO == "EM"
				aCols[nCount, nPosQuant]    := Ceiling(aCols[nCount, nPosQuant])
				aCols[nCount, nPosQtSegum]  := ConvUM(aCols[nCount, nPosCod], aCols[nCount, nPosQuant], 0, 2)
			EndIf
		Next nCount
	EndIf

	RestArea(aAreaSB1)
	FWFreeVar(@aAreaSB1)

Return
