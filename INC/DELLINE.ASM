;delline.asm
 
 
DeleteEmptyLines: ;inc/delline.asm
 
;esi=index and address of lines
       mov      esi,dword [StartMemory]
.l1:
       call     .escCheck
       jc       .stop
 
       call     .CheckEmptyLine
       add      esi,dword 80
       mov      eax,dword [SizeTextFormatted]
       add      eax,dword [StartMemory]
       cmp      esi,eax ;test address-----------!
       jnz      .l1
 
.stop:
       mov      eax,dword [SizeTextFormatted]
       cmp      eax,CHAR_ON_LINE*25
       jb       .cursorUp
 
       sub      eax,CHAR_ON_LINE*25
 
       mov      dword [IndexPageActive],eax
                                           ret
       cmp      eax,dword [IndexPageActive]
       jb       .endTextSetPos
 
;       ret
 
.endTextSetPos:
       mov      eax,dword [SizeTextFormatted]
       sub      eax,CHAR_ON_LINE*25
       mov      dword [IndexPageActive],ebx
       mov      [y],byte 24
;       mov      [x],al
 
       ret
 
.cursorUp:
 
       xor      eax,eax
       mov      dword [IndexPageActive],eax
       mov      [y],al
       mov      [x],al
 
       ret
 
 
 
.escCheck:
       mov      [.saveRegs],dword esi
 
       mov      ah,1 ;check to see if a char is ready
       int      16h
       jz       .ReadLoop ;nope, continue
 
       mov      ah,0
       int      16h ;get the character & put in AX
       cmp      ah,1 ;если не клавиша Esc ...
       jnz      .ReadLoop ;nope, continue
 
       stc
       ret
 
.ReadLoop:
       clc
       mov      esi , dword [.saveRegs]
       ret
 
.saveRegs dd 0
 
;=======\
.CheckEmptyLine:
       mov      [.saveEsi],esi
 
       mov      cl,20;80
.a1:
       mov      eax,dword [esi]
       cmp      eax,0x020202020;' '
       jnz      .exit
       add      esi,4
       dec      cl
       jnz      .a1
 
;пустая строка
       call     .Erase
 
       mov      esi,[.saveEsi]
       sub      esi,80
       ret
 
.exit:
       mov      esi,[.saveEsi]
       ret
;=======/
 
 
.Erase:
 
       inc      dword [.countOfDelLines]
 
       mov      ebx,[StartMemory]
       mov      eax,[.saveEsi]
       sub      eax,ebx
       mov      ecx,[SizeTextFormatted]
       sub      ecx,eax
       shr      ecx,2 ;div 4
 
       mov      esi,[.saveEsi]
       mov      edi,esi
       add      dword esi,80
 
.l11:
       mov      eax,dword [esi]
       mov      dword [edi],eax
       add      esi,4
       add      edi,4
       dec      ecx
       jnz      .l11
 
       mov      eax,[SizeTextFormatted]
       sub      eax,80
       mov      [SizeTextFormatted],eax
       ret
 
 
;-------------------------------------------------------------------------------
 
.saveEsi dd 0 ;here actual address of line into memory
.countOfDelLines dd 0
 
;EOF
 
 
