;delline.asm
 
 
DeleteEmptyLines: ;inc/delline.asm
 
;esi=index and address of lines
       mov      esi,dword [StartMemory]
.l1:
       call     .escCheck
       jc       .stop
 
       call     .CheckEmptyLine
       add      esi,dword [leghtY]
       mov      eax,dword [SizeTextFormatted]
       add      eax,dword [StartMemory]
       cmp      esi,eax ;test address-----------!
       jnz      .l1
 
.stop:
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
 
       mov      cl,20;[leghtY]
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
       sub      esi,[leghtY]
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
       add      dword esi,[leghtY]
 
.l11:
       mov      eax,dword [esi]
       mov      dword [edi],eax
       add      esi,4
       add      edi,4
       dec      ecx
       jnz      .l11
 
       mov      eax,[SizeTextFormatted]
       sub      eax,[leghtY]
       mov      [SizeTextFormatted],eax
       ret
 
.saveEsi dd 0 ;here actual address of line into memory
.countOfDelLines dd 0
 
 
;EOF
