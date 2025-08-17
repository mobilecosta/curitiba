#include "TOTVS.ch"

/*/{Protheus.doc} ACD100MNU
Adicionar botões ao Menu Principal através do array aRotina.
@author Claudio Bozzi
@since 03/02/2023
@version 1.0
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6091060
/*/
User function ACD100MNU()

    aAdd(aRotina, {'Etiqueta Separação','u_xacd001a(2)',0,2,0,NIL})

return

User Function ACD100BUT()

	Local aButtons as Array

	aButtons := {}

    AADD(aButtons,{ 'Etiqueta Separação' ,{|| u_xacd001a(2) },'Etiqueta Separação','Etiqueta Separação' } )

Return(aButtons)
