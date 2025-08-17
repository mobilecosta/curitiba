#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include 'totvs.ch'
#Include 'FWMVCDef.ch'
#Include "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "colors.ch"

/*/{Protheus.doc} xcom001a
FwMarkBrowse para exibir os itens do documento de entrada a serem impressos.
@type  User Function
@author Claudio Bozi
@since 01/02/2023
@version 1.0
/*/
User Function xcom001a()

	Local aArea   := GetArea()

    Private aCpoInfo  := {}
    Private aCampos   := {}
    Private aCpoData  := {}
    Private oTable    := Nil
    Private oBrowse   := Nil
    Private aRotBKP   := {}

	Private dDigit	  As Date
	Private cNrNota   As Character 
	Private cSerie    As Character 
	Private cForn     As Character 
	Private cLjFor    As Character 

	Private aTexto  := {}
	Private nQuant  := 0
	Private nCaixas := 0
	Private nResto  := 0
	Private cEnter  := Chr(13) + Chr(10)

	cNrNota := SF1->F1_DOC
	cSerie	:= SF1->F1_SERIE
	cForn   := SF1->F1_FORNECE
	cLjFor  := SF1->F1_LOJA
	dDigit  := SF1->F1_DTDIGIT

    aRotBKP := aRotina

    aRotina := {}

    FwMsgRun(,{ || fLoadData() }, cCadastro, 'Carregando dados...')

    oBrowse := FwMBrowse():New()

    oBrowse:SetAlias('TRB')
    oBrowse:SetTemporary(.T.)

	oBrowse:AddMarkColumns(;
							{|| If(TRB->TMP_OK = "S", "LBOK", "LBNO")},;
							{|| SelectOne(oBrowse)             },;
							{|| SelectAll(oBrowse)             };
	)

    oBrowse:SetColumns(aCampos)

	oBrowse:SetEditCell( .T. ) 			// indica que o grid é editavel

	oBrowse:acolumns[7]:ledit    := .T. // informa qual coluna é editável
	oBrowse:acolumns[7]:cReadVar := 'TMP_QTD'

	oBrowse:acolumns[8]:ledit    := .T. // informa qual coluna é editável
	oBrowse:acolumns[8]:cReadVar := 'TMP_QTDETQ'

	oBrowse:AddButton("Confirmar"	,"u_xcom001b()",,1)

    oBrowse:SetMenuDef('custom.xcom001')

    oBrowse:SetDescription('Seleção de itens para impressão')
    
	oBrowse:Activate()

    If(Type('oTable') <> 'U')
        oTable:Delete()
        oTable := Nil
    Endif

    aRotina := aRotBKP

	RestArea(aArea)

Return

