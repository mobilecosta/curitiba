#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include 'totvs.ch'
#Include 'FWMVCDef.ch'
#Include "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "colors.ch"

/*/{Protheus.doc} xfat001a
FwMarkBrowse para exibir os itens do documento de saida a serem impressos.
@type  User Function
@author Claudio Bozi
@since 01/02/2023
@version 1.0
/*/
User Function xfat001a()

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
	Private cClie     As Character 
	Private cLjClie    As Character 

	Private aTexto  := {}
	Private nQuant  := 0
	Private nCaixas := 0
	Private nResto  := 0
	Private cEnter  := Chr(13) + Chr(10)

	cNrNota := SF2->F2_DOC
	cSerie	:= SF2->F2_SERIE
	cClie   := SF2->F2_CLIENTE 
	cLjClie := SF2->F2_LOJA
	dDigit  := SF2->F2_DTDIGIT

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

	oBrowse:AddButton("Confirmar"	,"u_xfat001b()",,1)

    oBrowse:SetMenuDef('custom.xfat001')

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
    aAdd(aCpoInfo, {'Item'			, '@!' 						, TamSx3('D2_ITEM')[1]		})
    aAdd(aCpoInfo, {'Código'  		, '@!' 						, TamSx3('D2_COD')[1]		})
    aAdd(aCpoInfo, {'Descrição'   	, '@!' 						, TamSx3('B1_DESC')[1]		})
    aAdd(aCpoInfo, {'Quantidade NF'	, '@E 999,999,999.999999'	, TamSx3('D2_QUANT')[1]		})
    aAdd(aCpoInfo, {'UM'  			, '@!' 						, TamSx3('B1_UM')[1]		})
    aAdd(aCpoInfo, {'Quantidade'	, '@E 999,999,999.99' 		, TamSx3('B1_QE')[1]	    })
    aAdd(aCpoInfo, {'Qtd. Etiquetas', '@E 999,999' 				, 6							})

    aAdd(aCpoData, {'TMP_OK'      , 'C'                     , 1                       	, 0							})
    aAdd(aCpoData, {'TMP_ITEM' 	  , TamSx3('D2_ITEM')[3] 	, TamSx3('D2_ITEM')[1] 		, 0							})
    aAdd(aCpoData, {'TMP_COD'  	  , TamSx3('D2_COD')[3] 	, TamSx3('D2_COD')[1] 		, 0							})
    aAdd(aCpoData, {'TMP_DESC'    , TamSx3('B1_DESC')[3]    , TamSx3('B1_DESC')[1]    	, 0							})
    aAdd(aCpoData, {'TMP_QTDNF'	  , TamSx3('D2_QUANT')[3]   , TamSx3('D2_QUANT')[1] 	, TamSx3('D2_QUANT')[2]		})
    aAdd(aCpoData, {'TMP_UM'      , TamSx3('B1_UM')[3] 		, TamSx3('B1_UM')[1] 		, 0							})
    aAdd(aCpoData, {'TMP_QTD'  	  , TamSx3('B1_QE')[3]      , TamSx3('B1_QE')[1] 	    , TamSx3('B1_QE')[2]	    })
    aAdd(aCpoData, {'TMP_QTDETQ'  , TamSx3('D2_QUANT')[3]   , 6   						, 0							})

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

        SELECT D2_COD, B1_DESC, B1_UM, B1_QE, D2_QUANT, D2_ITEM 
          FROM %TABLE:SD2% SD2
            INNER JOIN %TABLE:SB1% SB1
                 ON SB1.B1_FILIAL = %xFilial:SB1%
                AND SB1.B1_COD    = SD2.D2_COD
                AND SB1.%NOTDEL%
         WHERE SD2.D2_FILIAL  = %xFilial:SD2%
           AND SD2.D2_DOC     = %Exp:cNrNota%
           AND SD2.D2_SERIE   = %Exp:cSerie%
           AND SD2.D2_CLIENTE = %Exp:cClie%
           AND SD2.D2_LOJA    = %Exp:cLjClie%
           AND SD2.%NOTDEL%
		   ORDER BY D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_ITEM
    EndSQL

    (_cAlias)->(DbGoTop())

    DbSelectArea('TRB')

    While(!(_cAlias)->(EoF()))

        RecLock('TRB', .T.)

            TRB->TMP_OK 	:= 'S'
			TRB->TMP_ITEM   := (_cAlias)->D2_ITEM
            TRB->TMP_COD 	:= (_cAlias)->D2_COD
            TRB->TMP_DESC  	:= (_cAlias)->B1_DESC
			TRB->TMP_QTDNF  := (_cAlias)->D2_QUANT
			TRB->TMP_UM 	:= (_cAlias)->B1_UM
			If (_cAlias)->B1_QE > 0
            	TRB->TMP_QTD := (_cAlias)->B1_QE
			Else
            	TRB->TMP_QTD := 1
	        EndIf
			TRB->TMP_QTDETQ  := INT((_cAlias)->D2_QUANT/TRB->TMP_QTD)

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

