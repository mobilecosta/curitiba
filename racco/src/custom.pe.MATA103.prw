#include "totvs.ch"

//----------------------------------------------
/*/{Protheus.doc} MT103IPC
PREENCHIMENTO CAMPOS ESPECIFICOS DOCUMENTO DE ENTRADA
Preenche Descrição do Produto e NCM no Documento de Entrada

@type function
@author SOLVS
@version 1.0

@since 24/06/2015

@see https://tdn.totvs.com/display/public/PROT/MT103IPC+-+Atualiza+campos+customizados+no+Documento+de+Entrada
/*/
//----------------------------------------------
User Function MT103IPC() as Logical

	Local aAreaSC7  as Array
	Local _nItem    as Numeric
	Local _nPosDesc as Numeric
	Local _nPosPrd  as Numeric
	Local _nPosIpi	as Numeric

	Local lRet as Logical

	lRet := .t.

	_nItem    := Paramixb[1]
	_nPosDesc := aScan(aHeader, { |x| AllTrim(x[2]) == "D1_XDESCPR"	})
	_nPosPrd  := aScan(aHeader, { |x| AllTrim(x[2]) == "D1_COD"		})
	_nPosIpi  := aScan(aHeader, { |x| AllTrim(x[2]) == "D1_XPOSIPI"	})

	aAreaSC7 := SC7->(GetArea())

	aCols[_nItem,_nPosDesc] := POSICIONE("SB1",1,XFILIAL("SB1")+aCols[_nItem,_nPosPrd],"B1_DESC")
	aCols[_nItem,_nPosIpi ] := SB1->B1_POSIPI

	RestArea(aAreaSC7)

Return lRet

/*/{Protheus.doc} User Function MT103FIM
    O ponto de entrada MT103FIM encontra-se no final da função A103NFISCAL.
    Após o destravamento de todas as tabelas envolvidas na gravação do documento de entrada, depois de fechar a operação realizada neste.
    É utilizado para realizar alguma operação após a gravação da NFE.
    @type  Function
    @author Claudio Bozzi
    @since 11/05/2022
    @version 1.0
    @param Nil
    @return Nil
    @see https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=6085406
    /*/
User Function MT103FIM()

    If l103Class
        u_xcom001a()
    EndIf

Return nil

/*/{Protheus.doc} User Function MA103OPC
    Ponto de Entrada utilizado para adicionar itens no menu
    @type  Function
    @author Claudio Bozzi
    @since 11/05/2022
    @version 1.0
    @param Nil
    @return aRet(vetor) Array contendo dados do novo item do menu.
    @see https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=6085341
    /*/
User Function MA103OPC()

    Local aRet := {}

    aAdd(aRet,{'Etiqueta Entrada', 'u_xcom001a()', 0, 2})
    
Return aRet