/*/{Protheus.doc} fLoadData
Rotina para inserir dados da tabela temporaria do MarkBrowse
@author Claudio Bozzi
@since 01/02/2023
@version 1.0
/*/
Static Function fLoadData()

    Local nI      := 0
    Local _cAlias := GetNextAlias()

    If(Type('oTable') <> 'U')
        oTable:Delete()
        oTable := Nil
    Endif

    oTable := FwTemporaryTable():New('TRB')

    aCampos  := {}
    aCpoInfo := {}
    aCpoData := {}

    aAdd(aCpoInfo, {'Marcar'  		, '@!' 						, 1							})
    aAdd(aCpoInfo, {'Item'			, '@!' 						, TamSx3('D1_ITEM')[1]		})
    aAdd(aCpoInfo, {'Código'  		, '@!' 						, TamSx3('D1_COD')[1]		})
    aAdd(aCpoInfo, {'Descrição'   	, '@!' 						, TamSx3('B1_DESC')[1]		})
    aAdd(aCpoInfo, {'Quantidade NF'	, '@E 999,999,999.999999'	, TamSx3('D1_QUANT')[1]		})
    aAdd(aCpoInfo, {'UM'  			, '@!' 						, TamSx3('B1_UM')[1]		})
    aAdd(aCpoInfo, {'Quantidade'	, '@E 999,999,999.99' 		, TamSx3('B1_QE')[1]	    })
    aAdd(aCpoInfo, {'Qtd. Etiquetas', '@E 999,999' 				, 6							})

    aAdd(aCpoData, {'TMP_OK'      , 'C'                     , 1                       	, 0							})
    aAdd(aCpoData, {'TMP_ITEM' 	  , TamSx3('D1_ITEM')[3] 	, TamSx3('D1_ITEM')[1] 		, 0							})
    aAdd(aCpoData, {'TMP_COD'  	  , TamSx3('D1_COD')[3] 	, TamSx3('D1_COD')[1] 		, 0							})
    aAdd(aCpoData, {'TMP_DESC'    , TamSx3('B1_DESC')[3]    , TamSx3('B1_DESC')[1]    	, 0							})
    aAdd(aCpoData, {'TMP_QTDNF'	  , TamSx3('D1_QUANT')[3]   , TamSx3('D1_QUANT')[1] 	, TamSx3('D1_QUANT')[2]		})
    aAdd(aCpoData, {'TMP_UM'      , TamSx3('B1_UM')[3] 		, TamSx3('B1_UM')[1] 		, 0							})
    aAdd(aCpoData, {'TMP_QTD'  	  , TamSx3('B1_QE')[3]      , TamSx3('B1_QE')[1] 	    , TamSx3('B1_QE')[2]	    })
    aAdd(aCpoData, {'TMP_QTDETQ'  , TamSx3('D1_QUANT')[3]   , 6   						, 0							})

    For nI := 1 To Len(aCpoData)

        If(aCpoData[nI, 1] <> 'TMP_OK' .and. aCpoData[nI, 1] <> 'TMP_RECNO')

            aAdd(aCampos, FwBrwColumn():New())

            aCampos[Len(aCampos)]:SetData( &('{||' + aCpoData[nI,1] + '}') )
            aCampos[Len(aCampos)]:SetTitle(aCpoInfo[nI,1])
            aCampos[Len(aCampos)]:SetPicture(aCpoInfo[nI,2])
            aCampos[Len(aCampos)]:SetSize(aCpoData[nI,3])
            aCampos[Len(aCampos)]:SetDecimal(aCpoData[nI,4])
            aCampos[Len(aCampos)]:SetAlign(aCpoInfo[nI,3])

        EndIf

    next

    oTable:SetFields(aCpoData)
    oTable:Create()

    BeginSql Alias _cAlias

        SELECT D1_COD, B1_DESC, B1_UM, B1_QE, D1_QUANT, D1_ITEM 
          FROM %TABLE:SD1% SD1
            INNER JOIN %TABLE:SB1% SB1
                 ON SB1.B1_FILIAL = %xFilial:SB1%
                AND SB1.B1_COD    = SD1.D1_COD
                AND SB1.%NOTDEL%
         WHERE SD1.D1_FILIAL  = %xFilial:SD1%
           AND SD1.D1_DOC     = %Exp:cNrNota%
           AND SD1.D1_SERIE   = %Exp:cSerie%
           AND SD1.D1_FORNECE = %Exp:cForn%
           AND SD1.D1_LOJA    = %Exp:cLjFor%
           AND SD1.%NOTDEL%
		   ORDER BY D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM
    EndSQL

    (_cAlias)->(DbGoTop())

    DbSelectArea('TRB')

    While(!(_cAlias)->(EoF()))

        RecLock('TRB', .T.)

            TRB->TMP_OK 	:= 'S'
			TRB->TMP_ITEM   := (_cAlias)->D1_ITEM
            TRB->TMP_COD 	:= (_cAlias)->D1_COD
            TRB->TMP_DESC  	:= (_cAlias)->B1_DESC
			TRB->TMP_QTDNF  := (_cAlias)->D1_QUANT
			TRB->TMP_UM 	:= (_cAlias)->B1_UM
			If (_cAlias)->B1_QE > 0
            	TRB->TMP_QTD := (_cAlias)->B1_QE
			Else
            	TRB->TMP_QTD := 1
	        EndIf
			TRB->TMP_QTDETQ  := INT((_cAlias)->D1_QUANT/TRB->TMP_QTD)

        TRB->(MsUnlock())

        (_cAlias)->(DbSkip())

    EndDo

    TRB->(DbGoTop())

    (_cAlias)->(DbCloseArea())

Return

Static Function SelectOne(oBrowse)

    Local aArea  := TRB->(GetArea())
    Local cMarca := "N"

    cMarca := IIF(TRB->TMP_OK = "S", "N", "S")

	RecLock("TRB", .F.)
		TRB->TMP_OK := cMarca
	TRB->(MsUnlock())

    RestArea(aArea)

    oBrowse:Refresh()

    FWFreeVar(@aArea)
    FWFreeVar(@cMarca)

