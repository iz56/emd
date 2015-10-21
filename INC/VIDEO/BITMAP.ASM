;bitmap.asm
 
;x86 cpu unreal mode cod
 
macro AddEaxLi {
add eax,dword [Lighit]
}
 
 
 ADD_LIGHIT = 0x111111;0x0101010
 DEF_LIGHIT = 0x0202020;0x0101010
 
 COM_COLOR32 = 0x03a3a3a
 
 
        BACKCOLOR = 0x0;0x028a8f8;fffff
 
;        BACKCOLOR = 0x01;028a8f8;fffff
;       КОД_ЦВЕТ_ПЕСОЧНЫЙ_ЯРКИЙ = 0x0ffcc00
;       КОД_ЦВЕТ_СЕРЫЙ = 0x0c8c8c8
;       КОД_ЦВЕТ_СВИНЦОВЫЙ = 0x07898c8
;       КОД_ЦВЕТ_СЕРОСИНИЙ_СВЕТЛЫЙ = 0x0bdc7d6
;       КОД_ЦВЕТ_ЗЕЛЕНЫЙ = 0x0008080
;       КОД_ЦВЕТ_БОЛОТНЫЙ_ЗЕЛЕНЫЙ = 0x074744a
;       КОД_ЦВЕТ_СВЕТЛО_ЗЕЛЕНЫЙ = 0x0c0dcc0
;       КОД_ЦВЕТ_ОРАНЖЕВОКОРИЧНЕВЫЙ = 0x0eec585
;       КОД_ЦВЕТ_СОЧНО_ГОЛУБОЙ = 0x028a8f8
 
 
       SELECT_COLOR = 0x00101010;0x0777878;0x01111
 
 
 
 
 
;       ШИРИНА_КАРТИНКИ = 8
;       ДЛИНА_КАРТИНКИ = 8
;       РАЗМЕР_БИТОВОЙ_КАРТЫ_БАЙТАХ = 8
       ОТСТУП_СВЕРХУ = 800*4*10
       ОТСТУП_СНИЗУ = 8
       ОТСТУП_СЛЕВА = 0;80*4;\
       ОТСТУП_СПРАВА = 0;79*4 ;80*4;/
       МЕЖСТРОЧНЫЙ_ИНТЕРВАЛ = 800*14*4
       МЕЖСИМВОЛЬНЫЙ_ИНТЕРВАЛ = 8 ;4
 
 
       ЦВЕТ_СИМВОЛА = 0x04444;0x03333;535353
       ЦВЕТ_ФОНА = BACKCOLOR
 
;esi = массив символов и аттрибутов 80 на 25 строк
;edi = font
;используем шрифт 8x8
 
    tempflag dd 0 ; ]]]]]]]]]
 
 
DrawVideoPage:
 
cmp   [tempflag],dword 0  ; ]]]]]]]]
jnz .fffff ;]]]]]]]]]
      call     DrawBack  ;]]]]]]]]]
mov   [tempflag],dword 1   ;]]]]]]]]]
.fffff:  ; ]]]]]]]]]
 
       call     DrawCursorY
       call     DrawCursorX
 
       call     .Init
 
       mov      ebx,dword [VideoLinear]
       add      ebx,dword ОТСТУП_СВЕРХУ
 
       mov      [.saveEbx],dword ebx ;начальное значение
 
       mov      esi,dword [.ArrayChrs80x25]
       mov      [.saveEsi],dword esi ;начальное значение
 
       mov      cx,25 ;кол-во строк на экране
 
.mainCycle:
       push     cx
       call     .GetAttr ;сохраняем аттрибуты в буфер отдельно
       call     .GetStr ;и коды символов преобразуем в бит-карту
       call     .Draw
       pop      cx
       dec      cx
       jnz      .mainCycle
 
       ret
 
 
 
.Draw:
; далее ebx - указатель на видео-память
       mov      ebx,dword [.saveEbx]
       add      ebx,dword МЕЖСТРОЧНЫЙ_ИНТЕРВАЛ
 
macro put_pix { mov [fs:ebx],dword eax }
 
       mov      esi,edi
       mov      ax,word 8 ;всего нужно отрисовать 8 линий
 
.nextLine:
       add      ebx,dword ОТСТУП_СЛЕВА
 
       mov      edi,20 ;edi - длина сроки пикселей в dword-ax
       push     ax
 
       xor      eax,eax
       mov      dword [.ИндексНаТекущийАттрибут],eax
       call     .GetNextColor ;инициализирует переменные .CharColor .FonColor
 
