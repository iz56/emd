;cls.asm
 
cls:
 
       mov      edi,dword [VideoBufMemory]
       mov      eax, SPACES_7_DWORD
;mov cx,word 1000
       mov      ecx,[SizeVideoPageBytes] ;4000
 shr ecx,2 ;div 4
.redraw:
mov dword [edi],eax
       add      edi,4
dec ecx
       jnz      .redraw
 
 
;esi = массив символов и аттрибутов 80 на 25 строк
       mov      esi,dword [VideoBufMemory]
       call     DrawPage ;вывод пикселей
 
       ret
 
 
 
 
 
 
;EOF
