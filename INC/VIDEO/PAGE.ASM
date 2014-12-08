;page.asm
 
 
; esi = page buffer
DrawPage:
       cmp      [VideoMode],dword 3
       jnz      .vesa
 
       xor      ebx,ebx
.redraw:
       mov      dword edx,[esi]
       mov      dword eax,[esi+4]
       add      esi,dword 8
 
mov dword [gs:ebx],edx
mov dword [gs:ebx+4],eax
       add      ebx,dword 8
       cmp      ebx,[SizeVideoPageBytes] ;4000
       jbe      .redraw
       ret
 
.vesa:
       mov      [.tmpEsi],esi
 
       mov      ebx,dword [VideoLinear]
       test     ebx,ebx
       jnz      .noSetMode
 
       call     set_VESA_mode ;vesa16.asm
       jc       .error
       mov      esi,[.tmpEsi]
 
       mov      ebx,dword [VideoLinear]
       mov      eax,dword [EndMemory]
       cmp      ebx,eax
       jb       .error
 
 
.noSetMode:
;esi = массив символов и аттрибутов 80 на 25 строк
;edi = font
 
       mov      edi,Font
 
       call     DrawVideoPage
 
       ret
 
 
 
.error:
       call     SetTxtVMode ;vesa16.asm
 
       mov      [VideoMode],dword 3
       mov      esi,[.tmpEsi]
       jmp      DrawPage
 
.tmpEsi dd 0
VideoMode dd 3;8 ;еще определяет какой режим при старте программы
SizeVideoPageBytes dd 4000
 
DrawPageFirstLine:
;esi = массив символов и аттрибутов 80 на 25 строк
;edi = font
 
       mov      edi,Font
       call     DrawVideoPageFirstLine
 
ret
;EOF
