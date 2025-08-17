#command @ <row>, <col> VTSAY <xpr> [PICTURE <pic>]                       ;
      => VTSay( <row>, <col>, <xpr> [, <pic>] )

#command VTCLEAR                                                          ;
                                                                          ;
      => VTClear()
	  
#command VTCLEAR SCREEN                                                   ;
                                                                          ;
      => VTCLEAR

#command @ <top>, <left> VTCLEAR TO <bottom>, <right>                     ;
                                                                          ;
      => VTClear( <top>, <left>, <bottom>, <right> )                      ;

#command VTREAD                                                           ;
                                                                          ;
      => VTRead()
	  
#command @ <row>, <col> VTGET <var> [PICTURE <pic>]                       ;
                        [<password: PASSWORD>]                            ;
                        [VALID <valid>] [WHEN <when>] [F3 <sF3>]         ;
						                                                  ;
      => VTSetGet( @<var>, <"var">, <row>, <col>, {|| <valid> },          ;
                   {|| <pic> }, {|| <when> }, <.password.> ,<sF3>)         ;
				   
#command @ <row>, <col> VTSAY <sayxpr> [<sayClauses,...>]                 ;
                        VTGET <var> [<getClauses,...>]                    ;
                                                                          ;
      => @ <row>, <col> VTSAY <sayxpr> [<sayClauses>]                     ;
       ; @ VTROW(), VTCOL() + 1 VTGET <var> [<getClauses>]


#command VTPAUSE                                                          ;
                                                                          ;
      => VTPause()

#command @ <row>, <col> VTPAUSE <xpr> [PICTURE <pic>]                     ;
                                                                          ;
      => VTPause( <row>, <col>, <xpr> [, pic ] )

#command VTSAVE SCREEN TO <var>                                             ;
      => <var> := VTSave()

#command VTRESTORE SCREEN FROM <var>                                        ;
      => VTRestore( nil, nil, nil, nil, <var> )

#command VTSAVE SCREEN VAR <var>                                          ;
                FROM <top>, <left> TO <bottom>, <right>                   ;
                                                                          ;
      => <var> := VTSave( <top>, <left>, <bottom>, <right> )

#command VTRESTORE SCREEN VAR <var>                                       ;
                FROM <top>, <left> TO <bottom>, <right>                   ;
                                                                          ;
      => VTRestore( <top>, <left>, <bottom>, <right>, <var> )
	  
#command VTSIZE <row>, <col>                                              ;
                                                                          ;
      => VTSetSize( <row>, <col> )

#command VTSET KEY <n> TO <proc>                                          ;
      => VTSetKey( <n>, {|p, l, v| <proc>(p, l, v)} )

#command VTSET KEY <n> TO <proc> ( [<list,...>] )                         ;
      => VTSET KEY <n> TO <proc>

#command VTSET KEY <n> TO <proc:&>                                        ;
                                                                          ;
      => if ( Empty(<(proc)>) )                                           ;
       ;   VTSetKey( <n>, NIL )                                           ;
       ; else                                                             ;
       ;   VTSetKey( <n>, {|p, l, v| <proc>(p, l, v)} )                   ;
       ; end

#command VTSET KEY <n> [TO]                                               ;
      => VTSetKey( <n>, NIL )
      

//----------------------- INCLUIDO POR ERIKE

#command @ <row>, <col> TERSAY <cMsg>                       									;
      => TerSay(<row>,<col>,<cMsg>)

#command TerCls      																													;
			 => TerCls()			 

#command TerCBuffer																														;
			=>	TerCBuffer()

#command @ <row>, <col>	 TerGetRead	<uVar>	[PICTURE <pic>]											;
												[WHEN <when>]	[VALID <valid>] 												;
			=>TerGetRead(<row>,<col>,@<uVar>,[<pic>],[{|| <valid>}],[{|| <when>}]) 

#command TerEsc      																													;
			 => TerEsc()                                                                                           
                          
#command TerBeep <nVezes>      																								;
			 => TerBeep(<nVezes>)                                                                                           

#command TerIsQuit																															;
			=> TerIsQuit()
