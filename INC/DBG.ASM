;dbg.asm
 
 
       macro    ff_debug_asm_file_only arg {
       mov      dx,word arg
       call     PrintDosAH9 ;emd.asm
       biosKBDwait
       }
 
       macro    prnOk {
       ff_debug_asm_file_only okMsg
       }
 
okMsg db 'Ok $',0
 
;EOF