Return .T.
 
Static Function SelectAll(oBrowse)
	
    Local aArea  := TRB->(GetArea())
    Local cMarca := "N"
    
    TRB->(DBGoTop())
    
    cMarca := IIF(TRB->TMP_OK = "S", "N", "S")
    
    While TRB->(!Eof())

		RecLock("TRB", .F.)
			TRB->TMP_OK := cMarca
		TRB->(MsUnlock())

		TRB->(DBSkip())
    End

    RestArea(aArea)

    oBrowse:Refresh()

    FWFreeVar(@aArea)
    FWFreeVar(@cMarca)

Return

/*/{Protheus.doc} xcom001b
	Função responsavel por gerar a impressão da etiqueta de entrada, chamada pelo PE MT103FIM e via menu MA103OPC.
	@author Claudio Bozzi
	@since 30/06/2022
	@version 1.0
	@param Nil
	@return Nil
/*/
User Function xcom001b()

	Private aArea := GetArea()
    Private nPag  := 0

	Private oPrinter 		:= Nil

	oPrinter := GetPrinter()

	Private oArial6   := TFont():New("Arial",,6,,.f.,,,,,.f.,.f.)
	Private oArial6N  := TFont():New("Arial",,6,,.t.,,,,,.f.,.f.)
	Private oArial8   := TFont():New("Arial",,8,,.f.,,,,,.f.,.f.)
	Private oArial8N  := TFont():New("Arial",,8,,.t.,,,,,.f.,.f.)
	Private oArial10  := TFont():New("Arial",,10,,.f.,,,,,.f.,.f.)
	Private oArial10N := TFont():New("Arial",,10,,.t.,,,,,.f.,.f.)
	Private oArial12  := TFont():New("Arial",,12,,.f.,,,,,.f.,.f.)
	Private oArial12N := TFont():New("Arial",,12,,.t.,,,,,.f.,.f.)
	Private oArial15  := TFont():New("Arial",,15,,.f.,,,,,.f.,.f.)
	Private oArial15N := TFont():New("Arial",,15,,.t.,,,,,.f.,.f.)
	Private oArial17N := TFont():New("Arial",,17,,.t.,,,,,.f.,.f.)

    If oPrinter != Nil
        FwMsgRun(, {|| TratarImp()}, "Executando...", "Executando impressão.")
    EndIf

    RestArea(aArea)

Return

Static Function TratarImp()

    Local nX := 0

    BeginSql Alias "TMPETIQ"

        SELECT D1_DOC, D1_COD, D1_QUANT, D1_LOTECTL, D1_LOTEFOR, D1_DTDIGIT, D1_DTVALID, D1_FORNECE, D1_LOJA, 
                B1_DESC, B1_UM, B1_QE, A2_NOME, A2_CGC, BZ_QE, F1_VOLUME1, B1_CODGTIN, F1_FORNECE, F1_LOJA, 
                F1_DOC, F1_SERIE
		  FROM %Table:SD1% SD1

			INNER JOIN %Table:SF1% SF1
			   ON SF1.F1_FILIAL  = %xFilial:SF1%
			  AND SF1.F1_DOC     = SD1.D1_DOC
			  AND SF1.F1_SERIE   = SD1.D1_SERIE
			  AND SF1.F1_FORNECE = SD1.D1_FORNECE
			  AND SF1.F1_LOJA    = SD1.D1_LOJA
			  AND SF1.%NotDel%

			INNER JOIN %Table:SB1% SB1
			   ON SB1.B1_FILIAL = %xFilial:SB1%
			  AND SB1.B1_COD    = SD1.D1_COD
			  AND SB1.%NotDel%

			INNER JOIN %Table:SA2% SA2
			   ON SA2.A2_FILIAL = %xFilial:SA2%
			  AND SA2.A2_COD    = %Exp:cForn%
			  AND SA2.A2_LOJA   = %Exp:cLjFor%
			  AND SA2.%NotDel%

			LEFT JOIN %Table:SBZ% SBZ
			   ON SBZ.BZ_FILIAL = %xFilial:SBZ%
			  AND SBZ.BZ_COD    = SD1.D1_COD
			  AND SBZ.%NotDel%

        WHERE SD1.D1_FILIAL  = %xFilial:SD1%
		  AND SD1.D1_DOC  	 = %Exp:cNrNota%
          AND SD1.D1_SERIE   = %Exp:cSerie%
          AND SD1.D1_FORNECE = %Exp:cForn%
          AND SD1.D1_LOJA    = %Exp:cLjFor%
          AND SD1.%NotDel%
        
        ORDER BY D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM

    EndSql

	If TMPETIQ->(Eof())
		MsgAlert('Não há dados para impressão de etiqueta para o produto informado', 'Atenção')
	EndIf

    TRB->(DBGoTop())

	Do While ! TMPETIQ->(Eof())

		If TRB->TMP_OK = "N"
			TRB->(DBSkip())
			TMPETIQ->(DbSkip())
			Loop
		EndIf

		If TRB->TMP_QTD > 0
			nQE := TRB->TMP_QTD
		Else
			nQE := 1
		EndIf	

		For nX := 1 To TRB->TMP_QTDETQ
			nQuant := nQE
            MontarImp()
		Next					

		TMPETIQ->(DbSkip())
		TRB->(DBSkip())
	Enddo

	TMPETIQ->(DbCloseArea())

    oPrinter:Preview()

