;replace.asm
 
 
       MAX_SIZE_FOR_ENTERED_WORD = CHAR_ON_LINE - 13
 
ReplaceWord:
 
       macro    pushXY {
       push     ax
 
;for undercur.asm
       call     GetChAdr
       mov      dword [.ptrCh],eax
       call     GetLnAdr
       mov      dword [.ptrLn],eax
       mov      al,[x]
       mov      ah,[y]
       mov      [.x],al
       mov      [.y],ah
       pop      ax
       }
 
       macro    popXY {
       push     ax
       mov      al,[.x]
       mov      ah,[.y]
 
       mov      [x],al
       mov      [y],ah
       pop      ax
       }
 
 
       macro    Hidecursor {
       xor      ax,ax
       mov      [x],al
       mov      [y],al
;hide cursor
       mov      ah,02h ;- bios servis
       mov      bh,0
       mov      dh,25
       mov      dl,25
       int      10h
       }
 
       pushXY
       mov      [SetcursorBios.fVisible], byte 1
       call     cls
       SetcursorToLine 0
       SetColorUI 7
printToScr 'enter word1: '
       call     EnterWord ;return ax=ptr to entered string
       jnc      .Word2
 
.Wrong:
       SetColorUI 7
       printToScr ' something wrong '
       call     WaitPressAnyKey
       popXY
 
       ret      ;- - - - - - - - - - - - - - exit[1]
 
.Word2:
       SetColorUI 7
 
       macro    saveInputStr ptrMem {
       local    .llllo
       mov      si,ax
       mov      di,word ptrMem
.llllo:
       mov      al,byte [si]
       mov      [di],byte al
       inc      di
       inc      si
       test     al,al
       jnz      .llllo
       }
 
       saveInputStr .str1
       SetcursorToLine 1
       SetColorUI 7
printToScr 'enter word2: '
       call     EnterWord ;return ax=ptr to entered string
       jc       .Wrong
       SetColorUI 7
 
       saveInputStr .str2
 
       SetcursorToLine 2
 
       mov      [SetcursorBios.fVisible], byte 0
       Hidecursor
 
       SetColorUI 7
       mov      ax ,word .str1
       mov      bx ,word .str2
       call     FindAndReplace ;ret ecx =num of reps
 
       push     cx
       shr      ecx,16
       push     cx
 
;print info
       SetcursorToNewLine
 
printToScr 'replaces:'
 
       pop      ax
       shl      eax,16
       pop      ax
 
       call     Bin2AsciiDec ;esi=str
 
       macro    CrrctEsiFrFrstZrPrnt {
       local    .delCharZero, .okDelZ
       mov      ecx,11
.delCharZero:
       dec      ecx
       jz       .okDelZ
       mov      al,[esi]
       inc      esi
       cmp      al,'0'
       jnz      .okDelZ
       jz       .delCharZero
.okDelZ:
       dec      esi
       call     PrintToEmdStr
;put spaces to end
       call     GetPos
       mov      edx,eax
       mov      eax, 0x007200720
       mov      ecx,dword 5 ;10 pos
       call     FillVideoPage
 
       }
       CrrctEsiFrFrstZrPrnt
 
; call PrintToEmdStr
 
       printToScr ' Press any key.. '
       call     WaitPressAnyKey
       popXY
 
       ret      ;- - - - - - - - - - - - - - exit[2]
 
.x db 0
.y db 0
 
.ptrCh dd 0
.ptrLn dd 0
 
 
;buffers for input strings
.str1 rb MAX_SIZE_FOR_ENTERED_WORD
.str2 rb MAX_SIZE_FOR_ENTERED_WORD
 
 
;ecx=size,esi=ptr to string
ChangeColorUIword:
       mov      dword [.numOfOks],0
 
       test     ecx,ecx
       jnz      .work
       SetColorUI 7
       ret
.work:
       mov      dword [.saveEcx],ecx
       mov      dword [.saveEsi],esi
 
       mov      edi,dword [StartMemory]
       mov      edx,dword [SizeTextFormatted]
       mov      bl,byte [esi]
.l1ecx:
       mov      ecx,dword [.saveEcx]
       mov      esi,dword [.saveEsi]
 
.l1:
       mov      al,byte [edi]
       inc      edi
       cmp      al,bl
       jz       .match1
       dec      edx
       jnz      .l1
 
       cmp      dword [.numOfOks],0
       jz       .nothing
       SetColorUI 7
       ret
 
.nothing:
       SetColorUI 8
       ret
 
.match1:
       dec      ecx
       jz       .ok
       inc      esi
       mov      al,byte [edi]
       cmp      al,byte [esi]
       jnz      .l1ecx
       inc      edi
       jmp      .match1
 
