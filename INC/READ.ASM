;read.asm
 
;in-
;dx - ptr file name
;edi - ptr memory
 
;-out
;eax (0 = ok 1,2,3,4=error)
;ecx = size reading byte
 
ReadOperation:
 
;проверяем размер файла - должен быть меньше 1/4 доступной памяти
;для этого инит переменную .LimitSizeFile
       mov      eax,dword [EndMemory]
       sub      eax,dword [StartMemory]
       shr      eax,2 ; div 4
       mov      [.LimitSizeFile], dword eax
 
 
       xor      eax,eax
       mov      dword [.BytesRead],eax
       mov      dword [.PtrMemoryDest],edi
 
       mov      ax,3D00h
       mov      al,2
       int      21h
       jc       .errorOpen
 
       mov      [.h],ax
 
.next:
 
;+ проверяем нажатие Esc
       pusha
 
       mov      ah,1 ;check to see if a char is ready
       int      16h
       jz       .ReadLoop ;nope, continue
 
       mov      ah,0
       int      16h ;get the character & put in AX
       cmp      ah,1 ;если не клавиша Esc ...
       jnz      .ReadLoop ;nope, continue
 
       popa
       jmp      .errorCansel ;отмена копирования файла в память
 
.ReadLoop:
       popa
;-
       mov      eax, dword [.BytesRead]
;       cmp      eax,dword SIZE_READ_BUF*10
;       jbe      .notProgress
 
display PROGRESS_SPEC_CHAR
 
;.notProgress:
 
       push     ds
       pop      es
       mov      ah,3fh
       mov      cx,SIZE_READ_BUF
       mov      bx,[.h]
       mov      dx,buf
       int      21h
       jc       .errorRead
 
       test      ax,ax
       jz       .ok
 
       xor      ecx,ecx
       mov      cx,ax
       mov      edi,dword [.PtrMemoryDest]
       add      edi,dword [.BytesRead]
       mov      esi,buf
 
       mov      eax, dword [.BytesRead]
       add      eax,ecx
       mov      [.BytesRead], dword eax
 
;проверяем размер файла - должен быть меньше 1/4 доступной памяти
       cmp      eax, dword [.LimitSizeFile]
       jae      .errorMemory
 
       shr      ecx,2
       inc      ecx
       xor      ebx,ebx
.l1:
       mov      eax, dword [esi]
       mov      [edi],dword eax
       add      esi, dword 4
       add      edi, dword 4
       dec      ecx
       jnz      .l1
 
       jmp      .next
 
.ok:
 
       mov      ah,3eh
       mov      bx,[.h]
       int      21h ;close file (dos service)
 
       mov      dword ecx, [.BytesRead]
       xor      eax,eax
       ret
 
.errorRead:
       mov      dword eax,1
       ret
.errorOpen:
       mov      dword eax,2
       ret
.errorMemory:
       mov      dword eax,3
       ret
.errorCansel: ;отмена копирования файла в память
       mov      dword eax,4
       ret
 
.LimitSizeFile dd 0
.Cursor dd 0
.BytesRead dd 0
.PtrMemoryDest dd 0
.h dw 0
 
;EOF