/*/{Protheus.doc} xfat001b
	Função responsavel por gerar a impressão da etiqueta de entrada, chamada pelo PE MT103FIM e via menu MA103OPC.
	@author Claudio Bozzi
	@since 30/06/2022
	@version 1.0
	@param Nil
	@return Nil
/*/
User Function xfat001b()

	Private aArea := GetArea()
    Private nPag  := 0

	Private lAdjustToLegacy := .F.
	Private lDisableSetup  	:= .T.
	Private cLocal          := "\spool"
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
	Private oArial20  := TFont():New("Arial",,20,,.f.,,,,,.f.,.f.)
	Private oArial20N := TFont():New("Arial",,20,,.t.,,,,,.f.,.f.)
	Private oArial30N := TFont():New("Arial",,30,,.t.,,,,,.f.,.f.)

    If oPrinter != Nil
        FwMsgRun(, {|| TratarImp()}, "Executando...", "Executando impressão.")
    EndIf
    
    RestArea(aArea)

Return

Static Function TratarImp()

    Local nX := 0

    BeginSql Alias "TMPETIQ"

        SELECT D2_DOC, D2_SERIE, D2_COD, D2_QUANT, D2_CLIENTE, D2_LOJA, B1_DESC, B1_UM, B1_QE, A1_NOME, F2_VOLUME1, F2_ESPECI1, COALESCE(A4_NOME,"") A4_NOME, D2_PEDIDO, A1_MUN,; 
                A1_EST, A1_CEP, A1_END, A1_BAIRRO, A1_ENDENT, A1_MUNE, A1_ESTE, A1_BAIRROE, A1_CEPE, A1_COMPLEM, A1_COMPENT
		  FROM %Table:SD2% SD2

			INNER JOIN %Table:SF2% SF2
			   ON SF2.F2_FILIAL  = %xFilial:SF2%
			  AND SF2.F2_DOC     = SD2.D2_DOC
			  AND SF2.F2_SERIE   = SD2.D2_SERIE
			  AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
			  AND SF2.F2_LOJA    = SD2.D2_LOJA
			  AND SF2.%NotDel%

			INNER JOIN %Table:SB1% SB1
			   ON SB1.B1_FILIAL = %xFilial:SB1%
			  AND SB1.B1_COD    = SD2.D2_COD
			  AND SB1.%NotDel%

			INNER JOIN %Table:SA1% SA1
			   ON SA1.A1_FILIAL = %xFilial:SA1%
			  AND SA1.A1_COD    = %Exp:cClie%
			  AND SA1.A1_LOJA   = %Exp:cLjClie%
			  AND SA1.%NotDel%

			LEFT JOIN %Table:SA4% SA4
			   ON SA4.A4_FILIAL = %xFilial:SA4%
			  AND SA4.A4_COD    = SF2.F2_TRANSP
			  AND SA4.%NotDel%

			LEFT JOIN %Table:SBZ% SBZ
			   ON SBZ.BZ_FILIAL = %xFilial:SBZ%
			  AND SBZ.BZ_COD    = SD2.D2_COD
			  AND SBZ.%NotDel%

        WHERE SD2.D2_FILIAL  = %xFilial:SD2%
		  AND SD2.D2_DOC  	 = %Exp:cNrNota%
          AND SD2.D2_SERIE   = %Exp:cSerie%
          AND SD2.D2_CLIENTE = %Exp:cClie%
          AND SD2.D2_LOJA    = %Exp:cLjClie%
          AND SD2.%NotDel%
        
        ORDER BY D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_ITEM

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
	Private nCol    := 15

	oPrinter:SetPaperSize(0, 150,100)
	oPrinter:SetMargin(001,001,001,001)
	oPrinter:StartPage()

    oPrinter:SayBitmap( nRow, nCol+180,'\system\etq'+cEmpAnt+cFilAnt+'.png')

    nRow += 15
    oPrinter:Say( nRow, nCol,AllTrim(TMPETIQ->A4_NOME),oArial20N,,,)

    nRow += 30
    oPrinter:Say( nRow, nCol,"DESTINATÁRIO",oArial12,,,)

    nRow += 15
    oPrinter:Say( nRow, nCol,AllTrim(TMPETIQ->A1_NOME),oArial12,,,)

    If ! Empty(TMPETIQ->A1_ENDENT)    
        nRow += 15
        oPrinter:Say( nRow, nCol,SubStr(AllTrim(TMPETIQ->A1_ENDENT),1,24),oArial12,,,)
        nRow += 15
        oPrinter:Say( nRow, nCol,AllTrim(TMPETIQ->A1_BAIRROE),oArial12,,,)
        nRow += 15
        oPrinter:Say( nRow, nCol,"CEP: " + AllTrim(Transform(TMPETIQ->A1_CEPE, "@R 99.999-999")),oArial12,,,)
        nRow += 40
        oPrinter:Say( nRow, nCol,AllTrim(TMPETIQ->A1_MUNE) + "/" + AllTrim(TMPETIQ->A1_ESTE),oArial30N,,,)
    Else
        nRow += 15
        oPrinter:Say( nRow, nCol,SubStr(AllTrim(TMPETIQ->A1_END),1,24),oArial12,,,)
        nRow += 15
        oPrinter:Say( nRow, nCol,AllTrim(TMPETIQ->A1_BAIRRO),oArial12,,,)
        nRow += 15
        oPrinter:Say( nRow, nCol,"CEP: " + AllTrim(Transform(TMPETIQ->A1_CEP, "@R 99.999-999")),oArial12,,,)
        nRow += 40
        oPrinter:Say( nRow, nCol,AllTrim(TMPETIQ->A1_MUN) + " - " + AllTrim(TMPETIQ->A1_EST),oArial30N,,,)
    EndIf

    nRow += 30
    oPrinter:Say( nRow, nCol,"PEDIDO: ",oArial20N,,,)
    oPrinter:Say( nRow, nCol+70,AllTrim(TMPETIQ->D2_PEDIDO),oArial20N,,,)

    nRow += 30
    oPrinter:Say( nRow, nCol,"VOLUME: ",oArial20N,,,)
    oPrinter:Say( nRow, nCol+80,cValToChar(TMPETIQ->F2_VOLUME1),oArial20N,,,)

    nRow += 100
    oPrinter:Line( nRow, nCol, nRow, nCol+240 )
    nRow += 15
    oPrinter:Say( nRow, nCol,'REMETENTE',oArial10N,,,)
    nRow += 15
    oPrinter:Say( nRow, nCol,AllTrim(SM0->M0_NOME),oArial10,,,)
    nRow += 15
    oPrinter:Say( nRow, nCol,AllTrim(SM0->M0_ENDCOB) + " " + AllTrim(SM0->M0_COMPCOB),oArial10,,,)
    nRow += 15
    oPrinter:Say( nRow, nCol,AllTrim(SM0->M0_BAIRCOB) + ", " + AllTrim(SM0->M0_CIDCOB) + " - " + AllTrim(SM0->M0_ESTCOB) + ", " + AllTrim(Transform(SM0->M0_CEPCOB, "@R 99.999-999")),oArial10,,,)

	oPrinter:EndPage()

Return

Static Function GetPrinter()

    Local oPrinter  as Object
    Local oSetup    as Object
    Local cTempFile as Character
    
    cTempFile := "xfat001_" + DtoS(dDataBase) + "_" + StrTran(Time(),":","") + ".pdf"
    
	oPrinter := FWMSPrinter():New(cTempFile, IMP_PDF, .F.,, .T.,, oSetup,, .T.,,, .F.,)

	oPrinter:SetResolution(72)
	oPrinter:SetLandscape()

    oSetup := FWPrintSetup():New( PD_ISTOTVSPRINTER + ;
                                    PD_DISABLEPAPERSIZE + ;
                                    PD_DISABLEMARGIN + ;
                                    PD_DISABLEORIENTATION + ;
                                    PD_DISABLEDESTINATION ;
                                    , "Impressão de Pick List de Pedidos de Venda")

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
