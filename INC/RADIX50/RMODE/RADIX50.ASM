;radix50.asm
 
 
;вывод на зкран строки в кодировке radix50
; ds:si = ptr Rad string
OutTextRadix50RealMode:
 
;in:
;ds:si = sring RADIX50 (16bit ptr)
;ds:di = buffer for work (16bit prt)
;out:
;ds:si = string ASCII text (16bit prt)
 
       mov      di,buf ;di = work buffer for OutTextRadix50RealMode
       call     Rad2AsciiStringRM
       mov      dx,si
 
       call     .checkDollar
 
       mov      ah,9
       int      21h
 
       ret
 
.checkDollar:
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
 
       ret
 
;входные даные:
;si = текст в кодировке RADIX50 (16bit ptr)
;di = buffer for work (16bit prt)
 
;выходные даные:
;si = здесь будет ASCII text (16bit prt)
 
Rad2AsciiStringRM:
 
       push     di ; адрес буфера - там результат
 
.l1:
       call     EncodingR50RM
       call     Rad2AsciiRM
       add      si,word 2
       add      di,word 3
 
       mov      al,byte [di-3-3]
       cmp      al,'$' ;line terminator
       jz       .l2
 
       mov      al,byte [di-2-3]
       cmp      al,'$'
       jz       .l2
       mov      al,byte [di-1-3]
       cmp      al,'$'
       jnz      .l1
 
.l2:
       pop      si
       ret
 
;si = ptr RADIX50 x,y,z (2 byte)
;di = ptr result (3 byte)
 
EncodingR50RM:
 
;обнуляем место под 3 байта
       mov      byte [di],0
       mov      byte [di+1],0
       mov      byte [di+2],0
 
;получаем слово с кодом RADIX50
       mov      ax,word [si]
 
       cmp      ax,word 1600 ;старший разряд = 0?
       jb       .b1600
.l2:
       inc      byte [di]
       sub      ax,word 1600
       cmp      ax,word 1600
       jae      .l2
 
.b1600:
       cmp      ax,word 40 ;второй разряд
       jb       .b40
.l4:
       inc      byte [di+1]
       sub      ax,word 40
       cmp      ax,word 40
       jae      .l4
 
.b40:
       mov      [di+2],byte al ;остаток = третий разряд
 
       ret
 
 
;di = ptr RADIX50 x,y,z (3 byte)
;di = ptr result (3 byte)
Rad2AsciiRM:
 
       mov      al,byte [di]
       call     .Translate ;translate
       mov      [di],byte al
 
       mov      al,byte [di+1]
       call     .Translate
       mov      [di+1],byte al
 
       mov      al,byte [di+2]
       call     .Translate
       mov      [di+2],byte al
 
       ret
 
.Translate:
       mov      bx,TableVAX ;таблица для перекодирования RADIX-50 >> ASCII
       shl      ax,8
       shr      ax,8
       add      bx,ax
       mov      al,byte [bx]
       ret
 
TableVAX db ' ABCDEFGHIJKLMNOPQRSTUVWXYZ$.%0123456789'
 
 
;EOF
