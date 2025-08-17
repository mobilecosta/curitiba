#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include 'totvs.ch'
#Include 'FWMVCDef.ch'
#Include "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "colors.ch"

/*/{Protheus.doc} xacd001a
	Função responsavel por gerar a impressão da etiqueta de separação
	@type  User Function
	@author Claudio Bozzi
	@since 11/05/2022
	@version 1.0
	@param Nil
	@return Nil
/*/
User Function xacd001a(nOpc)

	Private aArea 		:= GetArea()
	Private aAreaSB1 	:= SB1->(GetArea())
	Private aAreaSD7 	:= SD7->(GetArea())
	Private aAreaSA2 	:= SA2->(GetArea())
	Private nQuant		:= 0
	Private cPerg		:= 'XACD001A'

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
		If MsgYesNo("Deseja imprimir a etiqueta de separação referente a quantidade total?", "Etiqueta de Separação")
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

	// Posiciona produto
	CB8->(DbSetOrder(1))	//CB8_FILIAL + CB8_ORDSEP + CB8_ITEM + CB8_SEQUEN + CB8_PROD
	CB8->(DbSeek(xFilial('CB8') + CB7->CB7_ORDSEP ))

    While CB7->CB7_FILIAL + CB7->CB7_ORDSEP == CB8->CB8_FILIAL + CB8->CB8_ORDSEP

        // Posiciona produto
        SB1->(DbSetOrder(1))	//B1_FILIAL + B1_COD
        SB1->(DbSeek(xFilial('SB1') + CB8->CB8_PROD ))

        If nOpc = 2
            MsgAlert("Defina as quantidades a serem impressas para o produto: " + CB8->CB8_PROD,"Atenção")
            If ! Pergunte(cPerg,.T.) // Pergunta no SX1
                CB8->(DBSkip())
                Loop
            EndIf
        EndIf

        If nOpc = 2 .And. MV_PAR01 > 0
            For nX := 1 To MV_PAR01
                MontarImp()
            Next
        Else
            MontarImp()
        EndIf

        CB8->(DBSkip())

    EndDo

    oPrinter:Preview()

Return

Static Function MontarImp()

    Private nRow    := 20
	Private nCol    := 5

	oPrinter:SetPaperSize(0, 25,85)
	oPrinter:SetMargin(001,001,001,001)
	oPrinter:StartPage()

    oPrinter:SayBitmap( nRow, nCol+180,'\system\etq'+cEmpAnt+cFilAnt+'.png')

    oPrinter:Say( nRow+5, nCol,"OP: ",oArial10N,,,)
    oPrinter:Say( nRow+5, nCol+20,AllTrim(CB8->CB8_OP),oArial10,,,)

    oPrinter:Say( nRow+5, nCol+80,"CÓD MP: ",oArial10N,,,)
    oPrinter:Say( nRow+5, nCol+120,AllTrim(CB8->CB8_PROD),oArial10,,,)

    nRow += 15
    oPrinter:Say( nRow, nCol,"LOTE MP: ",oArial10N,,,)
    oPrinter:Say( nRow, nCol+40,AllTrim(CB8->CB8_LOTECT),oArial10,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,"DESCR. MP: ",oArial10N,,,)
    oPrinter:Say( nRow, nCol+50,AllTrim(SB1->B1_DESC),oArial10,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,"QTD PESADA: ___________________  TARA: __________",oArial10,,,)

    // Posiciona OP
    SC2->(DbSetOrder(1))	//C2_FILIAL + C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD
    SC2->(DbSeek(xFilial('SC2') + CB8->CB8_OP ))

    // Posiciona produto
    SB1->(DbSetOrder(1))	//B1_FILIAL + B1_COD
    SB1->(DbSeek(xFilial('SB1') + SC2->C2_PRODUTO ))

    nRow += 10
    oPrinter:Say( nRow, nCol,"PROD. OP: ",oArial10N,,,)
    oPrinter:Say( nRow, nCol+45,AllTrim(SC2->C2_PRODUTO) + " " + SB1->B1_DESC,oArial10,,,)

    nRow += 10
    oPrinter:Say( nRow, nCol,"ASS: _______________________    CONF: _____________",oArial10,,,)

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