.nextDD:
       mov      eax,dword [esi]
       add      esi,dword 4
 
       mov      edx,eax
       mov      ecx,32
.DrawDrord:
       mov      eax,edx
       shl      eax,31
       test     eax,eax
       jz       .zeroPix
       mov      eax,dword [.CharColor]
AddEaxLi
 
       put_pix
       jmp      .okk
.zeroPix:
       mov      eax,dword [.FonColor]
 
       put_pix
.okk:
 
       add      ebx,4
       shr      edx,1
 
 ;;
       cmp      ecx,dword 32-7
       jnz      .AAffff
       add      ebx,dword МЕЖСИМВОЛЬНЫЙ_ИНТЕРВАЛ
       call     .GetNextColor
.AAffff:
       cmp      ecx,dword 17
       jnz      .AAffff2
       add      ebx,dword МЕЖСИМВОЛЬНЫЙ_ИНТЕРВАЛ
       call     .GetNextColor
.AAffff2:
       cmp      ecx,dword 9
       jnz      .AAffff23
       add      ebx,dword МЕЖСИМВОЛЬНЫЙ_ИНТЕРВАЛ
       call     .GetNextColor
.AAffff23:
       cmp      ecx,dword 1
       jnz      .AAffff231
       add      ebx,dword МЕЖСИМВОЛЬНЫЙ_ИНТЕРВАЛ
       call     .GetNextColor
.AAffff231:
 ;;
 
       dec      ecx
       jnz      .DrawDrord
       dec      edi
       jnz      .nextDD
 
       add      ebx,dword ОТСТУП_СПРАВА
 
       pop      ax
       dec      ax
       jnz      .nextLine
 
       mov      dword [.saveEbx],ebx
 
       ret
 
 
.GetNextColor: ;достаёт аттрибуты и определяет цвет пикселей
 
       mov      eax, dword [.ИндексНаТекущийАттрибут]
       cmp      eax,dword 80
       jz       .ИтоговыйПускGNC
 
       mov      [.tmpEsi],dword esi
       mov      eax,dword [.ИндексНаТекущийАттрибут]
       inc      eax
       mov      [.ИндексНаТекущийАттрибут],dword eax
       dec      eax
       mov      esi,dword [.tmpBufForStringAttrbs]
       add      esi,eax
 
;по умолчанию инит цвет фона
       mov      eax,dword ЦВЕТ_ФОНА
       mov      [.FonColor],dword eax
 
       xor      eax,eax
       mov      al,byte [esi]
       cmp      al,7
       jnz      .not7
       mov      eax,dword ЦВЕТ_СИМВОЛА
AddEaxLi
 
       mov      [.CharColor],dword eax
       mov      esi,dword [.tmpEsi]
       ret
 
.not7:
       cmp      al,23 ;23 - это признак-атрибут выделения текста
       jnz      .not23
 
       mov      eax,dword ЦВЕТ_СИМВОЛА
;mov eax,dword SELECT_COLOR
AddEaxLi
 
       mov      [.CharColor],dword eax
;       mov      eax,dword 0x0111000
mov eax,dword SELECT_COLOR
 
AddEaxLi
 
       mov      [.FonColor],dword eax
       mov      esi,dword [.tmpEsi]
ret
 
.not23:
 
       cmp      al,8 ;8 - это признак-атрибут закомментированного текста
       jnz      .not8
 
       mov      eax,dword COM_COLOR32;0x01a1a1a;02000;ЦВЕТ_СИМВОЛА+0x0ff
AddEaxLi
 
       mov      [.CharColor],dword eax
 
       mov      esi,dword [.tmpEsi]
       ret
 
 
.not8:
 
       cmp      al,byte COLOR_ASCII_TXT
       jnz      .notCOLOR_ASCII_TXT
       mov      eax,dword 0x01113000;ЦВЕТ_СИМВОЛА+0x0ff
AddEaxLi
 
       mov      [.CharColor],dword eax
       mov      esi,dword [.tmpEsi]
       ret
 
 
.notCOLOR_ASCII_TXT:
       mov      eax,dword 0x0333000;ЦВЕТ_СИМВОЛА+0x0ff
AddEaxLi
 
       mov      [.CharColor],dword eax
       mov      esi,dword [.tmpEsi]
       ret
 
.ИтоговыйПускGNC:
       xor      eax,eax
       mov      dword [.ИндексНаТекущийАттрибут],eax
       ret
 
.ИндексНаТекущийАттрибут dd 0
.tmpEsi dd 0
 
