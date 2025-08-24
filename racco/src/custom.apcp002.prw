#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} APCP002
    Formula de lote de produção chamada pelo cadastro de formulas definido no parâmetro MV_FORMLOT
    @type function
    @version 12.1.2210
    @author Carvalho Informatica
    @since 16/10/2023
    @return character, Lote
/*/
User Function APCP002()
	Local nX   := 1
	Local nY   := 1
	Local nLot := 1

	nPosCod    := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_COD"})
	nPosTRT    := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_TRT"})
	nPosLocal  := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_LOCAL"})
	nPosQuant  := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_QUANT"})
	nPosQtdOri := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_QTDEORI"})
	nPosSegUM  := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_QTSEGUM"})
	nPosLotCtl := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_LOTECTL"})
	nPosLote   := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_NUMLOTE"})
	nPosDValid := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_DTVALID"})
	nPosPotenc := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_POTENCI"})
	nPosData   := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_DATA"})
	nPosOPorig := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_OPORIG"})
	nPosRecno  := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_REC_WT"})
	nPosPrdOri := aScan(aHeader,{|aX| AllTrim(aX[2]) == "D4_PRDORG"})

	for nX := 1 to len(aCols)
		cCodProd := aCols[nX][nPosCod]
		cLocal   := aCols[nX][nPosLocal]
		nQuant   := aCols[nX][nPosQuant]

		//Verifica se o produto controla lote/
		SB1->(DBSetOrder(1))
		If SB1->(DBSeek(xFilial("SB1") + cCodProd)) .And. Empty(aCols[nX][nPosLotCtl])
			if SB1->B1_RASTRO == "L"
				// Realiza query buscando na SB8 B8_SALDO > 0 do produto
				cQry := " SELECT "
				cQry += " SB8.B8_PRODUTO, SB8.B8_SALDO, SB8.B8_LOCAL, SB8.B8_LOTECTL, SB8.B8_DTVALID "
				cQry += " FROM " + RETSQLNAME("SB8") + " SB8 "
				cQry += " WHERE SB8.B8_FILIAL = '" + FWxFilial("SB8") + "' "
				cQry += " AND SB8.B8_PRODUTO = '" + cCodProd + "' "
				cQry += " AND SB8.B8_LOCAL = '" + cLocal + "' "
				cQry += " AND SB8.B8_SALDO > 0 "
				cQry += " AND SB8.D_E_L_E_T_ = ' ' "
				cQry += " ORDER BY SB8.B8_DTVALID "
				PlsQuery(cQry, "QRY")
				DbSelectArea("QRY")

				nQtdRest := nQuant
				aLotes   := {}

				While !QRY->(EoF()) .and. nQtdRest > 0
					nSaldoLote := QRY->B8_SALDO
					nQtdUsar   := Min(nSaldoLote, nQtdRest)

					aAdd(aLotes, { ;
						QRY->B8_LOTECTL, ; // Lote
					nQtdUsar,;        // Quantidade destinada deste lote
					QRY->B8_DTVALID;   // Validade
					})

					nQtdRest -= nQtdUsar
					QRY->(dbSkip())
				End

				QRY->(dbCloseArea())

				// Se não conseguiu atender toda a quantidade
				if Len(aLotes) > 0
					// Para cada lote utilizado, crie uma linha no empenho (SD4)
					For nLot := 1 To Len(aLotes)

						if nLot > 1
							aNovaLinha := aClone(aCols[nX])
							aNovaLinha[nPosLotCtl]   := aLotes[nLot][1]
							aNovaLinha[nPosQtdOri]   := aLotes[nLot][2]
							aNovaLinha[nPosQuant]    := aLotes[nLot][2]
							aNovaLinha[nPosDValid]   := aLotes[nLot][3]
							aNovaLinha[nPosRecno]    := 0

							// Realiza o calculo da segunda unidade de medida
							if SB1->B1_TIPCONV == "M"
								aNovaLinha[nPosSegUM] := aNovaLinha[nPosQuant] * SB1->B1_CONV
							elseif SB1->B1_TIPCONV == "D"
								aNovaLinha[nPosSegUM] := aNovaLinha[nPosQuant] / SB1->B1_CONV
							endif

							aAdd(aCols, aNovaLinha)
						else
							// Atualiza a linha atual com os dados do lote
							aCols[nX][nPosLotCtl]    := aLotes[nLot][1]
							aCols[nX][nPosQtdOri]    := aLotes[nLot][2]
							aCols[nX][nPosQuant]     := aLotes[nLot][2]
							aCols[nX][nPosDValid]    := aLotes[nLot][3]

							// Realiza o calculo da segunda unidade de medida
							if SB1->B1_TIPCONV == "M"
								aCols[nX][nPosSegUM] := aCols[nX][nPosQuant] * SB1->B1_CONV
							elseif SB1->B1_TIPCONV == "D"
								aCols[nX][nPosSegUM] := aCols[nX][nPosQuant] / SB1->B1_CONV
							endif
						endif
					Next

					// Se for o caso de possuirmos lotes, mas não conseguimos consumir todo o saldo, copia a linha e adiciona o saldo restante
					if nQtdRest > 0
						aNovaLinha := aClone(aCols[nX])
						aNovaLinha[nPosLotCtl]   := ""
						aNovaLinha[nPosQtdOri]   := nQtdRest
						aNovaLinha[nPosQuant]    := nQtdRest
						aNovaLinha[nPosDValid]   := CtoD("//")
						aNovaLinha[nPosRecno]    := 0

						// Realiza o calculo da segunda unidade de medida
						if SB1->B1_TIPCONV == "M"
							aNovaLinha[nPosSegUM] := aNovaLinha[nPosQuant] * SB1->B1_CONV
						elseif SB1->B1_TIPCONV == "D"
							aNovaLinha[nPosSegUM] := aNovaLinha[nPosQuant] / SB1->B1_CONV
						endif
						
						aAdd(aCols, aNovaLinha)
					endif
				endif

			EndIf
		EndIf
	Next

	// Mensagens de sucesso
	nLtInfo := 0
	for nY := 1 to len(aCols)
		if !Empty(aCols[nY][nPosLotCtl])
			nLtInfo += 1
		endIF
	next

	// Verifica se é parcial total ou nada
	if nLtInfo == len(aCols)
		FWAlertSuccess("Empenho atualizado: Todos os lotes foram reservados para a OP", "Sucesso")
	elseif nLtInfo > 0
		FWAlertError("Empenho atualizado: Um ou mais produtos não possuem saldo disponível", "Aviso")
	endif

	oGet:Refresh()
Return