Return

Static Function MontarImp()

    Private nRow    := 20
	Private nCol    := 10

	oPrinter:SetPaperSize(0, 150,100)
	oPrinter:SetMargin(001,001,001,001)
	oPrinter:StartPage()

    oPrinter:SayBitmap( nRow, nCol+180,'\system\etq'+cEmpAnt+cFilAnt+'.png')

    oPrinter:Say( nRow+5, nCol+40,"ENTRADA",oArial17N,,,)

    nRow += 20
    oPrinter:Say( nRow, nCol+10,AllTrim(TMPETIQ->D1_COD),oArial15N,,,)

    nRow += 15
    oPrinter:Say( nRow, nCol+10,SubStr(AllTrim(TMPETIQ->B1_DESC),1,30),oArial15N,,,)

    nRow += 15
    oPrinter:Say( nRow, nCol+10,SubStr(AllTrim(TMPETIQ->B1_DESC),31),oArial15N,,,)

    nRow += 15
    oPrinter:Say( nRow, nCol+10,AllTrim(TMPETIQ->D1_LOTECTL) + "     " + dToC(sToD(TMPETIQ->D1_DTVALID)),oArial15N,,,)

    oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,8/*nRow*/ ,2/*nCol*/, AllTrim(TMPETIQ->D1_COD)/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.T./*lHorz*/,/*nWidth*/,0.6/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)
    oPrinter:Say( nRow+45, nCol+20,AllTrim(TMPETIQ->D1_COD),oArial12,,,)

    oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,11.3/*nRow*/ ,2/*nCol*/, AllTrim(TMPETIQ->D1_LOTECTL)/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.T./*lHorz*/,/*nWidth*/,0.6/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)
    oPrinter:Say( nRow+85, nCol+20,AllTrim(TMPETIQ->D1_LOTECTL),oArial12,,,)

    oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,15/*nRow*/ ,2/*nCol*/, AllTrim(TMPETIQ->D1_LOTEFOR)/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.T./*lHorz*/,/*nWidth*/,0.6/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)
    oPrinter:Say( nRow+130, nCol+20,AllTrim(TMPETIQ->D1_LOTEFOR),oArial12,,,)

    // oPrinter:Code128(62/*nRow*/ ,20/*nCol*/, AllTrim(TMPETIQ->D1_LOTECTL)/*cCode*/,5/*nWidth*/,20/*nHeight*/,.F./*lSay*/,/*oFont*/,100/*nTotalWidth*/)

    nRow += 150
    oPrinter:Say( nRow, nCol,"FORNECEDOR: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+75,SubStr(AllTrim(TMPETIQ->A2_NOME),1,24),oArial12,,,)
    
    If ! Empty(SubStr(AllTrim(TMPETIQ->A2_NOME),25))
        nRow += 10
        oPrinter:Say( nRow, nCol,SubStr(AllTrim(TMPETIQ->A2_NOME),25),oArial12,,,)
    EndIf

    nRow += 10
    oPrinter:Say( nRow, nCol,"COD FORNECEDOR: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+95,AllTrim(TMPETIQ->F1_FORNECE),oArial12,,,)

    oPrinter:Say( nRow, nCol+150,"LOJA: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+180,AllTrim(TMPETIQ->F1_LOJA),oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,"NOTA FISCAL: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+70,AllTrim(TMPETIQ->F1_DOC),oArial12,,,)

    oPrinter:Say( nRow, nCol+150,"SÉRIE: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+185,AllTrim(TMPETIQ->F1_SERIE),oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,"CNPJ: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+30,Transform(TMPETIQ->A2_CGC,"@R 99.999.999/9999-99"),oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,"QTDE LOTE: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+60,AllTrim(cValToChar(nQuant)),oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,"QTDE EMB: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+55,AllTrim(cValToChar(nQuant)),oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,"UM: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+20,AllTrim(TMPETIQ->B1_UM),oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,"LOTE FORN: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+58,AllTrim(TMPETIQ->D1_LOTEFOR)+"TST",oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,"LOTE: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+30,AllTrim(TMPETIQ->D1_LOTECTL),oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,"VALIDADE: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+52,dToC(sToD(TMPETIQ->D1_DTVALID)),oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,"DATA: ",oArial12N,,,)
    oPrinter:Say( nRow, nCol+30,dToC(sToD(TMPETIQ->D1_DTDIGIT)),oArial12,,,)

    oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,22/*nRow*/ ,12/*nCol*/, AllTrim(TMPETIQ->F1_FORNECE)+AllTrim(TMPETIQ->F1_LOJA)/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.T./*lHorz*/,/*nWidth*/,0.6/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)
    oPrinter:Say( nRow-40, nCol+150,AllTrim(TMPETIQ->F1_FORNECE)+AllTrim(TMPETIQ->F1_LOJA),oArial12,,,)

    oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,26/*nRow*/ ,12/*nCol*/, AllTrim(TMPETIQ->F1_DOC)+AllTrim(TMPETIQ->F1_SERIE)/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.T./*lHorz*/,/*nWidth*/,0.6/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)
    oPrinter:Say( nRow+5, nCol+150,AllTrim(TMPETIQ->F1_DOC)+AllTrim(TMPETIQ->F1_SERIE),oArial12,,,)

    oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,30/*nRow*/ ,12/*nCol*/, AllTrim(cValToChar(nQuant))/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.T./*lHorz*/,/*nWidth*/,0.6/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)
    oPrinter:Say( nRow+55, nCol+150,AllTrim(cValToChar(nQuant)),oArial12,,,)

    nRow += 65
    oPrinter:Say( nRow, nCol,"_______________________________________",oArial12N,,,)
    
    nRow += 15
    oPrinter:Say( nRow, nCol+50,"QUARENTENA",oArial15N,,,)

	oPrinter:EndPage()