;end GetNextColor
 
 
;============
.GetAttr:
       mov      ecx,80
       mov      ebx,dword [.tmpBufForStringAttrbs]
       mov      esi,dword [.saveEsi]
 
 
.fl1:
       mov      al,byte [esi+1] ;теперь собираем цвет
       mov      [ebx],byte al
       inc      ebx
       inc      esi ;2
       inc      esi ;2
       dec      ecx
       jnz      .fl1
       mov      esi,dword [.saveEsi]
 
       ret
 
;===========
.GetStr:
       mov      ecx,80
       mov      ebx,dword [.tmpBufForStringChars]
       mov      esi,dword [.saveEsi]
 
 
.l1:
       mov      al,byte [esi]
       mov      [ebx],byte al
       inc      ebx
       inc      esi ;2
       inc      esi ;2
       inc      edi
       dec      ecx
       jnz      .l1
 
;save esi
       mov      [.saveEsi],dword esi
 
       mov      esi,dword [.tmpBufForStringChars]
       mov      edi,dword [.tmpBufForArrayPixs]
       mov      ecx,80
.l2:
       xor      eax,eax
       mov      al,byte [esi]
       imul     eax,8
       mov      ebx,dword [.Font]
       add      ebx,eax
;теперь в ebx (ptr) битовая карта символа
 
;       repeat   8
;       mov      al,[ebx]
;       inc      ebx
;       mov      [edi],byte al
;       inc      edi
;       end      repeat
 
       repeat   2
       mov      eax,dword [ebx]
       mov      [edi],dword eax
       add      ebx,4
       add      edi,4
       end      repeat
 
 
       inc      esi
       dec      ecx
       jnz      .l2
 
       call     .Convert
 
       ret
 
 
;-----------
.Convert:
;преобразуем череду изображений символов в одно - цельное из-ние строки
       mov      edx,8
       mov      esi,dword [.tmpBufForArrayPixs]
       mov      eax,esi
       add      eax,80*8
       mov      edi,eax
       add      edi,edx
.DFF:
;inc dword [.tmpBufForArrayPixs]
       mov      esi,dword [.tmpBufForArrayPixs]
       mov      ecx,80
       inc      dword [.tmpBufForArrayPixs]
 
.MovL:
       xor      eax,eax
       mov      al,[esi]
 
;------------меняем местами биты - зеркало
       push     dx
       mov      dl,1
       call     .Cycle
       mov      dl,010b
       call     .Cycle
       mov      dl,0100b
       call     .Cycle
       mov      dl,01000b
       call     .Cycle
       mov      dl,010000b
       call     .Cycle
       mov      dl,0100000b
       call     .Cycle
       mov      dl,01000000b
       call     .Cycle
       mov      dl,010000000b
       call     .Cycle
       jmp      .ok
 
.Cycle:
       rol      al,1
       jnc      .not1
       add      ah,dl
.not1:
       ret
 
.ok:
       pop      dx
;-----------------------------------------
 
       mov      [edi],ah ;al|ah = зеркально обратный порядок битов
       add      esi,8
       inc      edi
       dec      ecx
       jnz      .MovL
       dec      edx
       jnz      .DFF
 
       mov      eax,dword [.tmpBufForArrayPixs]
       add      eax,80*8
       mov      edi,eax
 
       ret
 
.Init:
;подготовка
       mov      [.ArrayChrs80x25], dword esi
       mov      [.Font], dword edi
       mov      eax,dword [StartMemory]
       mov      edx,dword [SizeTextFormatted]
       add      eax,edx
       add      eax,dword 1000h
 
       mov      dword [.tmpBufForStringChars],eax
       add      eax,dword 80
       mov      dword [.tmpBufForStringAttrbs],eax
       add      eax,dword 80
 
       mov      dword [.tmpBufForArrayPixs],eax
 
       xor      eax,eax
       mov      [.x],dword eax
       mov      [.y],dword eax
 
       ret
 
.x dd 0
.y dd 0
.ArrayChrs80x25 dd 0
.Font dd 0
 
.tmpBufForStringChars dd 0
.tmpBufForStringAttrbs dd 0
.tmpBufForArrayPixs dd 0
 
.saveEsi dd 0
.saveEbx dd 0
 
.CharColor dd ЦВЕТ_СИМВОЛА
.FonColor dd ЦВЕТ_ФОНА
Lighit dd DEF_LIGHIT ;global variable - use in emd.asm (F8 key)
 
 
;EOF
