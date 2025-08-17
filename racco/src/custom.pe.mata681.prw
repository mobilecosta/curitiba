#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT681AIN
Ponto de entrada - Executado no inicio do processamento da inclusão, dentro da transação.
@type function
@version 12.1.2210
@author Thiago Berna
@since 16/10/2023
/*/
User Function MT681AIN
	Local aAreaSD4	as array
	Local aAreaSB1	as array
	Local dValid	as date
	Local cLote 	as character
	aAreaSD4:= SD4->(GetArea())
	aAreaSB1:= SB1->(GetArea())
	aAreaQPK:= QPK->(GetArea())
	dValid	:= STOD("")
	cLote	:= SC2->C2_NUM + SubStr(DTOS(SH6->H6_DATAINI), 5, 2) + SubStr(DTOS(SH6->H6_DATAINI), 1, 4) + "00"

	//Inicializa o campo C2_XLOTE para tratamento no MV_FORMLOT
	If SC2->(FieldPos("C2_XLOTE")) > 0 .And. Empty(SC2->C2_XLOTE)
		RecLock("SC2", .F.)
		SC2->C2_XLOTE := cLote
		SC2->(MsUnlock())
	EndIf

    If ! Empty(cLote)
        QPK->(DBSetOrder(1)) //QPK_FILIAL+QPK_OP+QPK_LOTE+QPK_NUMSER+QPK_PRODUT+QPK_REVI
        If QPK->(MsSeek(FWxFilial("QPK")+SC2->(C2_NUM + C2_ITEM + C2_SEQUEN)))
            If Empty(QPK->QPK_LOTE)
                RecLock("QPK", .F.)
                    QPK->QPK_LOTE := cLote
                QPK->(MsUnlock())
            EndIf
        EndIf
    EndIf

	SB1->(DBSetOrder(1)) //B1_FILIAL+B1_COD
	SB1->(MsSeek(FWxFilial("SB1")+SC2->C2_PRODUTO))

	//Ajusta a data de validade com base na estrutura do produto buscando a menor data de validade entre os compontes B1_TIPO == "PI" para produtos B1_TIPO == "PA"
	If SB1->B1_TIPO == "PA"
		SD4->(DBSetOrder(2)) //D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
		SD4->(MsSeek(FWxFilial("SD4")+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)))

		While SD4->(!Eof()) .And. SD4->(D4_FILIAL+D4_OP) == FWxFilial("SD4")+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
			SB1->(MsSeek(FWxFilial("SB1")+SD4->D4_COD))

			If SB1->B1_TIPO $ "PA|PI" .And. !Empty(SD4->D4_DTVALID)
				If Empty(dValid)
					dValid := SD4->D4_DTVALID
				ElseIf SD4->D4_DTVALID < dValid
					dValid := SD4->D4_DTVALID
				EndIf
			EndIf
			SD4->(DBSkip())

		EndDo

		BeginSql Alias "TMPSD5"

			SELECT MIN(D5_DTVALID) D5_DTVALID
			  FROM %TABLE:SD5% SD5
			 WHERE SD5.D5_FILIAL  = %xFilial:SD5%
			   AND SD5.D5_DOC     = %Exp:SC2->C2_NUM%
			   AND SUBSTRING(SD5.D5_LOTECTL,1,12) = %Exp:SubStr(cLote,1,12)%
			   AND SD5.D5_ORIGLAN = '010'
			   AND SD5.D5_ESTORNO <> 'S'
			   AND SD5.%NOTDEL%
		EndSQL

		If ! TMPSD5->(EoF()) .And. ! Empty(TMPSD5->D5_DTVALID)
			If Empty(dValid)
				dValid := sToD(TMPSD5->D5_DTVALID)
			ElseIf TMPSD5->D5_DTVALID < dValid
				dValid := sToD(TMPSD5->D5_DTVALID)
			EndIf
		EndIf

		TMPSD5->(DbCloseArea())

		If !Empty(dValid)
			RecLock("SH6", .F.)
			SH6->H6_DTVALID := dValid
			SH6->(MsUnlock())
		EndIf
	EndIf

	RestArea(aAreaSD4)
	RestArea(aAreaSB1)
	RestArea(aAreaQPK)

	FWFreeVar(@aAreaSD4)
	FWFreeVar(@aAreaSB1)

Return

/*/{Protheus.doc} MT681INC
Ponto de entrada - Executado no apos o processamento da inclusão, fora da transação.
@type function
@version 12.1.2210
@author Thiago Berna
@since 17/10/2023
/*/
User Function MT681INC
	Local lPriOper 	as logical
	Local lImprime	as logical
	Local aTela		as array
	lPriOper:= SH6->H6_OPERAC == "01"
	lImprime:= .F.
	aTela	:={}

	If lPriOper
		//Verifica se a execução é via ACD
		If FWIsInCallStack("ACDV025")
			aTela := VTSave()
			If VTYesNo("Deseja imprimir a etiqueta?", "Atencao", .T.)
				lImprime := .T.
			EndIf
			VTRestore(,,,,aTela)
		Else
			If MsgNoYes("Deseja imprimir a etiqueta?", "Atenção")
				lImprime := .T.
			EndIf
		EndIf

		//Imprime a etiqueta de Ordem de Produção
		If lImprime
			U_RPCP001()
		EndIf
	EndIf

	FWFreeVar(@aTela)

Return

/*/{Protheus.doc} MTA681MNU
Ponto de entrada - Menu
@type function
@version 12.1.2210
@author Thiago Berna
@since 17/10/2023
/*/
User Function MTA681MNU
	If FindFunction("U_RPCP001")
		AAdd(aRotina, {"Reimprimir Etiqueta", "U_RPCP001()", 0, 6, 0, Nil})
		AAdd(aRotina, {"Reimprimir Etiqueta tipo 2", "U_XPCP001A(2)", 0, 6, 0, Nil})
	EndIf
    aAdd(aRotina,{'Etiqueta Produção', 'u_xpcp001a(2)', 0, 1, 0, NIL})
Return
