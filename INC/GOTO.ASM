;goto.asm
 
;при нажатии f3 анализируем строку на которой курсор
;и если это переход на метку - то ищем строку с этой меткой и туда
GotoLabel:
       mov      al,[x]
       mov      [.xsave],al
 
       call     Animation
 
       mov      eax,dword [SizeTextFormatted]
       cmp      eax,dword CHAR_ON_LINE*25
       ja       .ok
       ret ;--------exit[1]
.ok:
       call     GoToMacro ;search for macro
       jc       .Complete
       clc
       call     GoToData ;search for dd,db,dw,label:
       jc       .Complete
       clc
       call     GoToLabelDo
.Complete:
 
       mov      al,[.xsave]
       mov      [x],al
       ret ;--------exit[2]
.xsave db 0
 
 
GoToLabelDo:
 
       mov      al,':'
       mov      [PostLabelChar],al
       call     GetLnAdr ;emd.asm
       mov      [.LnAdr],eax
 
.ЕслиПервыйПоискНеудачен:
       mov      esi,[.LnAdr]
       mov      ecx, dword CHAR_ON_LINE ;ecx=длина строки
.NextWrd:
       call     GetLabelName
       jc       .Exit
 
;сохраним регистры ecx esi
       mov      [.tmp],dword ecx
       mov      [.tmp+4],dword esi
       call     CheckInTable
;restore регистры ecx esi
       mov      ecx,dword [.tmp]
       mov      esi,dword [.tmp+4]
 
       jc       .NextWrd
 
;перемотка найденого слова
;----->
       push     bx
       mov      bx,4 ;длина самой длинной call
.l11:
       dec      bx
       jc       .Exit
 
       mov      al,[esi]
       inc      esi
       cmp      al,' '
       jnz      .l11
 
       pop      bx
;----->
 
       call     GetLabelName
       jc       .Exit
 
       dec      esi
;теперь esi адресует слово для поиска ecx = длина не более этого
       call     FindWordLabel
.Exit:
 
       mov      al,byte [PostLabelChar]
       test     al,al
       jnz      .Ище
       ret ;--------exit[1]
.Ище:
       cmp      al,' '
       jnz      .l111
       ret ;--------exit[2]
.l111:
 
       mov      al,' '
       mov      [PostLabelChar],al
       jmp      .ЕслиПервыйПоискНеудачен
 
.tmp dd 0,0
.LnAdr dd 0
 
PostLabelChar db 0
 
 
;===============================================================================
FindWordLabel:
       mov      [.MaxSize],dword ecx
       mov      [.WordAdr],dword esi
 
       inc      esi
;подсчет длины
;----->
       xor      edx,edx
.l1:
       mov      al,[esi]
       inc      esi
       cmp      al,' '
       jz       .fded
       cmp      al,';'
       jz       .fded
       inc      edx
       dec      ecx
       jnz      .l1
 
.fded:
       mov      [.Size],dword edx
;----->
 
       mov      eax,dword [StartMemory]
       add      eax,dword [SizeTextFormatted]
       mov      [.EndTextAdr],dword eax
 
 
;вычисляем адрес текущей строки в памяти
       call     GetLnAdr ;emd.asm
;eax =ptr
       mov      [.MainLineAdr], dword eax
 
;готовим индексные переменные
       mov      eax, dword CHAR_ON_LINE ;ecx=длина строки
 
       mov      [.iUp],dword eax
       mov      [.iDn],dword eax
 
;цикл поиска от текущей строки
.следИтерация:
 
       call     .nextUp
       mov      eax,dword 1
       cmp      edi,0
       jz       .End
       call     .CheckStr
       jc       .End2
 
 
       call     .nextDn
       mov      eax,dword 2
       cmp      edi,0
       jz       .End
       call     .CheckStr
       jc       .End2
 
       jmp      .следИтерация
 
.End:
       cmp      eax,dword 1
       jnz      .добиваемUp
 
.ДобиваемDn:
       call     .nextDn
       cmp      edi,0
       jz       .End2
       call     .CheckStr
       jc       .End2
 
       jmp      .ДобиваемDn
 
.добиваемUp:
       call     .nextUp
       cmp      edi,0
       jz       .End2
       call     .CheckStr
       jc       .End2
       jmp      .добиваемUp
 
.End2:
       ret ;--------exit[1]
 
 
 
.CheckStr:
       mov      ebx,edi
       mov      esi,dword [.WordAdr]
       mov      al,[esi]
       cmp      al,byte [edi]
       jnz      .нетСовпадения
 
       mov      ecx,dword [.Size]
       test     ecx,ecx
       jnz      .БолееОдного
       mov      al,[esi]
       cmp      al,byte [edi]
       jnz      .нетСовпадения
mov al,[PostLabelChar];':'
       cmp      al,byte [edi+1]
       jz       .естьСовпадение
       jmp      .нетСовпадения
 
 
