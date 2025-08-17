#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include 'totvs.ch'
#Include 'FWMVCDef.ch'
#Include "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "colors.ch"

/*/{Protheus.doc} xpcp001a
	Função responsavel por gerar a impressão da etiqueta de produção, chamada pelo PE FISTRFNFE.
	@type  User Function
	@author Claudio Bozzi
	@since 11/05/2022
	@version 1.0
	@param Nil
	@return Nil
/*/
User Function xpcp001a(nOpc)

    Local aPergs := {}

	Private aArea 		:= GetArea()
	Private aAreaSB1 	:= SB1->(GetArea())
	Private aAreaSB8 	:= SB8->(GetArea())
	Private nQuant		:= 0
	Private cPerg		:= 'XPCP001A'

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
	Private oArial12N := TFont():New("Arial Black",,12,,.t.,,,,,.f.,.f.)
	Private oArial15  := TFont():New("Arial",,15,,.f.,,,,,.f.,.f.)
	Private oArial15N := TFont():New("Arial",,15,,.t.,,,,,.f.,.f.)
	Private oArial17N := TFont():New("Arial",,17,,.t.,,,,,.f.,.f.)

    aAdd(aPergs, {1, "Quantidade",  nQuant,  "@E 9,999",     "", "", ".T.", 80,  .F.})

	If nOpc = 2
		If MsgYesNo("Deseja imprimir a etiqueta de produção referente a quantidade total do apontamento?", "Etiqueta de Produção")
			nOpc := 1
        elseif !ParamBox(aPergs, "Informe os parâmetros")
			Return
		EndIf
	EndIf

    If oPrinter != Nil
	    FwMsgRun(, {|| Impressao(nOpc)}, "Executando...", "Executando impressão.")
	EndIf
	
   	RestArea(aArea)
   	RestArea(aAreaSB1)
   	RestArea(aAreaSB8)
	
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

	Local nX := 0

	// Posiciona produto
	SB1->(DbSetOrder(1))	//B1_FILIAL + B1_COD
	SB1->(MsSeek(xFilial('SB1') + SH6->H6_PRODUTO ))

	// Posiciona saldos por lote
	SB8->(DbSetOrder(3))	//B8_FILIAL + B8_PRODUTO + B8_LOCAL + B8_LOTECTL + B8_NUMLOTE + DTOS(B8_DTVALID)
	SB8->(MsSeek(xFilial('SB8') + SH6->H6_PRODUTO + SH6->H6_LOCAL + SH6->H6_LOTECTL + SH6->H6_NUMLOTE))

	If nOpc = 2
        nQuant := MV_PAR01
		For nX := 1 To MV_PAR01
			If AllTrim(SB1->B1_TIPO) = 'PI'
				MontarImp()
			ElseIf AllTrim(SB1->B1_TIPO) = 'PA'
				MontarImp2()
			EndIf
		Next
	Else
		nQuant := SD3->D3_QUANT
		If AllTrim(SB1->B1_TIPO) = 'PI'
			MontarImp()
		ElseIf AllTrim(SB1->B1_TIPO) = 'PA'
			MontarImp2()
		EndIf
	EndIf

    oPrinter:Preview()

Return

