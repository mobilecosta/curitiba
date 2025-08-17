#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include 'totvs.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} User Function telaCQ
    Tela para seleção dos itens a serem aprovados/rejeitados com markBrowse
    @type  Function
    @author Claudio Bozzi
    @since 16/10/2023
    @version 2210
    /*/
User Function xcq001a()

	Local aArea   := GetArea()

    Private aCpoInfo  := {}
    Private aCampos   := {}
    Private aCpoData  := {}
    Private oTable    := Nil
    Private oBrowse   := Nil
    Private aRotBKP   := {}

	Private cProduto  As Character 
	Private cLote     As Character 

	Private aTexto  := {}
	Private nQuant  := 0
	Private nCaixas := 0
	Private nResto  := 0
	Private cEnter  := Chr(13) + Chr(10)

	cProduto := SD7->D7_PRODUTO
	cLote	 := SD7->D7_LOTECTL

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

	oBrowse:acolumns[6]:ledit    := .T. // informa qual coluna é editável
	oBrowse:acolumns[6]:cReadVar := 'TMP_QTD'

	oBrowse:AddButton("Aprovar"	,"u_xcq001b(1)",,1)
	oBrowse:AddButton("Rejeitar","u_xcq001b(2)",,1)

    oBrowse:SetMenuDef('custom.xcq001')

    oBrowse:SetDescription('Seleção de itens para liberação/rejeição')
    
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
    
    Local cNumeroAnt := ''
    Local cSaldo     := ''
    Local cLocal     := ''
    Local cNrTr      := ''
    Local cLocDest   := ''
    Local cDoc       := ''
    Local cSerie     := ''
    Local nRecno     := 0

    If(Type('oTable') <> 'U')
        oTable:Delete()
        oTable := Nil
    Endif

    oTable := FwTemporaryTable():New('TRB')

    aCampos  := {}
    aCpoInfo := {}
    aCpoData := {}

    aAdd(aCpoInfo, {'Marcar'  		, '@!' 						, 1							})
    aAdd(aCpoInfo, {'Produto'		, '@!' 						, TamSx3('D7_PRODUTO')[1]	})
    aAdd(aCpoInfo, {'Lote'		    , '@!' 						, TamSx3('D7_LOTECTL')[1]	})
    aAdd(aCpoInfo, {'Numero'	    , '@!' 						, TamSx3('D7_NUMERO')[1]	})
    aAdd(aCpoInfo, {'Saldo'  		, '@E 99,999,999,999.9999' 	, TamSx3('D7_SALDO')[1]		})
    aAdd(aCpoInfo, {'Quantidade'    , '@E 99,999,999,999.9999' 	, TamSx3('D7_QTDE')[1]	    })
    aAdd(aCpoInfo, {'Local'     	, '@!'	                    , TamSx3('D7_LOCAL')[1]		})
    aAdd(aCpoInfo, {'Local Dest.'   , '@!' 						, TamSx3('D7_LOCDEST')[1]	})
    aAdd(aCpoInfo, {'Documento'	    , '@!' 		                , TamSx3('D7_DOC')[1]	    })
    aAdd(aCpoInfo, {'Serie'         , '!!!' 				    , TamSx3('D7_SERIE')[1] 	})
    aAdd(aCpoInfo, {'recno'         , '@E 9999999999999'		, 13 	                    })

    aAdd(aCpoData, {'TMP_OK'      , 'C'                     , 1                       	, 0							})
    aAdd(aCpoData, {'TMP_PROD' 	  , TamSx3('D7_PRODUTO')[3]	, TamSx3('D7_PRODUTO')[1] 	, 0							})
    aAdd(aCpoData, {'TMP_LOTE' 	  , TamSx3('D7_LOTECTL')[3]	, TamSx3('D7_LOTECTL')[1] 	, 0							})
    aAdd(aCpoData, {'TMP_NRTR' 	  , TamSx3('D7_NUMERO')[3]	, TamSx3('D7_NUMERO')[1] 	, 0							})
    aAdd(aCpoData, {'TMP_SLD'  	  , TamSx3('D7_SALDO')[3] 	, TamSx3('D7_SALDO')[1] 	, TamSx3('D7_SALDO2')[2]	})
    aAdd(aCpoData, {'TMP_QTD'     , TamSx3('D7_QTDE')[3]    , TamSx3('D7_QTDE')[1]      , TamSx3('D7_QTDE')[2]	    })
    aAdd(aCpoData, {'TMP_LOCAL'	  , TamSx3('D7_LOCAL')[3]   , TamSx3('D7_LOCAL')[1] 	, 0		                    })
    aAdd(aCpoData, {'TMP_LOCDES'  , TamSx3('D7_LOCDEST')[3]	, TamSx3('D7_LOCDEST')[1] 	, 0							})
    aAdd(aCpoData, {'TMP_DOC'  	  , TamSx3('D7_DOC')[3]     , TamSx3('D7_DOC')[1] 	    , 0	                        })
    aAdd(aCpoData, {'TMP_SERIE'   , TamSx3('D7_SERIE')[3]   , TamSx3('D7_SERIE')[1]   	, 0							})
    aAdd(aCpoData, {'TMP_RECNO'   , 'N'                     , 13   	                    , 0							})

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

        SELECT D7_SEQ, D7_NUMERO, D7_PRODUTO, D7_LOTECTL, D7_SALDO, D7_QTDE, D7_LOCAL, D7_LOCDEST, D7_DOC, D7_SERIE, R_E_C_N_O_ AS RECNO
          FROM %TABLE:SD7% SD7
         WHERE SD7.D7_FILIAL  = %xFilial:SD7%
           AND SD7.D7_PRODUTO = %Exp:cProduto%
           AND SD7.D7_LOTECTL = %Exp:cLote%
           AND SD7.D7_SALDO   > 0
           AND SD7.D7_LIBERA = ''
           AND SD7.%NOTDEL%
        ORDER BY D7_NUMERO, D7_SEQ
    EndSQL

    (_cAlias)->(DbGoTop())

    DbSelectArea('TRB')

    cNumeroAnt := ''

    If ! (_cAlias)->(EoF())

        cNumeroAnt := (_cAlias)->D7_NUMERO

        cProduto    := (_cAlias)->D7_PRODUTO
        cLote       := (_cAlias)->D7_LOTECTL
        cNrTr       := (_cAlias)->D7_NUMERO
        cSaldo      := (_cAlias)->D7_SALDO
        cLocal      := (_cAlias)->D7_LOCAL
        cLocDest    := (_cAlias)->D7_LOCDEST
        cDoc        := (_cAlias)->D7_DOC
        cSerie      := (_cAlias)->D7_SERIE
        nRecno      := (_cAlias)->RECNO

    EndIf

    While ! (_cAlias)->(EoF())

        (_cAlias)->(DbSkip())

        If cNumeroAnt == (_cAlias)->D7_NUMERO

            cSaldo      := (_cAlias)->D7_SALDO

        Else

            RecLock('TRB', .T.)

                TRB->TMP_OK 	 := 'S'
                TRB->TMP_PROD    := cProduto
                TRB->TMP_LOTE    := cLote
                TRB->TMP_NRTR    := cNrTr
                TRB->TMP_SLD 	 := cSaldo
                TRB->TMP_QTD  	 := cSaldo
                TRB->TMP_LOCAL   := cLocal
                TRB->TMP_LOCDES  := cLocDest
                TRB->TMP_DOC     := cDoc
                TRB->TMP_SERIE   := cSerie
                TRB->TMP_RECNO   := nRecno

            TRB->(MsUnlock())

            cNumeroAnt := (_cAlias)->D7_NUMERO

            cProduto    := (_cAlias)->D7_PRODUTO
            cLote       := (_cAlias)->D7_LOTECTL
            cNrTr       := (_cAlias)->D7_NUMERO
            cSaldo      := (_cAlias)->D7_SALDO
            cLocal      := (_cAlias)->D7_LOCAL
            cLocDest    := (_cAlias)->D7_LOCDEST
            cDoc        := (_cAlias)->D7_DOC
            cSerie      := (_cAlias)->D7_SERIE
            nRecno      := (_cAlias)->RECNO

        EndIf

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

/*/{Protheus.doc} xcq001b
	Função responsavel por gerar a impressão da etiqueta de entrada, chamada pelo PE MT103FIM e via menu MA103OPC.
	@author Claudio Bozzi
	@since 30/06/2022
	@version 1.0
	@param Nil
	@return Nil
