;scancmd.asm
 
;return dx = offset input string (modif to ASCIIZ)
 
ScanCmd:
 
;if reenter
       mov      dx ,word [.saveForRep ]
       test     dx,dx
       jz       .first
       ret
 
.first:  ;if first call
 
;--------------------------------------[+]
;scan command line for a file name
       mov      cx,15
       mov      si,81h
       mov      bl,' '
       mov      dx,3
       mov      di,sp
 
.scan:
       mov      al,[si]
       inc      si
       cmp      al,bl
       jz       .scan1
       dec      cx
       jnz      .scan
.erNameStack:
       mov      sp,di
       jmp      .erName
 
.scan1:
       push     si
       dec      dx
       jz       .erNameStack
       mov      bl,13
       cmp      al,13
       jnz      .scan
 
       pop      si
       dec      si
       mov      byte [si],0
       pop      dx
;--------------------------------------[-]
       mov      word [.saveForRep ],dx
 
       ret
.erName:
       stc
       ret
.saveForRep dw 0
 
;EOF
 
