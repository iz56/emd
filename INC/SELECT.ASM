;select.asm
 
 
;вход: ah содержит сканкод нажатой клавиши
;dl = [FlagKeyShift] ,dh = [FlagTextSelect]
 
SelectBlockText:
 
 
;проверяем нажатие клавиш и флагов
       cmp      dl,0;[FlagKeyShift];,byte 0
       jz       .NotKeyShiftPress
 
;нажатa shift - проверяем флаг выделения блока строк
       cmp      dh,0;[FlagTextSelect];,byte 0
       jz       .FlagTextSelectZero
 
;проверяем сканкод - если не 50h заканчиваем выделение
       cmp      ah,50h ;теперь регистр ax is free
       jnz      .EndSelect
 
 
;----------------------
;проверяем конец текста
;если текущая строка в конце текста - заканчиваем выделение принудительно
       mov      ebx,[IndexPageActive]
       xor      eax,eax
       mov      al,[y]
       inc      al
 
; imul ax,CHAR_ON_LINE
       imulEax80
 
       add      ebx,eax
       cmp      ebx,[SizeTextFormatted]
       jae      .EndSelect
;----------------------
 
 
       add      dword [SizeTextSelect],CHAR_ON_LINE ;увеличиваем счетчик
; выд. текста
 
;здесь проверяем размер выделенного текста
       cmp      dword [SizeTextSelect],SIZE_TXT_BUF
       ja       .EndSelect;заканчиваем выделение
 
;здесь подсвечиваем выделяемый текст
       xor      eax,eax
       mov      al,[y]
;проверяем движение экрана
       cmp      al,24
       jnz      .OnPage
 
;подсвечиваем строку на экране сверху
       mov      esi,0
; mov ebx,dword [VideoBufMemory]
 
.scan23:
       mov      ebx,dword [VideoBufMemory]
       add      ebx,esi
       mov      al, byte [ebx+1]
       add      esi,160;2
       cmp      esi,4000
       jz       .OnPage;никогда
       cmp      al,23
       jnz      .scan23
       cmp      esi,160
       jz       .si_is_good
       sub      esi,160*2
.si_is_good:
       mov      edi,esi
       mov      cx,CHAR_ON_LINE
       jmp      .ColoredLine
 
.OnPage:
 
; imul ax, word CHAR_ON_LINE
       imulEax80
 
       mov      bx,ax
       add      ax,bx
       mov      di,ax
;inc di
       mov      cx, word CHAR_ON_LINE
 
.ColoredLine:
; gs=0b800h
       mov      bx,di
       xor      edi,edi
       mov      di,bx
       mov      ebx,dword [VideoBufMemory]
;shl edi,16
;shr edi,16
       add      ebx,edi
       mov      [ebx+1], byte 23
       add      edi,dword 2
       dec      cx
       jnz      .ColoredLine
       ret
 
 
.FlagTextSelectZero:
       cmp      ah,50h
       jz       .l1
       ret
.l1:
 
       xor      eax,eax
       mov      al,byte [y]
; imul ax,CHAR_ON_LINE
       imulEax80
 
       mov      ebx,dword [StartMemory]
       add      ebx,dword [IndexPageActive]
 
       add      eax,ebx
       mov      esi,eax
       mov      byte [FlagTextSelect],1
       mov      dword [SizeTextSelect],CHAR_ON_LINE
 
;помещаем выделенный текст сюда
       mov      edi,[ptrCopyPasteBuffer]
 
;05.02.2012
 
;копируем текст заранее ,полностью заполняя буфер
       mov      ecx, dword SIZE_TXT_BUF ;!
 
       call     movsbVersion32
 
 
;здесь подсвечиваем выделяемый текст (- line)
       xor      eax,eax
       mov      al,[y]
       jmp      .OnPage ;см. выше
 
 
.NotKeyShiftPress:
 
;проверяем FlagTextSelect
       cmp      byte [FlagTextSelect],0
       jnz      .EndSelect
       ret
 
;заканчиваем выделение текста
.EndSelect:
       beep
       xor      eax,eax
       mov      [FlagTextSelect], byte al
       redraw   ;заполнение
       colored
       ret
 
;EOF