Static Function MontarImp()

    Local nLin1     := 0
    Local nCol1     := 0
    Local n1        := 0
    Local n2        := 0
    Local nHor      := 0
    Local nVer      := 0
    Local nDiv01    := 0
    Local n3        := 0
    Local n4        := 0
    Local nLin2     := 0
    Local nCol2     := 0
    Local nLin3     := 0
    Local nCol3     := 0
    Local nLin4     := 0
    Local nCol4     := 0
    Local nLin5     := 0
    Local nCol5     := 0
    Local nLin6     := 0
    Local nCol6     := 0
    Local nLin7     := 0
    Local nCol7     := 0
    Local nLin8     := 0
    Local nCol8     := 0
    Local nLin9     := 0
    Local nCol9     := 0
    Local nLin10    := 0
    Local nCol10    := 0
    Local nLin11    := 0
    Local nCol11    := 0
    Local nAlt      := 0
    Local nLarg     := 0
    Local nLin12    := 0
    Local nCol12    := 0
    Local nLin13    := 0
    Local nCol13    := 0
    Local nLin14    := 0
    Local nCol14    := 0
    Local nLin15    := 0
    Local nCol15    := 0
    Local nLin16    := 0
    Local nCol16    := 0
    Local nLin17    := 0
    Local nCol17    := 0
    Local nLin18    := 0
    Local nCol18    := 0
    Local nLin19    := 0
    Local nCol19    := 0
    Local nLin20    := 0
    Local nCol20    := 0
    Local nLin21    := 0
    Local nCol21    := 0
    Local nLin22    := 0
    Local nCol22    := 0
    Local nLin23    := 0
    Local nCol23    := 0
    Local nLin24    := 0
    Local nCol24    := 0
    Local nLin25    := 0
    Local nCol25    := 0
    Local nLin26    := 0
    Local nCol26    := 0
    Local nLin27    := 0
    Local nCol27    := 0
    Local nLin28    := 0
    Local nCol28    := 0
    Local nLin29    := 0
    Local nCol29    := 0
    Local nLin30    := 0
    Local nCol30    := 0
    Local nLin31    := 0
    Local nCol31    := 0
    Local nLin32    := 0
    Local nCol32    := 0

    Private nRow    := 40
	Private nCol    := 15

    IF !ExistDir("C:\temp\",, .F.)
        MakeDir("C:\temp\",, .F.)
    EndIf

    oPrinter:cPathPDF := "c:\temp\"
	oPrinter:SetPaperSize(0, 150,100)
	oPrinter:SetMargin(001,001,001,001)
	oPrinter:StartPage()

    nLin1 := 10
    nCol1 := nCol+5
    n1 := 250
    n2 := 20
    nHor := 2
    nVer := 0
    oPrinter:SayAlign(nLin1, nCol1,Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_FILIAL" } )[1,2]),oArial12,n1,n2,,nHor,nVer)

    nDiv01 := 140

    n1 := 20
    n2 := nDiv01
    n3 := 600
    n4 := nDiv01
    
    nRow += 30
    nLin2 := nRow+5
    nCol2 := 5

    n1 := nDiv01
    n2 := 20
    nHor := 2
    nVer := 0
    oPrinter:SayAlign(nLin2, nCol2,"PRODUÇÃO",oArial12n,n1,n2,,nHor,nVer)

    nRow += 23
    nLin3 := nRow
    nCol3 := 5
    oPrinter:SayAlign(nLin3, nCol3, AllTrim(SH6->H6_PRODUTO),oArial12,n1,n2,,nHor,nVer)

    nRow += 23
    nLin4 := nRow
    nCol4 := 5
    oPrinter:SayAlign(nLin4, nCol4, AllTrim(SB1->B1_DESC),oArial12,n1,n2,,nHor,nVer)

    nRow += 23
    nLin5 := nRow
    nCol5 := 5
    oPrinter:SayAlign(nLin5, nCol5, AllTrim(SH6->H6_LOTECTL),oArial12,n1,n2,,nHor,nVer)

    nRow += 23
    nLin6 := nRow
    nCol6 := 5
    oPrinter:SayAlign(nLin6, nCol6,  dToC(SB8->B8_DTVALID),oArial12,n1,n2,,nHor,nVer)

    nRow += 23
    nLin7 := nRow
    nCol7 := 5
    oPrinter:SayAlign(nLin7, nCol7, "Quant: "+AllTrim(cValToChar(nQuant)),oArial12,n1,n2,,nHor,nVer)

    nLin8 := 6
    nCol8 := 12
    nLin9 := 115
    nCol9 := nDiv01 + 10
    oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,nLin8/*nRow*/ ,nCol8/*nCol*/, AllTrim(SH6->H6_PRODUTO)/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.T./*lHorz*/,0.0164/*nWidth*/,0.8/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)
    oPrinter:Say( nLin9, nCol9,AllTrim(SH6->H6_PRODUTO),oArial12,,,)

    nLin10 := 11
    nCol10 := 12
    nLin11 := 178
    nCol11 := nDiv01 + 10
    nAlt := 1
    nLarg := 0.0164
    oPrinter:FWMSBAR("CODE128" /*cTypeBar*/, nLin10 /*nRow*/ ,nCol10/*nCol*/, AllTrim(SH6->H6_LOTECTL)/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.T./*lHorz*/,0.0164/*nWidth*/,0.8/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)
    oPrinter:Say( nLin11, nCol11,AllTrim(SH6->H6_LOTECTL),oArial12,,,)

    nLin12 := 16
    nCol12 := 12
    nLin13 := 241
    nCol13 := nDiv01 + 10
    oPrinter:FWMSBAR("CODE128" /*cTypeBar*/, nLin12/*nRow*/ ,nCol12/*nCol*/, AllTrim(cValToChar(nQuant))/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.T./*lHorz*/,0.0164/*nWidth*/,0.8/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)
    oPrinter:Say( nLin13, nCol13,AllTrim(cValToChar(nQuant)),oArial12,,,)

    nRow += 80

    nLin14 := nRow
    nCol14 := nCol
    nLin15 := nRow
    nCol15 := nCol+125
    oPrinter:Say( nLin14, nCol14,"ORDEM DE PRODUÇÃO: ",oArial12N,,,)
    oPrinter:Say( nLin15, nCol15,AllTrim(SH6->H6_OP),oArial12,,,)
    
    nRow += 10

    nLin16 := nRow
    nCol16 := nCol
    nLin17 := nRow
    nCol17 := nCol+35
    oPrinter:Say( nLin16, nCol16,"LOTE: ",oArial12N,,,)
    oPrinter:Say( nLin17, nCol17,AllTrim(SH6->H6_LOTECTL),oArial12,,,)

    nRow += 10

    nLin18 := nRow
    nCol18 := nCol
    nLin19 := nRow
    nCol19 := nCol+60
    oPrinter:Say( nLin18, nCol18,"VALIDADE: ",oArial12N,,,)
    oPrinter:Say( nLin19, nCol19,dToC(SB8->B8_DTVALID),oArial12,,,)

    nRow += 10

    nLin20 := nRow
    nCol20 := nCol
    nLin21 := nRow
    nCol21 := nCol+35
    oPrinter:Say( nLin20, nCol20,"DATA: ",oArial12N,,,)
    oPrinter:Say( nLin21, nCol21,dToC(SH6->H6_DTPROD),oArial12,,,)

    nRow += 10

    nLin22 := nRow
    nCol22 := nCol
    nLin23 := nRow
    nCol23 := nCol+80
    oPrinter:Say( nLin22, nCol22,"QUANTIDADE: ",oArial12N,,,)
    oPrinter:Say( nLin23, nCol23,AllTrim(cValToChar(nQuant)),oArial12,,,)

    nRow += 10

    nLin24 := nRow
    nCol24 := nCol
    nLin25 := nRow
    nCol25 := nCol+105
    oPrinter:Say( nLin24, nCol24,"CÓDIGO PRODUTO: ",oArial12N,,,)
    oPrinter:Say( nLin25, nCol25,AllTrim(SH6->H6_PRODUTO),oArial12,,,)

    nRow += 10

    nLin26 := nRow
    nCol26 := nCol
    nLin27 := nRow
    nCol27 := nCol+70
    oPrinter:Say( nLin26, nCol26, "DESCRIÇÃO: ",oArial12N,,,)
    oPrinter:Say( nLin27, nCol27, SubStr(AllTrim(SB1->B1_DESC),1,24),oArial12,,,)

    nRow += 10

    nLin28 := nRow
    nCol28 := nCol
    nLin29 := nRow
    nCol29 := nCol+25
    oPrinter:Say( nLin28, nCol28,"UM: ",oArial12N,,,)
    oPrinter:Say( nLin29, nCol29,AllTrim(SB1->B1_UM),oArial12,,,)

    nRow += 10

    nLin30 := nRow
    nCol30 := nCol
    nLin31 := nRow
    nCol31 := nCol+35
    oPrinter:Say( nLin30, nCol30,"TIPO: ",oArial12N,,,)
    oPrinter:Say( nLin31, nCol31,AllTrim(SB1->B1_TIPO),oArial12,,,)

    nLin32 := 380
    nCol32 := nCol+5
    n1 := 250
    n2 := 20
    nHor := 2
    nVer := 0
    oPrinter:SayAlign(nLin32, nCol32, "---------------------------------------------------------------",oArial12,n1,n2,,nHor,nVer)
    oPrinter:SayAlign(nLin32+10, nCol32, "RESPONSÁVEL FÍSICO QUÍMICO",oArial12,n1,n2,,nHor,nVer)

	oPrinter:EndPage()

Return

Static Function MontarImp2()

    Local nDiv01    := 0
    Local nAltlin   := 0
    Local nLin1     := 0
    Local nCol1     := 0
    Local n1        := 0
    Local n2        := 0
    Local nHor      := 0
    Local nVer      := 0
    Local nLin3     := 0
    Local nCol3     := 0
    Local nLin4     := 0
    Local nCol4     := 0
    Local nLin5     := 0
    Local nCol5     := 0
    Local nLin6     := 0
    Local nCol6     := 0
    Local nLin7     := 0
    Local nCol7     := 0
    Local nLin8     := 0
    Local nCol8     := 0
    Local nLin9     := 0
    Local nCol9     := 0
    Local nLin10    := 0
    Local nCol10    := 0
    Local nLin11    := 0
    Local nCol11    := 0
    Local nAlt      := 0
    Local nLarg     := 0
    Local nLin12    := 0
    Local nCol12    := 0
    Local nLin13    := 0
    Local nCol13    := 0

    Private nRow    := 5
	Private nCol    := 5

    IF !ExistDir("C:\temp\",, .F.)
        MakeDir("C:\temp\",, .F.)
    EndIf

    oPrinter:cPathPDF := "c:\temp\"
	oPrinter:SetPaperSize(0, 50, 95)
	oPrinter:SetMargin(001,001,001,001)
	oPrinter:StartPage()

    nDiv01 := 130
    nAltlin := 18

    nLin1 := 5
    nCol1 := nCol+5
    n1 := 250
    n2 := 20
    nHor := 2
    nVer := 0
    oPrinter:SayAlign(nLin1, nCol1,Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_FILIAL" } )[1,2]),oArial10,n1,n2,,nHor,nVer)

    nRow += nAltlin + 6
    nLin3 := nRow
    nCol3 := 5
    n1 := 120
    oPrinter:SayAlign(nLin3, nCol3, AllTrim(SH6->H6_PRODUTO),oArial12,n1,n2,,nHor,nVer)

    nRow += nAltlin

    nLin4 := nRow
    nCol4 := 5
    oPrinter:SayAlign(nLin4, nCol4, AllTrim(SB1->B1_DESC),oArial12,n1,n2,,nHor,nVer)

    if oPrinter:GetTextWidth(AllTrim(SB1->B1_DESC),oArial12,1) > 200
        nRow += nAltLin
    endif

    nRow += nAltlin

    nLin5 := nRow
    nCol5 := 5
    oPrinter:SayAlign(nLin5, nCol5, AllTrim(SH6->H6_LOTECTL),oArial12,n1,n2,,nHor,nVer)

    nRow += nAltlin

    nLin6 := nRow
    nCol6 := 5
    oPrinter:SayAlign(nLin6, nCol6,  dToC(SB8->B8_DTVALID),oArial12,n1,n2,,nHor,nVer)

    nRow += nAltlin

    nLin7 := nRow
    nCol7 := 5
    oPrinter:SayAlign(nLin7, nCol7, "Quant: "+AllTrim(cValToChar(nQuant)),oArial12,n1,n2,,nHor,nVer)


    nLin8 := 2
    nCol8 := 10
    nLin9 := 47
    nCol9 := nDiv01 + 3


    oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,nLin8/*nRow*/ ,nCol8/*nCol*/, AllTrim(SH6->H6_PRODUTO)/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.T./*lHorz*/,0.0164/*nWidth*/,0.6/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)
    oPrinter:SayAlign(nLin9, nCol9, AllTrim(SH6->H6_PRODUTO),oArial12,n1,n2,,nHor,nVer)

    nLin10 := 5
    nCol10 := 10
    nLin11 := 83
    nCol11 := nDiv01 + 3
    nAlt := 1
    nLarg := 0.7
    oPrinter:FWMSBAR("CODE128" /*cTypeBar*/, nLin10 /*nRow*/ ,nCol10/*nCol*/, AllTrim(SH6->H6_LOTECTL)/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.T./*lHorz*/,0.0164/*nWidth*/,0.6/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,nLarg/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)
    oPrinter:SayAlign(nLin11, nCol11,AllTrim(SH6->H6_LOTECTL),oArial12,n1,n2,,nHor,nVer)

    nLin12 := 8
    nCol12 := 10
    nLin13 := 120
    nCol13 := nDiv01 + 3
    oPrinter:FWMSBAR("CODE128" /*cTypeBar*/, nLin12/*nRow*/ ,nCol12/*nCol*/, AllTrim(cValToChar(nQuant))/*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.T./*lHorz*/,0.0164/*nWidth*/,0.6/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)
    oPrinter:SayAlign(nLin13, nCol13, AllTrim(cValToChar(nQuant)),oArial12,n1,n2,,nHor,nVer)
    
    oPrinter:EndPage()

Return

Static Function GetPrinter()

    Local oPrinter  as Object
    Local oSetup    as Object
    Local cTempFile as Character
    
    cTempFile := "xpcp001_" + DtoS(dDataBase) + "_" + StrTran(Time(),":","") + ".pdf"
    
	oPrinter := FWMSPrinter():New(cTempFile, IMP_PDF, .F.,"C:\temp", .T.,, oSetup,, .T.,,, .F.,)

	oPrinter:SetResolution(72)
	oPrinter:SetPortrait()

    oSetup := FWPrintSetup():New( PD_ISTOTVSPRINTER + ;
                                    PD_DISABLEPAPERSIZE + ;
                                    PD_DISABLEMARGIN + ;
                                    PD_DISABLEORIENTATION + ;
                                    PD_DISABLEDESTINATION ;
                                    , "Impressão de Etiqueta de Produção")

    oSetup:SetPropert(PD_PRINTTYPE   , 6 ) //PDF
    oSetup:SetPropert(PD_ORIENTATION , 1 ) //Paisagen

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