.БолееОдного:
 
       inc      esi
       inc      edi
.сравниваем:
       mov      al,[esi]
       cmp      al,byte [edi]
       jnz      .нетСовпадения
       inc      esi
       inc      edi
       dec      ecx
       jnz      .сравниваем
;mov al,':'
       mov      al,[PostLabelChar]
 
       cmp      al,byte [edi]
       jnz      .нетСовпадения
 
.естьСовпадение:
; add ebx,80
       call     SetPage
       mov      byte [PostLabelChar],0
       stc
       ret ;--------exit[2]
 
.нетСовпадения:
       clc
       ret ;--------exit[3]
 
 
;-------
.nextUp:
 
       mov      eax,dword [.MainLineAdr]
       sub      eax,dword [.iUp]
       cmp      eax,dword [StartMemory]
       jz       .endUp
       mov      edi,eax
 
       mov      eax,dword [.iUp]
       add      eax,dword CHAR_ON_LINE
       mov      [.iUp],dword eax
       ret ;--------exit[x]
 
.endUp:
       xor      edi,edi
       ret ;--------exit[x]
;-------
 
 
;-------
.nextDn:
       mov      eax,dword [.MainLineAdr]
       add      eax,dword [.iDn]
       cmp      eax,dword [.EndTextAdr]
       jz       .endDn
       mov      edi,eax
 
       mov      eax,dword [.iDn]
       add      eax,dword CHAR_ON_LINE
       mov      [.iDn],dword eax
       ret ;--------exit[x]
 
.endDn:
       xor      edi,edi
       ret ;--------exit[x]
;-------
 
.MaxSize dd 0
.WordAdr dd 0
.Size dd 0
.EndTextAdr dd 0
.iUp dd 0
.iDn dd 0
.MainLineAdr dd 0
 
 
;-------------
CheckInTable:
;
       cmp      al,'j'
       jnz      .notJ
 
       mov      ax,word [esi]
       cmp      ax,'e '
       jz       .ok
 
       cmp      ax,'c '
       jz       .ok
 
 
       cmp      ax,'z '
       jz       .ok
 
       cmp      ax,'a '
       jz       .ok
 
       cmp      ax,'b '
       jz       .ok
 
       mov      eax,dword [esi-1]
 
       cmp      eax,'jae '
       jz       .ok
 
       cmp      eax,'jaz '
       jz       .ok
 
       cmp      eax,'jbz '
       jz       .ok
 
       cmp      eax,'jbe '
       jz       .ok
 
       cmp      eax,'jnz '
       jz       .ok
 
       cmp      eax,'jne '
       jz       .ok
 
       cmp      eax,'jmp '
       jz       .ok
 
       jmp      .notOk
 
.notJ:
       cmp      al,'c'
       jnz      .notC
       mov      eax,dword [esi]
       cmp      eax,'all '
       jnz      .notC
 
;совпадение
.ok:
 
       clc
       ret ;--------exit[1]
 
 
.notC:
.notOk:
       stc      ;нет совпадения
       ret ;--------exit[2]
;-------------
 
 
;------------
GetLabelName:
       test     ecx,ecx
       jnz      .l1
       stc
       ret ;--------exit[1]
 
.l1:
       mov      al, byte [esi]
       inc      esi
 
       cmp      al,' '
       jnz      .find
 
       dec      ecx
       jnz      .l1
       stc
       ret ;--------exit[2]
 
.find:
       dec      ecx
       clc
       ret ;--------exit[3]
;------------
 
;==============================[go to macro]===================================
 
;------------
 
GoToMacro:
 
       call     GetFirstWordFromLn ;ret ;--------exit[x] esi=ptr to first word
       jnc      .ok
       clc
       ret ;--------exit[1]
.ok:
       call     GetLnAdr ;emd.asm
       mov      [.macroReliseLine],eax
 
       mov      edi,esi ;save in edi ptr to str1
       mov      ebx,dword [StartMemory]
       mov      ecx,dword [SizeTextFormatted]
.l1:
       mov      eax,dword [ebx]
       cmp      eax,'macr'
       jz       .fndM
.l11:
       inc      ebx
       cmp      ebx, [.macroReliseLine]
       jnz      .notDownLimit
       clc
       ret ;--------exit[2]
 
.notDownLimit:
       dec      ecx
       jnz      .l1
       clc
       ret ;--------exit[3]
.fndM:
       cmp      ecx,dword CHAR_ON_LINE
       jae      .okSizeText
       ret ;--------exit[4]
.okSizeText:
       mov      eax,dword [ebx+2]
       cmp      eax,'cro '
       jnz      .l11
       mov      eax,ebx
       call     GetLn4Ch ;ret eax=start 1chr ptr on this line
 
       cmp      byte [eax],';'
       jz       .l11
       repeat   7
       inc      eax
       cmp      byte [eax],';'
       jz       .l11
       end      repeat
 
       add      ebx, dword 6
       sub      ecx,dword 6
       mov      dl ,byte CHAR_ON_LINE-6
