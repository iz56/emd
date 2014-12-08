;help.asm

HelpMenu:

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

.TipeOfMenu dd INFO_MENU_TIPE;тип алгоритма меню

.StrsTbl:
db '  1 - Help Exit ---------- ',0
db ' 2 - Save Document ------- ',0
db ' 3 - Exit to OS ---------- ',0
db ' 4 - Copy&Paste ---------- ',0
db ' 5 - Swith Video Mode ---- ',0
db ' 6 - F3 key -------------- ',0
db ' 7 - Cut Strings --------- ',0


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

;-------------------------------------------------------------------------------
.dum:
       ret
;--------
; mov esi , dword .saveText
.item:
;clear back area
       mov      edi,dword [VideoBufMemory]
       mov      ax,0720h
       mov      ecx,1000
.l1:
       mov      [edi],dword eax
       add      edi,4
       dec      ecx
       jnz      .l1

       mov      edi,dword [VideoBufMemory]
;print topic ,start on 10th line
       add      edi,dword 160*10
; mov esi , dword .saveText
       call     .PrintHelpTopicText
       ret

.item1:
       mov      esi , dword .ExitHelpText
       call     .item
       ret

.ExitHelpText:
db 'Выход из помощи <ESC> . ' ,0

;----


;--------
.item2:
       mov      esi , dword .saveText
       call     .item
       ret
.saveText:
db 'Сохранение изменённого текста возможно '
db 'только с одновременным выходом из программы при нажатии <F2>'
db '. Потом запускаем редактор снова - курсор будет там же где и был',0

;----


.item3:
       mov      esi , dword .escText
       call     .item
       ret
.escText:
db 'Выход из программы без сохранения изменений в тексте - '
db 'всегда при нажатии <ESC>.'
db 'Если запускаем редактор снова - курсор будет там где был,'
db 'при посленднем сохранении. Если только вы работаете с несколькими '
db 'файлами текстов одновременно - запоминается посленний сохранённый.'
db 'Место хранения координат курсора в памяти и стирается при откл. питания.',0

;----
.item4:
       mov      esi , dword .CopyPastText
       call     .item
       ret
.CopyPastText:
db 'Копирование и вставка текста возможна только строками . Для выделения '
db 'нужных строк текста - стрелка вниз и шифт. Вставка - <F5>.'
db ' Строки из буфера сохраняются на жест. диске, если существует файл -'
db ' c:\tmp\emd.tmp . Можно переносить текст из файла в файл' ,0

;----

.item5:
       mov      esi , dword .SwithVideoModeText
       call     .item
       ret
.SwithVideoModeText:
db 'Переключение из текстового, стандартного видеорежима в графический - <'
db 'F8>. И обратно - та же клавиша. Находясь в гр. режиме - можно удержива'
db 'я <Shift>+<F8> - изменить палитру - уменьшить яркость цветов. ',0

;----

.item6:
       mov      esi , dword .GoToF3Text
       call     .item
       ret

.GoToF3Text:
db 'При нажатии <F3> ,при условии , что текущая строка - строка передачи '
db 'управления (ассемблере) , курсор перейдёт на целевую строку. ',0

;----

.item7:
       mov      esi , dword .CutStrText
       call     .item
       ret

 .CutStrText:
db 'При нажатии <Shift>+<Enter> - строка бедет разрезана на две.'
db ' Правый или левый <Shift> - имеет значение.' ,0

;----


;-----
;print topic
.PrintHelpTopicText:
pusha
mov eax,[.leftSpaces]
shl eax,1 ;x2
add edi,eax
mov ecx,[.checkRightSpaces]

.PrintItLine:
       mov      al,byte [esi]
       inc      esi
       mov      ah,7
       mov      word [edi],ax
       add      edi,dword 2
       test     al,al
       jz      .PrintHelpTopicTextOut
dec ecx
jnz .PrintItLine
mov eax,[.leftSpaces]
add eax,[.rightSpaces]
shl eax,1 ;x2
add edi,eax
mov ecx,[.checkRightSpaces]
jmp .PrintItLine


.PrintHelpTopicTextOut:
popa
       ret
.leftSpaces dd 8
.rightSpaces dd 12 ;80-60-8
.checkRightSpaces dd 60


;EOF
