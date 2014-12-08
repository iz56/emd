;f7menu.asm
F7Menu:
 
;смещение на таблицу указателей вызываемого из меню кода
.pCodsTbl dd .CodsPtrsTbl
 
;смещение на таблицу текстовых строк соответствующих пунктам меню
.pStrTbl dd .StrsTbl
 
.cItems dd 7 ;число items пунктов меню (всего|total)
 
.SizeStr dd 27 ; size of 1 text string
 
.PosW dd 16 ; position of text window (*2)
 
.ActiveItem dd 1 ;текущая строка
 
.colorNotActivItem dd 7;цвет неактивных пунктов меню
 
.colorActivItem dd 23;цвет активных пунктов меню
 
.TipeOfMenu dd ACTION_MENU_TIPE;тип алгоритма меню
 
.StrsTbl:
db ' 1 - On|Off clock ------- ',0
db ' 2 - On|Off word light --- ',0
db ' 3 - Delete empty lines -- ',0
db ' 4 - Replace word -------- ',0
db ' 5 - xxxxxxxxxxxx--------- ',0
db ' 6 - xxxxxxxxxxxx--------- ',0
db ' 7 - xxxxxxxxxxxx--------- ',0
 
 
dw .dum ;действие по умолчанию
;-------------------------------------------------------------------------------
.CodsPtrsTbl:
dw .item1
dw .item2
dw .item3
dw .item4
dw .item5
dw .item6
dw .item7
dw .dum ;действие по умолчанию
dw .dum ;действие по умолчанию
 
;-------------------------------------------------------------------------------
.dum:
       ret
;--------
 
.item1:
       call     SwithClockOnOff
       ret
;----
.item2:
       call     SwithColorOnOff
       ret
 
;----
 
;----
.item3:
       call     DeleteEmptyLines ;inc/delline.asm
       ret
 
;----
;----
.item4:
 
       call     ReplaceWord ;inc/replace.asm
       ret
 
;----
;----
.item5:
       ret
 
;----
 
;----
.item6:
       ret
 
;----
 
;----
.item7:
       ret
 
;----
;----
;item8:
; ret
 
;----
 
;EOF
