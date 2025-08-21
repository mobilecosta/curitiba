#include 'totvs.ch'
#INCLUDE "rwmake.ch"


/*/{Protheus.doc} MA381MNU 
    LOCALIZAÇÃO: Na rotina de ajuste de empenhos (modalidade II).EM QUE PONTO: Será executado na montagem da tela nas funções de visualização, inclusão, alteração e exclusão.UTILIZAÇÃO: Este ponto de entrada permitirá ao usuário manipular a barra de botões nas rotinas de visualização, inclusão, alteração e exclusão.
    PARÂMETROS DE ENVIO: Os parâmetros enviados ao ponto de entrada estão no vetor PARAMIXB, sendo eles:
    ParamIXB[1] -> Opção selecionada pelo usuário, sendo:
    2-Visualizar
    3-Incluir
    4-Alterar
    5-Excluir
    ParamIXB[2] -> Vetor contendo os botões originais da rotina.
    PARÂMETROS DE RETORNO: É esperado como retorno um vetor no mesmo formato do vetor original
    .
    @type Function
    @author Carvalho Informatica
    @since 17/08/2025
    @version 1.0.0
     @see https://tdn.totvs.com/display/PROT/MA381BUT
/*/
User Function MA381BUT()
    Local nOpcao  := PARAMIXB[1]          // Opção escolhida
    Local aBotoes := aClone(PARAMIXB[2])  // Array com botões caso exist

    aAdd( aBotoes, { 'VRFCEST', { ||  FWMsgRun( , { || u_APCP002() }, "Verificando", "Verificando Estoque..." ) }, 'Verificar Estoque' } )
Return( aClone( aBotoes ) )

/*/{Protheus.doc} MTA381GRV
    (O Ponto de entrada MTA381GRV é utilizado para realizar operações complementares após a inclusão, alteração e exclusão de um item de ajuste de empenho mod II
    @type Function
    @author Carvalho Informatica
    @since 17/08/2025
    @version 1.0.0
    @see https://tdn.totvs.com/display/PROT/MTA381GRV+-+Ajuste+de+Empenho
/*/
User Function MTA381GRV()
    Local aArea      := FWGetArea()
    // Local ExpL1 := PARAMIXB[1] // Incluir
    Local ExpL2      := PARAMIXB[2] // Excluir
    // Local ExpL3 := PARAMIXB[3] // Alterar
    Local nX         := 1
    Local nPosLotCtl := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_LOTECTL"})
    Local nLtInfo    := 0 // Quantidade de registros com lotes informados

    if 	!ExpL2
        for nX := 1 to len(aCols)
            if !Empty(aCols[nX][nPosLotCtl])
                nLtInfo += 1
            endIF
        next

        // Se posciona
        dbSelectArea('SC2')
		SC2->(dbSetOrder(1))
		if SC2->(dbSeek(xFilial('SC2')+SD4->D4_OP))
            cStatus := ""

            // Verifica se é parcial total ou nada
            if nLtInfo == len(aCols)
                cStatus := "T"
            elseif nLtInfo > 0
                cStatus := "P"
            else
                cStatus := ""
            endif

            Reclock("SC2", .F.)
            SC2->C2_XEST := cStatus
            SC2->(msUnLock())
        endIF
        
    endif

    FWRestArea(aArea)
return
