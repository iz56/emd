;gotod.asm
 
 
       macro    err_ret { stc
       ret      }
       macro    ok_ret { clc
       ret      }
 
;-------\
GoToData: ;search for dd,db,dw,label:
       call     IfSkobki
       jnc      .work
       call     If2stWord
       jnc      .work
       clc
       ret      ;-----------------exit[1]
.work:
       mov      dword [.totalFnds],0
 
       mov      esi,dword buf
       call     .DisplayUserInfo
 
       mov      esi,dword buf
       mov      edi,[StartMemory]
       mov      ecx,[SizeTextFormatted]
.nextFnd:
       call     FndWord ;esi=ptr to ASCIIZ string,ret edi=ptr to line
       jc       .debugTemp
       mov      ebx,edi
       inc      edi
       test     ecx,ecx
       jz       .endFnd
       dec      ecx
       jz       .endFnd
       inc      dword [.totalFnds]
       call     .printRes
       call     TestForData ;ebx=ptr
       jc       .nextFnd
       call     SetPage
       stc
       ret      ;-----------------exit[2]
 
.endFnd:
       mov      esi,dword .mgEndFnd
       call     .DisplayUserInfo
 
.debugTemp:
       mov      esi,dword .mgNo
       call     .DisplayUserInfo
       clc
       ret      ;-----------------exit[3]
 
.mgOk db 'find',0
.mgNo db 'no find',0
.mgEndFnd db 'fnd completed,',0
.mgProgr db '*',0
 
.totalFnds dd 0
;-------/
 
 
;----\
.printRes:
 
       mov      dword [.saveRegsQ],edi
       mov      dword [.saveRegsQ+4],esi
       mov      dword [.saveRegsQ+8],ecx
       mov      dword [.saveRegsQ+12],ebx
 
       mov      esi,dword .mgProgr
       call     .DisplayUserInfo
       mov      edi,dword [.saveRegsQ]
       mov      esi,dword [.saveRegsQ+4]
       mov      ecx,dword [.saveRegsQ+8]
       mov      ebx,dword [.saveRegsQ+12]
 
       ret      ;-----------------exit[.printRes]
 
.saveRegsQ dd 0,0,0,0
;----/
 
;---------------\
.DisplayUserInfo:
       pusha
       call     PrintToEmdStr
       call     Clock ;inc\clock.asm
       xor      ecx,ecx
       mov      cl,2 ;delay
.l2:
; hlt
       dec      cx
       jnz      .l2
       popa
       ret      ;-----------------exit
;---------------/
 
;--------\
If2stWord:
       clc
       call     GetLnAdr ;emd.asm
 
       mov      ebx,eax
       mov      cx, word CHAR_ON_LINE
 
       mov      dl,','
       call     ParseLn
       jc       .err
 
       dec      cx
       jz       .err
 
       inc      ebx ;
       call     DWBskip ;ebx=ptr to first ch or space,cx=limit
 
       mov      esi,ebx ;now edi=ptr to last ch
 
       mov      dl,32
       call     ParseLn
       jc       .err
 
       dec      cx
       jz       .err
 
       mov      edi,ebx ;now edi=ptr to last ch
       mov      ebx,dword buf
       mov      cx, word CHAR_ON_LINE/2
       xor      dx,dx
 
.tpret:
       cmp      esi,edi
       jz       .okMove
       inc      dx
       mov      al,[esi]
       mov      [ebx],al
       inc      esi
       inc      ebx
       dec      cx
       jnz      .tpret
       err_ret  ;-----exit[1]
.okMove:
       test     dx,dx
       jz       .err
 
       mov      [ebx],byte 0
;now buf store str (ASCIIZ)
       ok_ret   ;---------exit[2]
.err:
       err_ret  ;-----exit[3]
;--------/
 
 
;------\
DWBskip: ;ebx=ptr to first ch or space,cx=limit
 
.l1:
       mov      eax,dword [ebx]
       mov      edx,6
       cmp      eax,'dwor'
       jz       .ok
       mov      edx,5
       cmp      eax,'word'
       jz       .ok
       cmp      eax,'byte'
       jz       .ok
 
       mov      al,byte [ebx]
       cmp      al,32
       jnz      .No
       inc      ebx
       dec      cx
       jnz      .l1
.No:
       err_ret  ;-----exit[1]
.ok:
       mov      al,byte [ebx]
       cmp      al,32
       jz       .No
       cmp      cx,dx
       jb       .No ;if size no good
       add      ebx,edx ;set to first char of name data
       ok_ret   ;----------exit[2]
;------/
 
 
;-------\
IfSkobki:
       clc
       call     GetLnAdr ;emd.asm
 
       mov      ebx,eax
       mov      cx, word CHAR_ON_LINE-8
 
       mov      dl,'['
       call     ParseLn
       jnc      .ok1
       err_ret  ;-----exit[1]
.ok1:
       dec      cx
       jz       .NotOk
 
       inc      ebx
       mov      esi,ebx ;now esi=ptr to 1st ch
 
       mov      dl,']'
       call     ParseLn
       jnc      .ok2
       err_ret  ;-----exit[2]
.ok2:
 
; dec ebx
       mov      edi,ebx ;now edi=ptr to last ch
       mov      ebx,dword buf
       mov      cx, word CHAR_ON_LINE/2
       xor      dx,dx
 
.tpret:
       cmp      esi,edi
       jz       .okMove
       inc      dx
       mov      al,[esi]
       mov      [ebx],al
       inc      esi
       inc      ebx
       dec      cx
       jnz      .tpret
       err_ret  ;-----exit[3]
.okMove:
       test     dx,dx
       jnz      .okSize
       err_ret  ;-----exit[4]
.okSize:
       mov      [ebx],byte 0
