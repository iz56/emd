;macro.asm
 
 
       macro    unpackFont {
;cx=size
;si=ptr of arh
;di=ptr to unpack data free mem
;bx=ptr to temp work buff
       mov      si,word FontPack
; mov cx,word font_size
       mov      di,word Font
       mov      bx,word buf
       call     LZW_unpack
       }
 
 
       macro    SetColorUI color {
       mov      byte [PrintToEmdStr.Color],color
       }
 
 
       macro    printToScr Str {
       local    .ok, .msg
       mov      esi,.msg
       call     PrintToEmdStr
       jmp      .ok
.msg db Str
db 0
.ok:
       }
 
       macro    SetcursorToLine num {
       mov      eax,dword CHAR_ON_LINE*num ;set cursor to line 2
       call     SetPos
       }
 
       macro    SetcursorToNewLine {
       local    .ok, .l1, .ok2
       pusha
       call     GetPos
 
.l1:
       test     eax,eax
       jz       .ok
       cmp      eax,dword CHAR_ON_LINE
       jb       .ok
       sub      eax,dword CHAR_ON_LINE
       jmp      .l1
 
.ok:
       push     ax
 
       call     GetPos
       pop      bx
       sub      ax,bx
       add      ax,CHAR_ON_LINE
       cmp      ax,word CHAR_ON_LINE*25
       jnz      .ok2
 
       call     shiftPage ;----
       mov      eax,dword CHAR_ON_LINE*24
.ok2:
       call     SetPos
       popa
       }
 
 
       macro    biosKBDwait { call BiosKBDWait }
 
       macro    setcur argX,argY {
       mov      ah,02h ;- bios servis
       mov      bh,0
       mov      dh,argX
       mov      dl,argY
       int      10h
       }
 
       macro    display str {
 
       local    .outmacro, .msg
       pusha
       mov      dx,.msg
       call     PrintDosAH9 ;emd.asm
       popa
       jmp      .outmacro
.msg db str
db '$'
.outmacro:
       }
 
       macro    imulEax80
       {
;eax * 80:
       shl      eax,04h
       lea      eax,[eax+eax*4]
       }
 
macro align value { rb (value-1) - ($ + value-1) mod value }
 
       macro    beep { nop }
 
       macro    delllll {
       local    beep0
       local    idle1
       local    idle2
       KBD_PORT_B = 61h
       push     ax bx cx
       in       al,KBD_PORT_B
       push     ax
       mov      cx,80
beep0:
       push     cx
       and      al,11111100b
       out      KBD_PORT_B,al
       mov      cx,60
idle1:
       loop     idle1
       or       al,00000010b
       out      KBD_PORT_B,al
       mov      cx,60
idle2:
       loop     idle2
       pop      cx
       loop     beep0
       pop      ax
       out      KBD_PORT_B,al
       pop      cx bx ax
       }
 
 
;EOF