Return

Static Function GetPrinter()

    Local oPrinter  as Object
    Local oSetup    as Object
    Local cTempFile as Character
    
    cTempFile := "xcom001_" + DtoS(dDataBase) + "_" + StrTran(Time(),":","") + ".pdf"
    
	oPrinter := FWMSPrinter():New(cTempFile, IMP_PDF, .F.,, .T.,, oSetup,, .T.,,, .F.,)

	oPrinter:SetResolution(72)
	oPrinter:SetLandscape()

    oSetup := FWPrintSetup():New( PD_ISTOTVSPRINTER + ;
                                    PD_DISABLEPAPERSIZE + ;
                                    PD_DISABLEMARGIN + ;
                                    PD_DISABLEORIENTATION + ;
                                    PD_DISABLEDESTINATION ;
                                    , "Impressão de Etiqueta de Entrada")

    oSetup:SetPropert(PD_PRINTTYPE   , 6 ) //PDF
    oSetup:SetPropert(PD_ORIENTATION , 2 ) //Paisagen
    oSetup:SetPropert(PD_DESTINATION , 2)
    oSetup:SetPropert(PD_MARGIN      , {20,20,20,20})
    oSetup:SetPropert(PD_PAPERSIZE   , 2)

    IF oSetup:Activate() == PD_OK
        If oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
            oPrinter:nDevice := IMP_PDF
            oPrinter:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
            oPrinter:lViewPDF := .T.
        elseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
            oPrinter:nDevice := IMP_SPOOL
            oPrinter:cPrinter := oSetup:aOptions[PD_VALUETYPE]
        Endif
    Else
        oPrinter := nil
    EndIF

Return oPrinter
