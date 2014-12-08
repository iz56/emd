;cls16.asm
 
 
ClrScr:
       push     gs
       push     word 0b800h
       pop      gs
       xor      edi,edi
       mov      eax, SPACES_7_DWORD
.redraw:
mov dword [gs:0+edi],eax
       add      edi,4
;       cmp      di,4000
cmp edi,[SizeVideoPageBytes]
       jbe      .redraw
       pop      gs
       ret
 
;EOF
 
