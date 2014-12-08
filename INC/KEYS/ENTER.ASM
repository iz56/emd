;enter.asm
 
 
;обрабатываем нажатие enter
EnterLine:
 
;очищаем память после конца текста (нужно если весь текст меньше экрана)
       call     EraseMemory ;inc\erase.asm
 
;проверяем наличие свободной
;памяти с двухкратным запасом (возможность обработать текст для сохранения)
       mov      eax,[SizeTextFormatted] ;текущий размер несжатого текста
       shl      eax,1 ;(умножаем на 2)
       add      eax,dword CHAR_ON_LINE*2
       mov      ebx,eax
       add      ebx,dword [StartMemory]
 
       cmp      ebx,dword [EndMemory]
       jae      .close ;мало памяти
 
;сохраняем для случая shift+enter
       mov      al,[x]
       mov      [.tmpX],al
 
;если конец текста
       mov      ebx,[IndexPageActive]
       xor      eax,eax
       mov      al,[y]
       inc      al
       imul     ax,CHAR_ON_LINE
       add      ebx,eax
       cmp      [SizeTextFormatted],ebx
       jbe      .end_of_text
;середина и начало
       mov      ebx,[StartMemory] ;начало текста
       add      ebx,[IndexPageActive] ;текущая страница
       xor      eax,eax ;обнуляем eax
       inc      [y]
       mov      al,[y] ;al - следующая строка
       cmp      al,LINES_ON_SCR
       jz       .end_of_page
 
.ok_page:
       imul     ax,CHAR_ON_LINE
       add      ebx,eax ;ebx - место вставки пустой строки
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
 
       mov      byte [x],0;переводим курсор в начало
       jmp      .pasteLineComplete
 
;когда нужно перемотать экран вниз
.end_of_page:
       mov      al,24
       mov      [y],al
       inc      al
       add      dword [IndexPageActive],CHAR_ON_LINE
       jmp      .ok_page
 
.end_of_text:
 
       add      dword [SizeTextFormatted],CHAR_ON_LINE
 
       mov      byte [x],0 ;переводим курсор в начало строки
       inc      [y]
       cmp      [y],LINES_ON_SCR
       jnz      .pasteLineComplete
       add      dword [IndexPageActive],CHAR_ON_LINE
       mov      [y],24
; jmp .pasteLineComplete
 
 
.pasteLineComplete:
; нажата клавиша shift ?
       cmp      byte [FlagKeyShift],1
       jz       .EnterShift_CutLine
 
       ret      ; работа сделана для одиночного Enter
 
 
;shift+enter - дорабатываем
.EnterShift_CutLine:
 
;узнаем правый или левый shift
;флаг состаяния клавиатуры (BIOS data area)
mov al,byte [fs:0+00417h]
       shl      al,7
       cmp      al,0
       jz       .leftShiftPressed
 
 
;здесь обрабатываем правый shift+enter
       xor      eax,eax
       mov      al,[.tmpX]
       cmp      al,0
       jnz      .go
       ret
.go:
       push     ax ;ax=место разреза строки
 
       mov      ebx,[StartMemory] ;начало текста
       add      ebx,[IndexPageActive] ;текущая страница
 
       xor      eax,eax
       mov      al,[y]
 
       imul     ax,CHAR_ON_LINE
       add      ebx,eax ;ebx - пустая строка
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
       sub      eax, dword CHAR_ON_LINE ;вычислим оставшиеся символы - колиество
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
       mov      al,32 ;дополним строку пробелами
.move32:
       mov      [edi],al
       inc      edi
       dec      cx
       jnz      .move32
 
       dec      [y]
 
       ret      ; работа сделана для Enter+Shift(правый)
 
 
.tmp_edi dd 0
 
.leftShiftPressed:
 
       mov      ebx,[StartMemory] ;начало текста
       add      ebx,[IndexPageActive] ;текущая страница
 
       xor      eax,eax
       mov      al,[y]
 
       imul     ax,CHAR_ON_LINE
       add      ebx,eax ;ebx - пустая строка
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
 
       ret      ; работа сделана для Enter+Shift(левый)
 
.tmpX db 0
 
 
.close:
;если памяти мало
       sub      dword [SizeTextFormatted],CHAR_ON_LINE
 
 
;очистка экрана
       mov      eax,07200720h
       mov      edi,dword 4000
.cls:
mov dword [gs:0+di],eax
 
       sub      edi,dword 4
       jnz      .cls
mov dword [gs:0+di],eax
 
;------------------cursor------------------
       mov      ah,02h ;- bios servis
       mov      bh,0
       mov      dh,24
       mov      dl,0
       int      10h
;------------------------------------------
 
       mov      si,.msgErrorMemory
       mov di,buf
       call     OutTextRadix50RealMode
 
 biosKBDwait ;inc\macro.asm
       ret ;зывершение с выводом сообщения ошибки
 
.msgErrorMemory:
db 022h ,022h ,090h ,060h ,0ech ,059h ,00dh ,002h ,0aah ,053h ,078h ,0a0h
 
 
 
;EOF