.ok:
       inc      dword [.numOfOks]
       cmp      edx,1
       ja       .l1ecx
       SetColorUI 7
       ret
.numOfOks dd 0
.saveEcx dd 0
.saveEsi dd 0
 
 
EnterWord:
       xor      eax,eax
       mov      dword [.ForwardNum],eax
 
       call     GetPos
       mov      [.posToStartCursor],eax
 
       mov      edx,eax
       mov      eax, 0x007200720
       mov      ecx,dword 10
       call     FillVideoPage
 
.NextKey:
       mov      eax, dword [ChangeColorUIword.numOfOks]
       mov      edx,dword [.posToStartCursor]
       mov      cx,word [.iTop]
       shl      ecx,16
       mov      cx,word [.i]
 
       call     PrintNumOfFindes
 
       macro    ChangeColorLive {
       pusha
       mov      esi,dword .EnteredString
       xor      ecx,ecx
       mov      cx,word [.iTop]
       call     ChangeColorUIword
       popa
       }
 
;it is macros for enter char to buffer
       macro    CharEnterToUserString {
       local    .l1,.macroExit, .work
       push     ax
       call     SavePos
 
       mov      bx,word .EnteredString
       mov      di,bx
       add      bx,word [.i]
       add      di,word [.iTop]
;bx=current pos , di = end pos
 
       cmp      bx,di
       jae      .macroExit
 
       cmp      word [.iTop],MAX_SIZE_FOR_ENTERED_WORD-5
       jz       .macroExit
       jb       .work
       pop      ax
       jmp      .errorEnterWord
 
.work:
       inc      word [.iTop]
;inc word [.i] (-jmp .incX)
 
       mov      al,byte [bx]
       pop      dx
       mov      byte [bx],dl ;enter new char
 
       inc      bx
       inc      di
.l1:
       mov      dl,byte [bx]
       mov      byte [bx],al
       inc      bx
 
       mov      al,byte [bx]
       mov      byte [bx],dl
       inc      bx
 
       cmp      bx,di
       jb       .l1
 
       mov      ax,word [.i]
       push     ax
       mov      ax,word [.iTop]
       push     ax
 
       call     .PutNewStringCall
       call     RestorePos
       call     SetcursorBios
       mov      esi,dword [VideoBufMemory]
       call     DrawPage
 
       pop      ax
       mov      word [.iTop],ax
       pop      ax
       mov      word [.i],ax
       jmp      .incx
 
.macroExit:
       pop      ax
       }
 
       call     .GetKey
 
       mov      ecx,dword MAX_SIZE_FOR_ENTERED_WORD-5
 
;-----cursor keys-------
       cmp      ah,4Bh
       je       .decx
 
       cmp      ah,4Dh
       je       .incx
 
       cmp      ah,48h
       je       .decy
 
       cmp      ah,50h
       je       .incy
;------
 
       cmp      ah,83 ;del
       je       .del
 
       cmp      ah,1;esc
       je       .close
 
       cmp      ah,14 ;bsp
       jz       .backspace
 
       cmp      ah,28 ;enter
       jz       .KeyEnter
 
       mov      bx,ax
       mov      eax, dword [.ForwardNum]
       cmp      eax,dword MAX_SIZE_FOR_ENTERED_WORD-5
       jz       .NextKey
       jb       .ForwardOk
       mov      eax,dword MAX_SIZE_FOR_ENTERED_WORD-5
       mov      dword [.ForwardNum],eax
       jmp      .NextKey
 
 
.ForwardOk:
 
       mov      ax,bx
 
       cmp      al,32
       jb       .NextKey
 
       mov      byte [.EskFlagForFirstPress],0
 
       CharEnterToUserString
 
       push     ax
       call     .SaveChar
       ChangeColorLive
       pop      ax
       call     PrintToEmd_ASCII_Char
       inc      dword [.ForwardNum]
       jmp      .NextKey
.ForwardNum dd 0
 
 
;-----cursor keys-------
 
.decx:
       cmp      dword [.ForwardNum],0
       jz       .delERTERFD0
       dec      dword [.ForwardNum]
.delERTERFD0:
 
       call     .SaveCharDecX
       jc       .decXl1
       call     DecX_replace
.decXl1:
       call     SetcursorBios
       mov      esi,dword [VideoBufMemory]
       call     DrawPage
       jmp      .NextKey ;decx - exit
 
.incx:
       mov      eax, dword [.ForwardNum]
       cmp      eax,dword MAX_SIZE_FOR_ENTERED_WORD-5
       jz       .NextKey
       inc      dword [.ForwardNum]
 
       call     .SaveCharIncX
       jc       .incXl1
       call     IncX_replace