.l2:
       mov      al,byte [ebx]
       cmp      al,32
       jnz      .firstChOfName
       dec      dl
       jz       .l1
       inc      ebx
       dec      ecx
       jnz      .l2
       clc
       ret ;--------exit[5]
 
.firstChOfName:
       cmp      al,byte [edi]
       jnz      .l1
       mov      esi,ebx
       call     CompareStrings ;edi=ptr to 1str !
       jc       .l1
;it work end
       clc
       call     SetPage ;setpg.asm
       stc
       ret ;--------exit[6]
.macroReliseLine dd 0 ;here save limit ptr for search macro declaration
 
 
;esi=1str ptr,edi=2str ptr (strings end is space (=32))
;set cf,if not match
CompareStrings:
       call     .PushAll
       mov      cl,CHAR_ON_LINE/2
.l1:
       mov      al,[esi]
       mov      dl,[edi]
       cmp      al,dl
       jnz      .False
       inc      esi
       inc      edi
       cmp      al,32
       jz       .ok
       dec      cl
       jnz      .l1
.False:
       call     .PopAll
       stc
       ret ;--------exit[1]
.ok:
       call     .PopAll
       clc
       ret ;--------exit[2]
 
 
.PushAll:
       mov      dword [.saveRegs],eax
       mov      dword [.saveRegs+4],ebx
       mov      dword [.saveRegs+8],edx
       mov      dword [.saveRegs+12],edi
       mov      dword [.saveRegs+16],esi
       mov      dword [.saveRegs+20],ecx
       ret ;--------exit
 
.PopAll:
       mov      eax,dword [.saveRegs]
       mov      ebx,dword [.saveRegs+4]
       mov      edx,dword [.saveRegs+8]
       mov      edi,dword [.saveRegs+12]
       mov      esi,dword [.saveRegs+16]
       mov      ecx,dword [.saveRegs+20]
 
       ret ;--------exit
 
.saveRegs dd 0,0,0,0,0,0,0
 
 
GetFirstWordFromLn:
;вычисляем адрес текущей строки в памяти
       call     GetLnAdr ;emd.asm
;eax =ptr
       mov      ebx,eax
       mov      [.i],eax
       add      eax,CHAR_ON_LINE
       mov      [.iEnd],eax
 
       mov      ebx,dword [.i]
       mov      edx,dword [.iEnd]
 
.l1:
       mov      al,byte [ebx]
       cmp      al,32
       jnz      .itWord
       inc      ebx
       cmp      ebx,edx
       jb       .l1
       mov      dword [.i],0
       stc
       ret ;--------exit[1]
.itWord:
       mov      esi,ebx
       clc
       ret ;--------exit[2]
 
.i dd 0
.iEnd dd 0
 
;in: eax=ptr of char
GetLn4Ch: ;ret eax=start 1chr ptr on this line
       call     .PushAll
       xor      edx,edx
       sub      eax,dword [StartMemory]
       cmp      eax,80
       jb       .ok
.l1:
       sub      eax,80
       add      edx,80
       cmp      eax,80
       jae      .l1
.ok:
       add      edx,dword [StartMemory]
       mov      eax,edx
       call     .PopAll ;eax-not pop
       ret ;--------exit
 
.PushAll:
       mov      dword [.saveRegs],ecx
       mov      dword [.saveRegs+4],ebx
       mov      dword [.saveRegs+8],edx
       mov      dword [.saveRegs+12],edi
       mov      dword [.saveRegs+16],esi
       ret ;--------exit
 
.PopAll:
       mov      ebx,dword [.saveRegs+4]
       mov      edx,dword [.saveRegs+8]
       mov      edi,dword [.saveRegs+12]
       mov      esi,dword [.saveRegs+16]
       mov      ecx,dword [.saveRegs]
       ret ;--------exit
 
.saveRegs dd 0,0,0,0,0,0
 
 
Animation:
       cmp      [VideoMode],3
       jz       .work
       ret ;--------exit
.work:
; call cls
       call     Clock ;inc\clock.asm
 
       xor      eax,eax
       mov      al,[y]
; SetcursorToLine eax;12
       imul     eax,80
       call     SetPos
 
       mov      cx,80-1
.l1:
       push     cx
       mov      esi,.textA
       call     PrintToEmdStr
       pop      cx
       dec      cx
       jnz      .l1
 
       call     Clock ;inc\clock.asm
 
       mov      cl,[.timeHlt]
.l2:
       hlt
       dec      cx
       jnz      .l2
       ret ;--------exit
 
.textA db 0f0h,0
.timeHlt db 5
 
 
;EOF
