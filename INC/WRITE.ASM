;write.asm
 
 
 
       OK_COMPLETE = 0 ;if not errors
 
;error cods for exit to dos msg print
       ERROR_CREATE = 7
       ERROR_WRITE = 8
       ERROR_DELETE = 9
       ERROR_CLOSE = 10
       ERROR_ABORT_USER = 11
 
;if file have spec "end-byte" (old dos texts) - restore it
;here check last orignal byte, and correct data for write
AddOldByte:
       mov      al,byte [SpecEOFbyte]
       cmp      al, byte 0
       jz       .l1
       mov      edi,esi
       add      edi,ecx
       mov      [edi],byte al ;(spec byte added on end of text)
       inc      ecx ; correct size
.l1:
       ret
 
 
; esi = 32bit ptr data; ecx = size; ds:dx = ptr name file (ASCIIZ)
WriteOperation:
 
       mov      [.IndexWriteOperation], dword esi
       mov      [.BytesToWrite],dword ecx
       mov      [.PtrNameFileText],word dx
 
       cmp      [FlagNewFile],byte 1
       jz       .noDel
 
       mov      [.CodError], dword ERROR_DELETE
 
;delete file and creat
       mov      ah,41h
       int      21h
       jc       .Exit ;#2 error exit
 
 
.noDel:
 
       mov      [.CodError], dword ERROR_CREATE
 
       mov      dx, word [.PtrNameFileText]
       mov      ah,3ch
       mov      cx,0
       int      21h
       jc       .Exit
 
       mov      [.h], word ax
 
       cls      7
       setcur   1,1
display 'write :'
 
.WriteCycle:
 
display PROGRESS_SPEC_CHAR
 
       mov      esi, dword [.IndexWriteOperation]
       mov      edi, buf
       mov      eax, dword [.BytesToWrite]
 
       cmp      eax, dword SIZE_READ_BUF
       jb       .ExitWriteCycle
 
       mov      cx, word SIZE_READ_BUF/4
       inc      cx
       xor      ebx,ebx
.Copy2Buf:
       mov      eax, dword [ebx+esi]
       mov      [ebx+edi],dword eax
       add      ebx, dword 4
       dec      cx
       jnz      .Copy2Buf
 
       mov      [.CodError], dword ERROR_WRITE
 
       mov      bx,[.h]
       mov      cx, word SIZE_READ_BUF
       mov      ah,40h
       mov      dx,buf
       int      21h
       jc       .Exit
 
       add      [.IndexWriteOperation], dword SIZE_READ_BUF
       sub      [.BytesToWrite], dword SIZE_READ_BUF
 
;mov esi,msg.next ;следующий блок
;call Print
 
       in       al, 60h ;выход если esc
       cmp      al, 81h
       jnz      .WriteCycle
 
       xor      ax,ax ;clear keybuffer
       int      16h
 
       mov      [.CodError], dword ERROR_ABORT_USER
       jmp      .Exit
 
.ExitWriteCycle:
       mov      esi,[.IndexWriteOperation]
       mov      edi,buf
       mov      ecx,[.BytesToWrite]
 
       cmp      ecx,0
       jz       .ExitCopy2BufEnd
 
       call     movsbVersion32
 
.ExitCopy2BufEnd:
       mov      ecx,[.BytesToWrite]
       cmp      ecx,0
       jz       .Exit
 
       mov      [.CodError], dword ERROR_WRITE
 
       mov      bx,[.h]
       mov      ah,40h
       mov      dx,buf
       int      21h
 
       mov      [.CodError], dword OK_COMPLETE
 
.Exit:
       mov      ax, [.h]
       test     ax,ax
       jz       .noClose
 
;close file
       mov      ah,3eh
       mov      bx,[.h]
       int      21h ;close file (dos service)
       jnc      .CloseOk
 
       mov      eax, dword ERROR_CLOSE
       ret
 
.CloseOk:
.noClose:
       mov      eax, dword [.CodError]
       ret
 
 
       align    4
 
.CodError dd 0
 
;данные для записи файла
.BytesToWrite dd ? ;размер незаписанного массива данных
.IndexWriteOperation dd ? ;адресс в массиве
.PtrNameFileText dw 0
.h dw 0
 
 
;EOF
