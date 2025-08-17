#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include 'totvs.ch'
#Include 'FWMVCDef.ch'
#Include "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "colors.ch"

/*/{Protheus.doc} xqie001a
	Função responsavel por gerar a impressão da etiqueta de retenção
	@type  User Function
	@author Claudio Bozzi
	@since 11/05/2022
	@version 1.0
	@param Nil
	@return Nil
/*/
User Function xqie001a(nOpc)

	Private aArea 		:= GetArea()
	Private aAreaSB1 	:= SB1->(GetArea())
	Private aAreaSD7 	:= SD7->(GetArea())
	Private aAreaSA2 	:= SA2->(GetArea())
	Private nQuant		:= 0
	Private cPerg		:= 'XQIE001A'

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
	Private oArial17N := TFont():New("Arial",,17,,.t.,,,,,.f.,.f.)

	If nOpc = 2
		If MsgYesNo("Deseja imprimir a etiqueta de retenção referente a quantidade total do resultado?", "Etiqueta de Retenção")
			nOpc := 1
		EndIf
	EndIf

    If oPrinter != Nil
	    FwMsgRun(, {|| Impressao(nOpc)}, "Executando...", "Executando impressão.")
	EndIf
	
   	RestArea(aArea)
   	RestArea(aAreaSB1)
   	RestArea(aAreaSD7)
   	RestArea(aAreaSA2)
	
Return

/*/{Protheus.doc} Impressao
	Função para impressão da etiqueta, codigo gerado atraves do BarTender UltaLite, ferramenta grafica para desenho de etiquetas Argox
	@type  Static Function
	@author Claudio Bozzi
	@since 11/05/2022
	@version 1.0
	@param Nil
	@return Nil
/*/
Static Function Impressao(nOpc)

	Local nX        := 0
    Local cArmRet   := GetMV("MV_XARMRET")
    Local cNumCQ    := Left(AllTrim(QEK->QEK_CERFOR),TamSX3('D7_NUMERO')[1])
    Local lImprir   := .F.

	// Posiciona produto
	SB1->(DbSetOrder(1))	//B1_FILIAL + B1_COD
	SB1->(DbSeek(xFilial('SB1') + QEK->QEK_PRODUT ))

	// Posiciona movimentações do CQ
	SD7->(DbSetOrder(1))	//D7_FILIAL + D7_NUMERO + D7_PRODUTO + D7_LOCAL + D7_SEQ + dtos(D7_DATA)
	SD7->(DbSeek(xFilial('SD7') + cNumCQ + QEK->QEK_PRODUT ))

    While xFilial('SD7') + cNumCQ + QEK->QEK_PRODUT == SD7->D7_FILIAL + SD7->D7_NUMERO + SD7->D7_PRODUTO

        If SD7->D7_LOCDEST == cArmRet

            lImprir := .T.

            // Posiciona fornecedor
            SA2->(DbSetOrder(1))	//A2_FILIAL + A2_COD + A2_LOJA
            SA2->(MsSeek(xFilial('SB1') + SD7->D7_FORNECE + SD7->D7_LOJA ))

            If nOpc = 2
                MsgAlert("Defina as quantidades a serem impressas para o produto: " + SD7->D7_PRODUTO,"Atenção")
                If ! Pergunte(cPerg,.T.) // Pergunta no SX1
                    SD7->(DBSkip())
                    Loop
                EndIf
            EndIf

            If nOpc = 2 .And. MV_PAR01 > 0
                nQuant := MV_PAR02
                For nX := 1 To MV_PAR01
                    MontarImp()
                Next
            Else
                nQuant := SD7->D7_QTDE
                MontarImp()
            EndIf

        EndIf

        SD7->(dbSkip())

    EndDo

    If lImprir
        oPrinter:Preview()
    EndIf

Return

Static Function MontarImp()

    Private nRow    := 20
	Private nCol    := 5

	oPrinter:SetPaperSize(0, 25,85)
	oPrinter:SetMargin(001,001,001,001)
	oPrinter:StartPage()

    oPrinter:SayBitmap( nRow, nCol+180,'\system\etq'+cEmpAnt+cFilAnt+'.png')

    oPrinter:Say( nRow+5, nCol,"RETENÇÃO FISICO-QUÍMICA",oArial12N,,,)

    nRow += 15
    oPrinter:Say( nRow, nCol,AllTrim(QEK->QEK_PRODUT),oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,AllTrim(SB1->B1_DESC),oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,AllTrim(SA2->A2_NOME),oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,AllTrim(SD7->D7_LOTECTL) + " - " + dtoc(SD7->D7_DTVALID),oArial12,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,cValToChar(SD7->D7_QTDE),oArial12,,,)

	oPrinter:EndPage()

Return

Static Function GetPrinter()

    Local oPrinter  as Object
    Local oSetup    as Object
    Local cTempFile as Character
    
    cTempFile := "xpcp001_" + DtoS(dDataBase) + "_" + StrTran(Time(),":","") + ".pdf"
    
	oPrinter := FWMSPrinter():New(cTempFile, IMP_PDF, .F.,, .T.,, oSetup,, .T.,,, .F.,)

	oPrinter:SetResolution(72)
	oPrinter:SetLandscape()

    oSetup := FWPrintSetup():New( PD_ISTOTVSPRINTER + ;
                                    PD_DISABLEPAPERSIZE + ;
                                    PD_DISABLEMARGIN + ;
                                    PD_DISABLEORIENTATION + ;
                                    PD_DISABLEDESTINATION ;
                                    , "Impressão de Etiqueta de Produção")

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