/*/
User Function xcq001b(nOpc)

	Local aArea := GetArea()

    FwMsgRun(, {|| AtuCQ(nOpc)}, "Executando...", "Executando atualização.")

    RestArea(aArea)

Return

/*/{Protheus.doc} User Function AtuCQ
    (long_description)
    @type  Function
    @author Claudio Bozzi
    @since 13/10/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Static Function AtuCQ(nOpc)

	Local aAreaSD7 := SD7->(GetArea())
	Local aAreaSB2 := SB2->(GetArea())
	Local aAreaSB1 := SB1->(GetArea())

    Private lMsErroAuto := .F.

    TRB->(DBGoTop())

	Do While ! TRB->(Eof())

        If TRB->TMP_OK = 'S'
        
            SD7->( dbGoTo(TRB->TMP_RECNO) )

            //Cria armazem para o produto caso não exista
            SB2->(dbSelectArea("SB2"))
            SB2->(dbGoTop() )
            SB2->(dbSeek(xFilial("SB2") + TRB->TMP_PROD + TRB->TMP_LOCDES ) )
                
            If ! SB2->(Found())
                CriaSB2(TRB->TMP_PROD,TRB->TMP_LOCDES)
            EndIf

            SB1->( dbSetOrder(1) )
            SB1->( dbGoTop() )
            SB1->( dbSeek( xFilial('SB1') + TRB->TMP_PROD ) )

            aDados := {}
            
            aAdd( aDados, {})

            aAdd( aTail(aDados),{ "D7_TIPO"		,nOpc			,nil } )
            aAdd( aTail(aDados),{ "D7_DATA"		,dDataBase		,nil } )
            aAdd( aTail(aDados),{ "D7_QTDE"		,TRB->TMP_QTD   ,nil } )
            aAdd( aTail(aDados),{ "D7_QTSEGUM"	,0				,nil } )
            aAdd( aTail(aDados),{ "D7_MOTREJE"	,""				,nil } )
            aAdd( aTail(aDados),{ "D7_LOCDEST"	,TRB->TMP_LOCDES,nil } )
            aAdd( aTail(aDados),{ "D7_SALDO2"  	,Nil			,nil } )
            aAdd( aTail(aDados),{ "D7_SALDO"  	,Nil			,nil } )
            aAdd( aTail(aDados),{ "D7_ESTORNO"	,Nil			,nil } )

            MSExecAuto({|x,y| mata175(x,y)}, aDados, 4 )
            
            If lMsErroAuto	
                MostraErro()
            EndIf

        EndIf

        TRB->(DbSkip())

    EndDo

    FwMsgRun(,{ || fLoadData() }, cCadastro, 'Carregando dados...')

    oBrowse:GoTop(.T.)
    oBrowse:Refresh()

    RestArea(aAreaSD7)
    RestArea(aAreaSB2)
    RestArea(aAreaSB1)

Return
