;enter.asm
 
 
;if pressed enter key
EnterLine:
 
;check size of free mem (*2 needed)
       mov      eax,[SizeTextFormatted] ;size of formated text (array80*lines)
       shl      eax,1
       add      eax,dword CHAR_ON_LINE*2
       mov      ebx,eax
       add      ebx,dword [StartMemory]
 
       cmp      ebx,dword [EndMemory]
       jae      .close ;memory is end
 
;save for shift+enter
       mov      al,[x]
       mov      [.tmpX],al
 
;if end of text
       mov      ebx,[IndexPageActive]
       xor      eax,eax
       mov      al,[y]
       inc      al
       imul     ax,CHAR_ON_LINE
       add      ebx,eax
       cmp      [SizeTextFormatted],ebx
       jbe      .end_of_text
;if start and middle
       mov      ebx,[StartMemory]
       add      ebx,[IndexPageActive]
       xor      eax,eax
       inc      [y]
       mov      al,[y] ;al - next line
       cmp      al,LINES_ON_SCR
       jz       .end_of_page
 
.ok_page:
       imul     ax,CHAR_ON_LINE
       add      ebx,eax ;ebx - here  past empty line
       mov      edi,[SizeTextFormatted]
       add      edi,[StartMemory]
       mov      esi,edi
       add      edi,CHAR_ON_LINE
 
.shift_text80:
       mov      al,[esi]
       mov      byte [esi],32
       mov      [edi],al
       dec      esi
       dec      edi
       cmp      esi,ebx
       jae      .shift_text80;-------------------
 
       add      dword [SizeTextFormatted],CHAR_ON_LINE
 
       mov      byte [x],0 ;set cursor to start of line
       jmp      .pasteLineComplete
 
;if needed scroll down
.end_of_page:
       mov      al,24
       mov      [y],al
       inc      al
       add      dword [IndexPageActive],CHAR_ON_LINE
       jmp      .ok_page
 
.end_of_text:
 
       add      dword [SizeTextFormatted],CHAR_ON_LINE
 
       mov      byte [x],0 ;set cur start
       inc      [y]
       cmp      [y],LINES_ON_SCR
       jnz      .pasteLineComplete
       add      dword [IndexPageActive],CHAR_ON_LINE
       mov      [y],24
 
 
.pasteLineComplete:
; shift ?
       cmp      byte [FlagKeyShift],1
       jz       .EnterShift_CutLine
 
       ret      ; work completed for single Enter
 
 
;shift+enter
.EnterShift_CutLine:
 
;shift
;flag KBD status (BIOS data area)
mov al,byte [fs:0+00417h]
       shl      al,7
       cmp      al,0
       jz       .leftShiftPressed
 
 
;right shift+enter
       xor      eax,eax
       mov      al,[.tmpX]
       cmp      al,0
       jnz      .go
       ret
.go:
       push     ax ;ax=here cut line
 
       mov      ebx,[StartMemory]
       add      ebx,[IndexPageActive]
 
       xor      eax,eax
       mov      al,[y]
 
       imul     ax,CHAR_ON_LINE
       add      ebx,eax ;ebx - empty line
       mov      eax,ebx
 
 
       mov      edi,eax
       mov      [.tmp_edi],dword edi
       sub      eax,dword CHAR_ON_LINE
       mov      esi,eax
       pop      cx
       mov      bl,20h
       mov      dx, word CHAR_ON_LINE
 
.copyCharsDown:
       mov      al,[esi]
       mov      [esi],bl
       mov      [edi],al
       inc      esi
       inc      edi
       dec      dx
       dec      cx
       jnz      .copyCharsDown
       mov      cx,dx
 
       mov      eax,dword [.tmp_edi]
       sub      eax, dword CHAR_ON_LINE ;chars num needed
       mov      edi,eax
       mov      dx, word CHAR_ON_LINE
 
.move0:
       mov      al,[esi]
       mov      [edi],al
       inc      esi
       inc      edi
       dec      dx
       dec      cx
       jnz      .move0
 
       mov      cx,dx
       mov      al,32 ;+spaces to line
.move32:
       mov      [edi],al
       inc      edi
       dec      cx
       jnz      .move32
 
       dec      [y]
 
       ret      ; work comleted for Enter+right_Shift
 
 
.tmp_edi dd 0
 
.leftShiftPressed:
 
       mov      ebx,[StartMemory]
       add      ebx,[IndexPageActive]
 
       xor      eax,eax
       mov      al,[y]
 
       imul     ax,CHAR_ON_LINE
       add      ebx,eax ;ebx - empty line
       mov      eax,ebx
 
       mov      edi,eax
       sub      eax,dword CHAR_ON_LINE
 
       xor      ebx,ebx
       mov      bl,[.tmpX]
       add      eax,ebx
 
       mov      esi,eax
       mov      ecx,dword CHAR_ON_LINE
       sub      ecx,ebx
.copyLine:
       mov      al,[esi]
       mov      [esi],byte 32
       mov      [edi],al
       inc      esi
       inc      edi
       dec      ecx
       jnz      .copyLine
 
       ret      ; work completed for Enter+left_Shift
 
.tmpX db 0
 
 
.close:
;error memory end:
       sub      dword [SizeTextFormatted],CHAR_ON_LINE
 
       call     SaveXY ;emd.asm
 
       SetcursorToLine 0
       SetColorUI 7
 
       mov      si,.msgErrorMemory
       mov      di,buf
       call     OutTextRadix50UnRealMode
 
       biosKBDwait ;inc\macro.asm
 
       call     SaveXY.re ;emd.asm
       ret
 
 
.msgErrorMemory:
db 022h ,022h ,090h ,060h ,0ech ,059h ,00dh ,002h ,0aah ,053h ,078h ,0a0h
 
 
;EOF
