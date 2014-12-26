;all.asm
 
 
 
;-----------
SetPos:
       mov      dword [PrintToEmdStr.cursor],eax
       ret
 
GetPos:
       mov      eax, dword [PrintToEmdStr.cursor]
       ret
 
GetPosX:
.l1:
       cmp      eax,dword CHAR_ON_LINE
       jae      .notAbCHAR_ON_LINE
       ret
.notAbCHAR_ON_LINE:
       sub      eax,dword CHAR_ON_LINE
       jmp      .l1
 
 
SetColor:
       mov      byte [PrintToEmdStr.Color],al
       ret
 
PrintToEmd_ASCII_Char:
       mov      byte [.Char],al
       mov      edi,dword [VideoBufMemory]
       mov      eax,dword [PrintToEmdStr.cursor]
       shl      eax,1
       add      edi,eax
       mov      ah,byte [PrintToEmdStr.Color]
       inc      dword [PrintToEmdStr.cursor]
       cmp      dword [PrintToEmdStr.cursor],CHAR_ON_LINE*25
       jnz      .pageVideoOk
 
       call     shiftPage ;----
       mov      [PrintToEmdStr.cursor],dword CHAR_ON_LINE*24
       sub      edi,dword CHAR_ON_LINE*2
.pageVideoOk:
       mov      al,byte [.Char]
       mov      [edi],word ax
 
       call     SetcursorBios
       mov      esi,dword [VideoBufMemory]
       call     DrawPage
       ret      ;----Exit
.Char db 0
 
PrintToEmdStrSize:
 
       add      esi,ecx
       mov      byte [esi],0
       sub      esi,ecx
 
PrintToEmdStr:
       mov      edi,dword [VideoBufMemory]
       mov      eax,dword [.cursor]
       shl      eax,1
       add      edi,eax
       mov      ah,byte [.Color]
.display:
       cmp      dword [.cursor],CHAR_ON_LINE*25 ;0
       jnz      .pageVideoOk
 
       call     shiftPage ;----
 
       mov      [.cursor],dword CHAR_ON_LINE*24
       mov      edi,dword [VideoBufMemory]
.pageVideoOk:
       mov      al,byte [esi]
       test     al,al
       jnz      .ok
       call     SetcursorBios
       mov      esi,dword [VideoBufMemory]
       call     DrawPage
       ret      ;----Exit
.ok:
       inc      dword [.cursor]
       mov      [edi],word ax
       inc      esi
       add      edi,dword 2
       jmp      .display
 
.cursor dd 0 ;current pos
.Color db 7
;------------
 
SetcursorBios:
       cmp      byte [.fVisible],0
       jnz      .work
       ret
.work:
       pusha
       call     GetPos
       xor      dx,dx
.l1:
       test     eax,eax
       jz       .ok
       cmp      eax,dword CHAR_ON_LINE
       jb       .ok
       sub      eax,dword CHAR_ON_LINE
       inc      dh
       jmp      .l1
.ok:
       mov      dl,al
 
 
       cmp      [VideoMode],dword 3
       jz       .okMode
 
       mov      [y],dh
       mov      [x],dl
 
       popa
       ret
.okMode:
 
       mov      [y],dh
       mov      [x],dl
call SetCursor
       popa
 
       ret
 
macro delllscdrhdrbrnbrh {
       mov      ah,02h ;- bios servis
       mov      bh,0
; mov dh,25
; mov dl,25
       int      10h
       popa
 
       ret
}
.fVisible db 1
 
 
shiftPage:
       .DUBLE_SIZE = CHAR_ON_LINE*2
 
       mov      dword [.saveRegs],esi
       mov      dword [.saveRegs+4],eax
       mov      dword [.saveRegs+8],ecx
 
       mov      esi,dword [VideoBufMemory]
       mov      ecx,CHAR_ON_LINE*24
.upLine:
       mov      ax,word [esi+.DUBLE_SIZE]
       mov      word [esi],ax
       add      esi,dword 2
       dec      ecx
       jnz      .upLine
       mov      ecx,CHAR_ON_LINE
       mov      ax,0x0720
.lastLine:
       mov      word [esi],ax
       add      esi,dword 2
       dec      ecx
       jnz      .lastLine
 
       mov      esi,dword [.saveRegs]
       mov      eax,dword [.saveRegs+4]
       mov      ecx,dword [.saveRegs+8]
 
       ret
.saveRegs dd 0,0,0
 
 
;edi = ptr,ecx=size eax=value
FillMem:
       test     ecx,ecx
       jnz      .l1
       ret
.l1:
       mov      dword [edi],eax
       add      edi,4
       dec      ecx
       jnz      .l1
       ret
 
RestorePos:
       mov      eax,dword [SavePos.pos]
       call     SetPos
       ret
SavePos:
       call     GetPos
       mov      dword [.pos],eax
       ret
.pos dd 0
 
 
       macro    PrintSpaces10 {
       mov      eax, 0x007200720
       mov      ecx,dword 5
       call     FillVideoPage
       }
 
 
; eax = value
; edx = cursor to start user string
PrintNumOfFindes:
       cmp      ecx,dword 0
       jnz      .work
       call     SavePos
       add      edx,dword CHAR_ON_LINE
       PrintSpaces10
       jmp      .exit
 
.work:
       mov      ecx,eax
       call     SavePos
 
       add      edx,CHAR_ON_LINE
       mov      eax,edx
       call     SetPos
 
       mov      eax,ecx
       call     Bin2AsciiDec ;esi=str
       CrrctEsiFrFrstZrPrnt
 
.exit:
       call     RestorePos
       call     SetcursorBios
       mov      esi,dword [VideoBufMemory]
       call     DrawPage
       ret
 
 
;eax=value , edx = pos(like cursor),ecx = size
FillVideoPage:
       mov      esi,dword [VideoBufMemory]
       shl      edx,1
       add      esi,edx
.l1:
       mov      [esi],eax
       add      esi,4
       dec      ecx
       jnz      .l1
       ret
 
 
;EOF
