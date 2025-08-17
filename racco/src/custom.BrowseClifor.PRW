#include "totvs.ch"

//----------------------------------------------
/*/{Protheus.doc} BRWSF2
Aparecer nome do cliente / fornecedor na tela de documento de saida CAMPO VIRTUAL

@type function
@version 1.0
@author Consultoria

@since 19/11/2022

@return Character, Nome para Exibição no Browse
/*/
//----------------------------------------------
USER FUNCTION BRWSF2() as Character

	Local cRet as Character

	IF (ALLTRIM(SF2->F2_TIPO) $ "N,C,I,P")
		cRet := Posicione("SA1",1,xFilial("SA1",SF2->F2_FILIAL)+SF2->F2_CLIENTE+SF2->F2_LOJA,"SA1->A1_NOME")
	Else
		cRet := Posicione("SA2",1,xFilial("SA2",SF2->F2_FILIAL)+SF2->F2_CLIENTE+SF2->F2_LOJA,"SA2->A2_NREDUZ")
	Endif

Return cRet

//----------------------------------------------
/*/{Protheus.doc} BRWSF1
Aparecer nome do cliente / fornecedor na tela de documento de entrada CAMPO VIRTUAL

@type function
@version 1.0
@author Consultoria

@since 19/11/2022

@return Character, Nome para Exibição no Browse
/*/
//----------------------------------------------
USER FUNCTION BRWSF1() as Character

	Local cRet as Character

	IF ALLTRIM(SF1->F1_TIPO)$ "D//B"
		cRet := Posicione("SA1",1,xFilial("SA1",SF1->F1_FILIAL)+SF1->F1_FORNECE+SF1->F1_LOJA,"SA1->A1_NOME")
	Else
		cRet := Posicione("SA2",1,xFilial("SA2",SF1->F1_FILIAL)+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_NOME")
	Endif

Return cRet

//----------------------------------------------
/*/{Protheus.doc} BRWPV
Aparecer nome do cliente / fornecedor na tela de pedido de venda CAMPO VIRTUAL

@type function
@version 1.0
@author Consultoria

@since 19/11/2022

@return Character, Nome para Exibição no Browse
/*/
//----------------------------------------------
USER FUNCTION BRWPV() as Character

	Local cRet as Character


	IF ALLTRIM(SC5->C5_TIPO)$ "B//D"
		cRet := Posicione("SA2",1,xFilial("SA2",SC5->C5_FILIAL)+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"SA2->A2_NREDUZ")
	Else
		cRet := Posicione("SA1",1,xFilial("SA1",SC5->C5_FILIAL)+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"SA1->A1_NOME")
	Endif

Return cRet

//----------------------------------------------
/*/{Protheus.doc} NOMSE1
Aparecer nome do cliente na tela de contas a receber

@type function
@version 1.0
@author Consultoria

@since 19/11/2022

@return Character, Nome para Exibição no Browse
/*/
//----------------------------------------------
USER FUNCTION NOMSE1() as Character

	Local cRet as Character

	cRet := Posicione("SA1",1,xFilial("SA1",SE1->E1_FILIAL)+SE1->E1_CLIENTE+SE1->E1_LOJA,"SA1->A1_NOME")

Return cRet

//----------------------------------------------
/*/{Protheus.doc} NOMSE2
Aparecer nome do fornecedor na tela de contas a pagar

@type function
@version 1.0
@author Consultoria

@since 19/11/2022

@return Character, Nome para Exibição no Browse
/*/
//----------------------------------------------
USER FUNCTION NOMSE2() as Character

	Local cRet as Character

	cRet := Posicione("SA2",1,xFilial("SA2",SE2->E2_FILIAL)+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_NOME")

Return cRet

//----------------------------------------------
/*/{Protheus.doc} BRWPC
Aparecer nome do fornecedor na tela de pedido de compra SC7

@type function
@version 1.0
@author Consultoria

@since 19/11/2022

@return Character, Nome para Exibição no Browse
/*/
//----------------------------------------------
USER FUNCTION BRWPC() as Character

	Local cRet as Character

	cRet := Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"SA2->A2_NREDUZ")

Return cRet

//----------------------------------------------
/*/{Protheus.doc} BRWC9
Aparecer descricao do produto na SC9

@type function
@version 1.0
@author Consultoria

@since 19/11/2022

@return Character, Nome para Exibição no Browse
/*/
//----------------------------------------------
USER FUNCTION BRWC9() as Character

	Local cRet as Character

	cRet := Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"SB1->B1_DESC")

Return cRet

//----------------------------------------------
/*/{Protheus.doc} CODPAG
Aparecer descricao condicao de pagamento pedido de venda

@type function
@version 1.0
@author Consultoria

@since 19/11/2022

@return Character, Nome para Exibição no Browse
/*/
//----------------------------------------------
USER FUNCTION CODPAG() as Character

	Local cRet as Character

	cRet := Posicione("SE4",1,xFilial("SE4",SC5->C5_FILIAL)+SC5->C5_CONDPAG,"SE4->E4_DESCRI")

Return cRet

//----------------------------------------------
/*/{Protheus.doc} CPAGF2
Aparecer descricao condicao de pagamento nfesefaz

@type function
@version 1.0
@author Consultoria

@since 19/11/2022

@return Character, Nome para Exibição no Browse
/*/
//----------------------------------------------
USER FUNCTION CPAGF2() as Character

	Local cRet as Character

	cRet := Posicione("SE4",1,xFilial("SE4",SF2->F2_FILIAL)+SF2->F2_COND,"SE4->E4_DESCRI")

Return cRet