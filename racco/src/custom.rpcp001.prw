#INCLUDE "TOTVS.CH"
#INCLUDE 'APVT100.CH'

/*/{Protheus.doc} RPCP001
Etiqueta de Ordem de Produção
@type function
@version 12.1.2210
@author Thiago Berna
@since 17/10/2023
/*/
User Function RPCP001
	Local 	aPergs		as array
	Local 	aTela		as array
	Local 	aAreaSB1	as array
	Local 	aAreaSB5	as array
	Local 	aAreaSC2	as array
	Private nQuant		as numeric
	aPergs	:= {}
	aTela	:= {}
	aAreaSB1:= SB1->(GetArea())
	aAreaSB5:= SB5->(GetArea())
	aAreaSC2:= SC2->(GetArea())
	nQuant	:= 0

	CB5->(DBSetOrder(1))

	SC2->(DBSetOrder(1)) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
	SC2->(MsSeek(FWxFilial("SC2")+SH6->H6_OP))

	SB1->(DBSetOrder(1)) //B1_FILIAL+B1_COD
	SB1->(MsSeek(FWxFilial("SB1")+SH6->H6_PRODUTO))

	SB5->(DBSetOrder(1)) //B5_FILIAL+B5_COD
	SB5->(MsSeek(FWxFilial("SB5")+SH6->H6_PRODUTO))

	//Atualiza a quantidade e Verifica se a execução é via ACD
	If SB1->B1_TIPO == "PA"
		If Type("lVT100B") == "L"
			aTela := VTSave()
			While nQuant == 0 .Or. nQuant > SH6->H6_QTDPROD
				nQuant := SB1->B1_CONV

				VTClear
				@ 2,00 VTSAY "Qtd.:" VTGet nQuant Pict AllTrim(GetSX3Cache("B1_CONV", "X3_PICTURE")) Valid U_RPCP01VQ()
				VTRead
			EndDo
			VTRestore( , , , , aTela)
		Else
			nQuant := SB1->B1_CONV
			AAdd(aPergs, {1, "Quantidade: ", nQuant, "", "Positivo() .And. U_RPCP01VQ()", "", ".T.", 80, .T.})

			SaveInter()
			If !Empty(aPergs) .And. ParamBox(aPergs, "Parâmetros", , , , , , , , , .F., .F.)
				nQuant := MV_PAR01
			EndIf
			RestInter()
		EndIf
	Else
		nQuant := SH6->H6_QTDPROD
	EndIf

	If Type("lVT100B") == "L"
		aTela := VTSave()
		
		VTClear
		@ 1,00 VTSAY  "Imprimindo..."
		Imprime(nQuant)

		VTClear
		VTRestore( , , , , aTela)
	Else
		FWMsgRun(, {|| Imprime(nQuant) }, "Imprimindo", "Imprimindo a etiqueta...")
	EndIf

	RestArea(aAreaSB1)
	RestArea(aAreaSB5)
	RestArea(aAreaSC2)

	FWFreeVar(@aPergs)
	FWFreeVar(@aTela)
	FWFreeVar(@aAreaSB1)
	FWFreeVar(@aAreaSB5)
	FWFreeVar(@aAreaSC2)

Return

