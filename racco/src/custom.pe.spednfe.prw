#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} FISTRFNFE
Rotina de ponto de entrada do SPEDNFE para notas fiscais.
Adiciona rotina no menu.
@type function
@version 12.1.033
@author Claudio Bozzi
@since 01/02/2023
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6077029
/*/
User Function FISTRFNFE()

    AAdd(aRotina, {'Etiqueta Expedição', 'u_xfat001a()', 0, 2})        

Return
