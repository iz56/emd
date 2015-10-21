;radix50.asm
 
 
;print to screen radix50 string
; ds:si = ptr Rad string
OutTextRadix50UnRealMode:
 
;in:
;ds:si = sring RADIX50 (16bit ptr)
 
;out:
;ds:si = string ASCII text (16bit prt)
 
       mov      di,buf ;di = work buffer for OutTextRadix50RealMode
       call     Rad2AsciiStringRM
       push     si
       xor      esi,esi
       pop      si
       push     si
       call     .checkDollarAndZeroPut
 
       pop      si
       call     PrintToEmdStr
 
       ret
 
 
.checkDollarAndZeroPut:
       mov      cx,70
.checkIt:
       mov      al, byte [si]
       cmp      al, '$'
       jz       .ok
       inc      si
       dec      cx
       jnz      .checkIt
 
       mov      al, '$'
       mov      [si],byte al
.ok:
       mov      [si],byte 0
       ret
 
 
 
;EOF
