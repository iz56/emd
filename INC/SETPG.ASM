;setpg.asm
 
;----------\
;ebx=ptr to line into all text
SetPage:
       .NUM_OF_LINE = 11 ;for set cursor in screen
 
       sub      ebx,dword [StartMemory]
call EbxCut80
 
       mov      eax,[SizeTextFormatted]
       sub      eax,ebx
       cmp      eax,80*25
       jae      .itNotEndOfText
       mov      ebx,eax
;set page
       mov      eax,[SizeTextFormatted]
       sub      eax,80*25
       mov      [IndexPageActive],dword eax
 
;set cursor
       call     .divEbx
       cmp      dl,25
       ja       .err
       mov      al,25
       sub      al,dl
       mov      [y],al
       ret      ;-------exit[1]
 
.itNotEndOfText:
 
       call     .divEbx
 
 
       mov      [IndexPageActive],dword 0
 
       cmp      eax,80*25
       jb       .itStartOfText
       sub      eax,80*.NUM_OF_LINE
       mov      [IndexPageActive],dword eax
 
       mov      dl,byte .NUM_OF_LINE
 
.itStartOfText:
       mov      [y],dl
       ret      ;-------exit[2]
 
.err:
       inc      byte [errors] ;emd.asm
       ret      ;-------exit[3]
 
;sub
;------\
.divEbx:
       xor      eax,eax
       xor      edx,edx
 
.subCHAR_ON_LINE:
       cmp      ebx,CHAR_ON_LINE
       jb       .subOk
       add      eax,CHAR_ON_LINE
       sub      ebx,CHAR_ON_LINE
       inc      edx ;lines
       jmp      .subCHAR_ON_LINE
.subOk:
       ret
;------/
 
;----------/
 
 
;EOF