;now buf store str (ASCIIZ)
       ok_ret   ;---------exit[5]
.NotOk:
       err_ret  ;-----exit[6]
;-------/
 
 
;------\
;ebx=ptr,dl=ch,cx=max range
ParseLn:
       mov      al,byte [ebx]
       cmp      al,dl
       jz       .ok
       inc      ebx
       dec      cx
       jnz      ParseLn
       err_ret  ;-----exit[1]
.ok:
       ok_ret   ;---------exit[2]
;------/
 
 
;-----------\
;eax=0 - mov word,and set end zero
MoveStrToBuf: ;ebx=ptr to str ,eax=fun
       test     eax,eax
       jz       .work
       ret      ;-----------------exit[1]
.work:
       call     .PushAll
       mov      edi,dword buf
       mov      ecx,dword CHAR_ON_LINE
.l1:
       mov      al,byte [ebx]
       call     TestAlToEndOfWord
       jc       .endWord
       mov      al,byte [ebx]
       mov      ah,0
       mov      word [edi],ax
       inc      ebx
       inc      edi
       dec      ecx
       jnz      .l1
.endWord:
       call     .PopAll
       ret      ;-----------------exit[2]
 
.PushAll:
       mov      dword [.saveRegs],eax
       mov      dword [.saveRegs+4],ebx
       mov      dword [.saveRegs+8],edx
       mov      dword [.saveRegs+12],edi
       mov      dword [.saveRegs+16],esi
       mov      dword [.saveRegs+20],ecx
       ret      ;-----------------exit
 
.PopAll:
       mov      eax,dword [.saveRegs]
       mov      ebx,dword [.saveRegs+4]
       mov      edx,dword [.saveRegs+8]
       mov      edi,dword [.saveRegs+12]
       mov      esi,dword [.saveRegs+16]
       mov      ecx,dword [.saveRegs+20]
       ret      ;-----------------exit
 
.saveRegs dd 0,0,0,0,0,0,0
;-----------/
 
 
;----------------\
TestAlToEndOfWord:
       mov      [.saveEsi],esi
       mov      esi,dword .tableOfChs
.l1:
       cmp      al,byte [esi]
       jz       .ItEndCh
       inc      esi
       cmp      byte [esi], 0
       jnz      .l1
 
       mov      esi,[.saveEsi]
       clc
       ret      ;-----------------exit[1]
 
.ItEndCh:
       mov      esi,[.saveEsi]
       stc
       ret      ;-----------------exit[2]
.saveEsi dd 0
.tableOfChs db ' :;,.[]{}()*/!@#$%&=+-?|',0
;----------------/
;;;
TestForData: ;ebx=ptr,esi=orig str ptr
       call     .PushAll
 
       mov      edx,ebx ;save ebx
       sub      ebx,[StartMemory]
       call     EbxCut80
       add      ebx,[StartMemory]
 
       mov      ecx,80
.l1y:
       mov      al,[ebx]
       cmp      al,32
       jnz      .no32
       inc      ebx
       dec      ecx
       jnz      .l1y
;string empty
       inc      [errors]
       jmp      .noOk
 
.no32:
       cmp      al,';'
       jz       .noOk ;it string is commented
 
       cmp      edx,ebx
       jnz      .noOk
 
       mov      al,[ebx-1]
       cmp      al,32
       jz       .Left32
 
       sub      ebx,[StartMemory]
       mov      edx,ebx ;save ebx
       call     EbxCut80
 
       cmp      edx,ebx
       jnz      .noOk
 
       add      ebx,[StartMemory]
 
.Left32:
 
       mov      ecx,80/2
.l1:
       mov      al,[esi]
       inc      esi
       inc      ebx
       test     al,al
       jnz      .l1
       dec      ebx
       mov      al,[ebx]
cmp al,':'
       jz       .okL
       cmp      al,32
       jz       .okEndWord
       jmp      .noOk
.okL:
       mov      ax,word [ebx]
cmp ax,': '
       jz       .ok
cmp ax,':;'
       jz       .ok
       jmp      .noOk
.okEndWord:
 
;--\
       mov      eax,dword [ebx]
       mov      ebx,dword .tableWordsData
       mov      cx,6
.nextCmp:
       cmp      eax,dword [ebx]
       jz       .ok
       add      ebx,4
       dec      cx
       jnz      .nextCmp
;--/
 
.noOk:
       call     .PopAll
       stc
       ret      ;-----------------exit[1]
 
.ok:
       call     .PopAll
       clc
       ret      ;-----------------exit[2]
 
.tableWordsData: ;here fasm lang specifies
db ' rb '
db ' rw '
db ' rd '
db ' db '
db ' dw '
db ' dd '
 
.PushAll:
       mov      dword [.saveRegs],eax
       mov      dword [.saveRegs+4],ebx
       mov      dword [.saveRegs+8],edx
       mov      dword [.saveRegs+12],edi
       mov      dword [.saveRegs+16],esi
       mov      dword [.saveRegs+20],ecx
       ret      ;-----------------exit
 
.PopAll:
       mov      eax,dword [.saveRegs]
       mov      ebx,dword [.saveRegs+4]
       mov      edx,dword [.saveRegs+8]
       mov      edi,dword [.saveRegs+12]
       mov      esi,dword [.saveRegs+16]
       mov      ecx,dword [.saveRegs+20]
 
       ret      ;-----------------exit
 
.saveRegs dd 0,0,0,0,0,0,0
;----------/
 
 
;-------\
EbxCut80:
       xor      eax,eax
.l1:
       cmp      ebx,80
       jb       .zEbx
       sub      ebx,80
       add      eax,80
       jmp      .l1
.zEbx:
       mov      ebx,eax
       ret      ;-----------------exit
;-------/
 
 
;EOF
