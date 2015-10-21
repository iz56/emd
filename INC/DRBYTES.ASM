;drbytes.asm
 
DisplayReadingBytes:
 
display ' read: '
 
       mov      eax,[SizeFile]
       test     eax,eax
       jnz      .notZero
       mov      dx,.zeroStr
       call     PrintDosAH9
       jmp      .end
 
.zeroStr db '0$'
 
.notZero:
 
       call     Bin2AsciiDec
       xor      dx,dx
.print:
       mov      al,byte [si]
       inc      si
       test     dx,dx
       jnz      .digTrue
       cmp      al,'0'
       jz       .print
       mov      dx,si
.digTrue:
       test     al,al
       jnz      .print
 
       mov      [si-1],byte '$'
       dec      dx
 
       mov      ah,9
       int      21h
.end:
       display  ' bytes. Press Any Key... '
       ret
 
;EOF
 
