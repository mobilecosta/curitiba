#include "TOTVS.ch"

/*/{Protheus.doc} ACD100MNU
Adicionar bot�es ao Menu Principal atrav�s do array aRotina.
@author Claudio Bozzi
@since 03/02/2023
@version 1.0
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6091060
/*/
User function ACD100MNU()

    aAdd(aRotina, {'Etiqueta Separa��o','u_xacd001a(2)',0,2,0,NIL})

return

User Function ACD100BUT()

	Local aButtons as Array

	aButtons := {}

    AADD(aButtons,{ 'Etiqueta Separa��o' ,{|| u_xacd001a(2) },'Etiqueta Separa��o','Etiqueta Separa��o' } )

Return(aButtons)
