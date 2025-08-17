#include "TOTVS.ch"

/*/{Protheus.doc} MTA140MNU
Adicionar botões ao Menu Principal através do array aRotina.
@author Claudio Bozzi
@since 03/02/2023
@version 1.0
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6085799
/*/
User function MTA140MNU()

    aAdd(aRotina, {'Etiqueta Entrada','u_xcom001a()',0,2,0,NIL})

return