.incXl1:
       call     SetcursorBios
       mov      esi,dword [VideoBufMemory]
       call     DrawPage
 
       jmp      .NextKey
 
 
;----\
.ReplaceFirstLast:
       mov      al, byte [.invertLastFirstCursor]
       shl      al,7
       test     al,al
       jz       .lastCur
       call     FromCurorFirst ; replace text in buffer - esi = ptr
       inc      byte [.invertLastFirstCursor]
       ret
.lastCur:
       call     FromCurorLast ; replace text in buffer - esi = ptr
       inc      byte [.invertLastFirstCursor]
       ret
.invertLastFirstCursor db 0
;----/
 
       macro    CLS_endOfLine {
       call     GetPos
       mov      edx,eax
       mov      eax, 0x007200720
       mov      ecx,dword 50
       call     FillVideoPage
       }
 
.incy:
;erase buffer
       mov      edi,dword .EnteredString
       mov      ecx,dword MAX_SIZE_FOR_ENTERED_WORD ;size buffer
       shr      ecx,2
       xor      eax,eax
       call     FillMem
 
 
       mov      esi,dword .EnteredString
       mov      ecx,dword MAX_SIZE_FOR_ENTERED_WORD ;size buffer
       call     .ReplaceFirstLast
 
.PutNewString:
       call     .PutNewStringCall
 
       mov      eax,dword [.posToStartCursor]
       call     GetPosX
       mov      ebx,eax
       call     GetPos
       call     GetPosX
 
       cmp      eax,ebx
       jb       .errorEnterWord
 
       sub      eax,ebx
       mov      dword [.ForwardNum],eax
       jmp      .NextKey
 
.PutNewStringCall:
       mov      byte [.EskFlagForFirstPress],0
       mov      eax,dword [.posToStartCursor]
       call     SetPos
 
       call     .SaveCharReset
 
       mov      esi,dword .EnteredString
.correctSaveChar:
       mov      al,[esi]
       call     .SaveChar
       jc       .errorEnterWord
       inc      esi
       mov      al,[esi]
       test     al,al
       jnz      .correctSaveChar
 
       ChangeColorLive
 
       mov      esi,.EnteredString
       call     PrintToEmdStr
 
       CLS_endOfLine
       ret
 
 
.decy:
       xor      eax,eax
       call     HistoryReplaces
       mov      esi,eax
       mov      edi,dword .EnteredString
       mov      ecx,MAX_SIZE_FOR_ENTERED_WORD-1
.l13:
       mov      al,[esi]
       mov      [edi],al
       inc      esi
       inc      edi
       dec      ecx
       jz       .ok3
       test     al,al
       jnz      .l13
       jmp      .PutNewString
 
.ok3:
       mov      byte [edi],0
       jmp      .PutNewString
 
 
;-----------------------
.del:
 
       cmp      dword [.ForwardNum],0
       jz       .delERTERFD
       dec      dword [.ForwardNum]
.delERTERFD:
 
       call     SavePos
 
       mov      bx,word .EnteredString
       mov      di,bx
       add      bx,word [.i]
       add      di,word [.iTop]
;bx=current pos , di = end pos
 
       cmp      bx,di
       ja       .errorEnterWord
       jz       .NextKey ;del key exit
 
.delCharUser:
       mov      al,byte [bx+1]
       mov      byte [bx],al
       inc      bx
       cmp      bx,di
       jnz      .delCharUser
 
.delOk: ;exit del all
       mov      al,32
       mov      byte [bx],al
 
       cmp      word [.iTop],0
       jz       .NextKey
 
       dec      word [.iTop]
 
       mov      ax,word [.i]
       push     ax
       mov      ax,word [.iTop]
       push     ax
 
       call     .PutNewStringCall
       call     RestorePos
       call     SetcursorBios
       mov      esi,dword [VideoBufMemory]
       call     DrawPage
 
       pop      ax
       mov      word [.iTop],ax
       pop      ax
       mov      word [.i],ax
       jmp      .NextKey ;del key exit
 
 
.backspace:
 
       call     SavePos
 
       mov      bx,word .EnteredString
       mov      di,bx
       cmp      word [.i],0
       jz       .NextKey
 
       add      bx,word [.i]
       add      di,word [.iTop]
;bx=current pos , di = end pos
 
       cmp      bx,di
       ja       .errorEnterWord
 
       dec      bx
