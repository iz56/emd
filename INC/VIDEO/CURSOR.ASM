;cursor.asm
       
       
       COLOR_CURSOR_VESA = 0x0f1212
       
;ñÇÖí_îéçÄ2 = 0x0
       ñÇÖí_îéçÄ2 = BACKCOLOR
; ñÇÖí_îéçÄ2 = 0;x030300
; ñÇÖí_îéçÄ2 = 0x0888888;0
       
DrawCursorY:
; mov ebx,dword [VideoLinear]
macro put_pix { mov [fs:ebx],dword eax }
       
       call     .EraseOldY
       
       xor      eax,eax
       mov      al,[y]
       inc      al
       
       mov      [.oldY],byte al
       
       imul     eax,800*4*22
       mov      ebx,dword [VideoLinear]
       add      ebx,dword éíëíìè_ëÇÖêïì;+1
       
       add      ebx,eax
       
       mov      ecx,800
       
       mov      eax,COLOR_CURSOR_VESA
       AddEaxLi
       
.l1:
       put_pix
       add      ebx,dword 4
       dec      ecx
       jnz      .l1
       
       ret
       
       
.EraseOldY:
       xor      eax,eax
       mov      al,byte [.oldY]
       
       imul     eax,800*4*22
       mov      ebx,dword [VideoLinear]
       add      ebx,dword éíëíìè_ëÇÖêïì;+1
       
       add      ebx,eax
       
       mov      ecx,800
       
       mov      eax,dword ñÇÖí_îéçÄ2
; mov eax,0
.l2:
       put_pix
       add      ebx,dword 4
       dec      ecx
       jnz      .l2
       
       ret
.oldY db 0
       
       
DrawCursorX:
; mov ebx,dword [VideoLinear]
macro put_pix { mov [fs:ebx],dword eax }
       
       call     .EraseOldX
       
       xor      eax,eax
       mov      al,[x]
;inc al
       
       mov      [.oldX],byte al
       
       imul     eax,10*4
       mov      ebx,dword [VideoLinear]
       
       test     eax,eax
       jz       .Z1
       sub      ebx,dword 4
.Z1:
       add      ebx,eax
       
       
       mov      ecx,600-1
       
       mov      eax,COLOR_CURSOR_VESA
       AddEaxLi
       
.l1:
       put_pix
       add      ebx,dword 800*4
       dec      ecx
       jnz      .l1
       
       ret
       
       
.EraseOldX:
       xor      eax,eax
       mov      al,byte [.oldX]
       
       imul     eax,10*4
       mov      ebx,dword [VideoLinear]
       
       test     eax,eax
       jz       .Z2
       sub      ebx,dword 4
.Z2:
       
       add      ebx,eax
       
       
       mov      ecx,600-1
       
       mov      eax,dword ñÇÖí_îéçÄ2
; mov eax,0
.l2:
       put_pix
       add      ebx,dword 800*4
       dec      ecx
       jnz      .l2
       
       ret
       
.oldX db 0
       
       
       ñÇÖí_éëçéÇçéÉé_îéçÄ = BACKCOLOR
       
DrawBack:
       mov      ebx,dword [VideoLinear]
       mov      ecx,600*800
       dec      ecx
       mov      eax,dword ñÇÖí_éëçéÇçéÉé_îéçÄ
       
.l1:
       put_pix
       add      ebx,dword 4
       dec      ecx
       jnz      .l1
       
       
       ret
       
       
;EOF
       