/*/{Protheus.doc} Imprime
Imprime a Etiqueta de Ordem de Produção
@type function
@version 12.1.2210
@author Thiago Berna
@since 17/10/2023
/*/
Static Function Imprime(nQuant as numeric)
	Local oEtiqueta	as object
	Local nQtdEtq	as numeric
	Local nTotal	as numeric
	Local nSaldo	as numeric
	Local cOP       as character
	Local cRetorno  as character
	Local cProduto	as character
	Local cDescPrd	as character
	Local cLote		as character
	Local cBarcode	as character
	Local cUM		as character
	Local dData		as date
	oEtiqueta	:= IIF(FindClass("RACCO.Etiqueta"), RACCO.Etiqueta():New(), Nil)
	nQtdEtq		:= IIF(SB1->B1_TIPO == "PI", 1, 1)
	nTotal		:= 0
	nSaldo		:= 0
	cOP         := SH6->H6_OP
	cRetorno    := ""
	cProduto	:= SH6->H6_PRODUTO
	cDescPrd	:= IIF(!Empty(SB5->B5_CEME), AllTrim(SB5->B5_CEME), AllTrim(SB1->B1_DESC))
	cLote		:= SubStr(SC2->C2_XLOTE, 1, 12)
	cBarcode	:= ""
	cUM			:= SB1->B1_UM
	dData		:= SH6->H6_DATAINI

	//Calcula etiquetas completas e parciais
	nTotal		:= SH6->H6_QTDPROD
	nSaldo		:= nTotal % nQuant
	nTotal		:= nTotal - nSaldo

	//Ideintifica o código de barras
	If SB5->B5_EAN141 == SB1->B1_CONV
		cBarcode := "1"
	ElseIf SB5->B5_EAN142 == SB1->B1_CONV
		cBarcode := "2"
	ElseIf SB5->B5_EAN143 == SB1->B1_CONV
		cBarcode := "3"
	ElseIf SB5->B5_EAN144 == SB1->B1_CONV
		cBarcode := "4"
	ElseIf SB5->B5_EAN145 == SB1->B1_CONV
		cBarcode := "5"
	ElseIf SB5->B5_EAN146 == SB1->B1_CONV
		cBarcode := "6"
	ElseIf SB5->B5_EAN147 == SB1->B1_CONV
		cBarcode := "7"
	ElseIf SB5->B5_EAN148 == SB1->B1_CONV
		cBarcode := "8"
	EndIf
	cBarcode += SubStr(SB1->B1_CODGTIN, 1, 12)
	cBarcode += EanDigito(AllTrim(cBarcode))

	If FindClass("RACCO.Etiqueta")

		oEtiqueta:selecionaImpressora()
		oEtiqueta:iniciaImpressora()

		While (nTotal + nSaldo) > 0

			cRetorno := oEtiqueta:etiquetaProducao(nTotal, nQuant, nSaldo, cProduto, cBarcode, cLote, dData, cDescPrd, cUM)

			If nTotal > 0
				nTotal := 0
			Else
				nSaldo := 0
			EndIf
		EndDo

		oEtiqueta:finalizaImpressora()

	EndIf

	FWFreeVar(@oEtiqueta)

Return

/*/{Protheus.doc} RPCP01VI
Validação da impressora informada
@type function
@version 12.1.2210 
@author Thiago Berna
@since 18/10/2023
@return logical, Validação
/*/
User Function RPCP01VI() as logical
	Local lRetorno as logical
	lRetorno := .T.

	If Empty(cImp)
		VTKeyBoard(chr(23))
		lRetorno := .F.
	Else
		If !CB5->(MsSeek(FWxFilial("CB5")+cImp))
			VTKeyBoard(chr(23))
			lRetorno := .F.
		EndIf
	EndIf

Return lRetorno

/*/{Protheus.doc} RPCP01VQ
Validação da impressora informada
@type function
@version 12.1.2210 
@author Thiago Berna
@since 19/10/2023
@return logical, Validação
/*/
User Function RPCP01VQ() as logical
	Local lRetorno as logical
	lRetorno := .T.

	If !Type("lVT100B") == "L"
		nQuant := MV_PAR01
	EndIf

	If nQuant <= 0 .Or. nQuant > SH6->H6_QTDPROD
		If Type("lVT100B") == "L"
			VTBEEP(2)
			VTALERT("Quantidade invalida.", "Atencao", .T., 5000, 3)

			VTKeyBoard(chr(23))
		Else
			MsgInfo("Quantidade invalida.", "Atenção")
		EndIf
		lRetorno := .F.
	EndIf

Return lRetorno