.shiftChBackspace:
       mov      al,byte [bx+1]
       mov      byte [bx],al
       inc      bx
       cmp      bx,di
       jnz      .shiftChBackspace
 
       mov      al,0;32 ;5%
       mov      byte [bx],al
 
       cmp      word [.iTop],0
       jz       .NextKey
 
       dec      word [.iTop]
 
       mov      ax,word [.i]
       push     ax
       mov      ax,word [.iTop]
       push     ax
 
       call     .PutNewStringCall
       call     RestorePos
       call     SetcursorBios
       mov      esi,dword [VideoBufMemory]
       call     DrawPage
 
       pop      ax
       mov      word [.iTop],ax
       pop      ax
       mov      word [.i],ax
       jmp      .decx ;bcs key exit
.EskFlagForFirstPress db 0
.close:
       cmp      byte [.EskFlagForFirstPress],0
       jnz      .errorEnterWord
       mov      eax,dword [.posToStartCursor]
       call     SetPos
       call     SetcursorBios
       CLS_endOfLine
       mov      esi,dword [VideoBufMemory]
       call     DrawPage
 
       mov      bx,word .EnteredString
       mov      byte [bx],0
       mov      word [.i],0
       mov      word [.iTop],0
 
       inc      byte [.EskFlagForFirstPress]
       xor      eax,eax
       mov      dword [.ForwardNum],eax
 
       jmp      .NextKey
 
.errorEnterWord:
       stc
       ret      ;-----------------------exit1
 
.KeyEnter:
       xor      ax,ax
       call     .SaveChar
       jc       .errorEnterWord
       mov      bx,word .EnteredString
       mov      al,byte [bx]
       test     al,al
       jc       .errorEnterWord
       mov      eax,dword .EnteredString
       call     HistoryReplaces
 
;-del counter\
       mov      edx,dword [.posToStartCursor]
       add      edx,CHAR_ON_LINE
       mov      eax, 0x007200720 ;2 spaces
       mov      ecx,dword 5 ;10 pos
       call     FillVideoPage
;-del counter/
 
       mov      eax,dword .EnteredString
       clc
       ret      ;-----------------------exit2
 
.SaveCharIncX:
       push     ax
       mov      ax,word [.i]
       cmp      ax,word [.iTop]
       jz       .SaveCharI
       inc      word [.i]
       pop      ax
       clc
       ret
.SaveCharI:
       pop      ax
       stc
       ret
 
 
.SaveCharDecX: ;delete char in buf
       cmp      word [.i],0
       jnz      .SaveCharD
       stc
       ret
.SaveCharD:
       dec      word [.i]
       clc
       ret
 
.SaveCharReset:
       xor      eax,eax
       mov      dword [.i], eax
       ret
 
 
.SaveChar:
       test     al,al
       jnz      .work1
       mov      ax,word [.iTop]
       mov      [.i],word ax
       xor      ax,ax
.work1:
 
       mov      bx,word .EnteredString
       add      bx,word [.i]
 
       macro    check_if_i_itop_eqa {
       local    .ok
       push     ax
       mov      ax, word [.i]
       cmp      ax,word [.iTop]
       jz       .ok
       dec      word [.iTop]
.ok:
       pop      ax
       inc      word [.i]
       inc      word [.iTop]
       }
 
       check_if_i_itop_eqa
 
       mov      [bx],byte al
 
       test     al,al
       jnz      .work
 
       xor      eax,eax
       mov      dword [.i], eax
 
.work:
 
       mov      ax,word [.iTop] ;%
       cmp      ax,MAX_SIZE_FOR_ENTERED_WORD
       jb       .okExit
 
       xor      eax,eax
       mov      dword [.i], eax
;IT ERROR___________________________!
       stc
       ret
.okExit:
       mov      ax,word .EnteredString
       clc
       ret
 
.posToStartCursor dd 0
 
.i dw 0
.iTop dw 0
.EnteredString rb MAX_SIZE_FOR_ENTERED_WORD
       rd       10
 
 
;-----------
.GetKey:
mov word ax,[fs:0+041ah]
mov word bx,[fs:0+041ch]
.wait_kbd:
       call     Clock ;inc\clock.asm
       hlt
cmp word bx,[fs:0+041ch]
       jz       .wait_kbd
mov word ax,[fs:0+bx+0400h]
mov word bx,[fs:0+041ch]
mov word [fs:0+041ah],bx
       ret
;-----------
 
;-----------
DecX_replace:
       call     GetPos
       test     eax,eax
       jz       .ok
       dec      eax
       call     SetPos
.ok:
       ret
 
IncX_replace:
       call     GetPos
       cmp      eax,dword CHAR_ON_LINE*25
       jz       .ok
       inc      eax
       call     SetPos
.ok:
       ret
 
 
;EOF
