;history.asm
 
 
       DIP_HISTORY=8
 
HistoryReplaces: ;main entry
 
       test     eax,eax
       jz       .getStrPtr
;in ax=ptr ASCIIZ string
       call     RepHistorySaveStr
 
       mov      ecx,dword DIP_HISTORY
       mov      ebx,dword [.i]
       cmp      ebx,ecx
       jz       .okFull
 
       inc      dword [.i]
 
.okFull:
       ret ;------exit[1]
 
.getStrPtr:
       mov      eax,dword [.i2]
       mov      ebx,dword [.i]
       test     ebx,ebx
       jnz       .noCleanHisrtory
       mov      eax,dword .cleanStr
       ret ;----exit[2]
 
     .noCleanHisrtory:
       cmp      eax,ebx
       jz       .firstGet
       test     eax,eax ;it last
       jz       .firstGet
       mov      ebx,eax
.firstGet:
       mov      dword [.i2],ebx
       dec      dword [.i2]
 
       mov      eax,dword .rtestStr
;in eax=ptr to buffer for ASCIIZ string
       call     RepHistoryGetStr
       mov      eax,dword .rtestStr
 
       ret  ;----exit[3]
 
.cleanStr db '-/-',0
 
.rtestStr rb MAX_SIZE_FOR_ENTERED_WORD
db 0
 
.ptrToMemForBuf dd TempBuf
 
.i dd 0
.i2 dd 0
 
 
;in eax=ptr ASCIIZ string
RepHistorySaveStr: ;history.asm
       call     .PushAll
 
       mov      ecx,dword DIP_HISTORY
       mov      ebx,dword numstr
       call     incVarCheck
 
       mov      eax,dword [numstr]
       imulEax80
 
       mov      edi,[.ptrToMemForBuf]
       add      edi,eax
       mov      esi,dword [.saveRegs]
       mov      ecx,MAX_SIZE_FOR_ENTERED_WORD-1
 
.l1:
       mov      al,byte [esi]
       mov      byte [edi],al
test al,al
jz .l1_ok
 
       inc      esi
       inc      edi
       dec      ecx
       jnz      .l1
       mov      byte [edi],0
.l1_ok:
 
       call     .PopAll
       ret
 
.PushAll:
       mov      dword [.saveRegs],eax
       mov      dword [.saveRegs+4],ebx
       mov      dword [.saveRegs+8],edx
       mov      dword [.saveRegs+12],edi
       mov      dword [.saveRegs+16],esi
       mov      dword [.saveRegs+20],ecx
       ret
 
.PopAll:
       mov      eax,dword [.saveRegs]
       mov      ebx,dword [.saveRegs+4]
       mov      edx,dword [.saveRegs+8]
       mov      edi,dword [.saveRegs+12]
       mov      esi,dword [.saveRegs+16]
       mov      ecx,dword [.saveRegs+20]
 
       ret
 
.saveRegs dd 0,0,0,0,0,0,0
.ptrToMemForBuf dd TempBuf
 
 
;in eax=ptr to buffer for ASCIIZ string
;ebx = num of saved string
RepHistoryGetStr: ;history.asm
 
       call     .PushAll
 
       mov      eax,ebx
       imulEax80
 
       mov      esi,[.ptrToMemForBuf]
       add      esi,eax
       mov      edi,dword [.saveRegs]
       mov      ecx,MAX_SIZE_FOR_ENTERED_WORD-1
 
.l1:
       mov      al,byte [esi]
       mov      byte [edi],al
test al,al
jz .l1_ok
       inc      esi
       inc      edi
       dec      ecx
       jnz      .l1
 
.l1_ok:
 
       call     .PopAll
       ret
 
.PushAll:
       mov      dword [.saveRegs],eax
       mov      dword [.saveRegs+4],ebx
       mov      dword [.saveRegs+8],edx
       mov      dword [.saveRegs+12],edi
       mov      dword [.saveRegs+16],esi
       mov      dword [.saveRegs+20],ecx
       ret
 
.PopAll:
       mov      eax,dword [.saveRegs]
       mov      ebx,dword [.saveRegs+4]
       mov      edx,dword [.saveRegs+8]
       mov      edi,dword [.saveRegs+12]
       mov      esi,dword [.saveRegs+16]
       mov      ecx,dword [.saveRegs+20]
 
       ret
 
.saveRegs dd 0,0,0,0,0,0,0
.ptrToMemForBuf dd TempBuf
 
 
 
incVarCheck:
;ebx=ptr to variable
;eax=limit
       mov      [.saveEdx],edx
       mov      edx,[ebx]
       inc      edx
       cmp      eax,edx
       jnz      .ok
       xor      edx,edx
.ok:
       mov      [ebx],edx
       mov      edx,[.saveEdx]
       ret
 
.saveEdx dd 0
 
 
decVarCheck:
;ebx=ptr to variable
;eax=limit
       mov      [.saveEdx],edx
       mov      edx,[ebx]
       test     edx,edx
       jnz      .nzero
       inc      eax
       mov      edx,eax
.nzero:
       dec      edx
.ok:
 
       mov      [ebx],edx
       mov      edx,[.saveEdx]
       ret
.saveEdx dd 0
 
 
TempBuf rb DIP_HISTORY*MAX_SIZE_FOR_ENTERED_WORD
 rb 2*MAX_SIZE_FOR_ENTERED_WORD
 
numstr dd 0
 
 
;EOF