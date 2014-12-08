;checkf.asm
;Warning user for error.
 
 
DebugCheckSizeFormTxt:
 
;внутренняя проверка размера - you can delete it
       mov      eax,[SizeCheckEr]
       cmp      eax,[SizeTextFormatted]
       jz       .exit
 
;error size - внутренняя ошибка
cls 4
;------------------cursor------------------
       mov      ah,02h ;- bios servis
       mov      bh,0
       mov      dh,12
       mov      dl,0
       int      10h
;------------------------------------------
 
       mov      si,.Msg
       mov      di,buf
       call     OutTextRadix50RealMode
       call     WaitPressAnyKey
 
       mov      eax,[SizeCheckEr]
       mov      [SizeTextFormatted],eax
       .exit:
 
ret
 
 
.Msg:
db 084h ,03ah ,01eh ,022h ,020h ,008h ,022h ,022h ,090h ,060h ,042h ,078h ,078h
db 023h ;RADIX-50 text
SizeCheckEr dd 0
 
 
;EOF
