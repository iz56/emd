;history.asm
 
 
       DIP_HISTORY = 8
 
HistoryReplaces: ;main entry
 
       test     eax,eax
       jz       .getStrPtr
 
       mov      ecx,dword DIP_HISTORY
       mov      ebx,dword [.i]
       cmp      ebx,ecx
       jae      .okFull
 
       inc      dword [.i]
.okFull:
;in eax=ptr ASCIIZ string
       call     RepHistorySaveStr
       ret      ;------exit[1]
 
.getStrPtr:
       mov      eax,dword [.i2]
       mov      ebx,dword [.i]
       test     ebx,ebx
       jnz      .noCleanHisrtory
       mov      eax,dword .cleanStr
       ret      ;----exit[2]
 
.noCleanHisrtory:
       cmp      eax,ebx
       jz       .firstGet
       test     eax,eax ;it last
       jz       .firstGet
       dec      eax
       mov      dword [.i2],eax
       mov      ebx,eax
       jmp      .doit
 
.firstGet:
       dec      ebx
       mov      dword [.i2],ebx
 
.doit:
       mov      eax,dword .rtestStr
;in eax=ptr to buffer for ASCIIZ string
       call     RepHistoryGetStr
       mov      eax,dword .rtestStr
       ret      ;----exit[3]
 
.cleanStr db '-/-',0
virtual at TmpData+56
.rtestStr rb MAX_SIZE_FOR_ENTERED_WORD
end virtual
 
db 0
 
.ptrToMemForBuf dd TempBuf
 
.i dd 0
.i2 dd 0
 
 
;in eax=ptr ASCIIZ string
RepHistorySaveStr: ;history.asm
       call     .PushAll
 
       mov      eax,dword [.numstr]
       call     .mulEax ;destroi edx
 
       mov      edi,[.ptrToMemForBuf]
       add      edi,eax
       mov      esi,dword [.saveRegs]
       mov      ecx,MAX_SIZE_FOR_ENTERED_WORD-1
 
.l1:
       mov      al,byte [esi]
       mov      byte [edi],al
       test     al,al
       jz       .l1_ok
 
       inc      esi
       inc      edi
       dec      ecx
       jnz      .l1
       mov      byte [edi],0
.l1_ok:
 
       mov      eax,dword DIP_HISTORY ;ERRORC?
       mov      ebx,dword .numstr
       call     incVarCheck
 
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
 
;------\
.mulEax:
       mov      cx,word MAX_SIZE_FOR_ENTERED_WORD
       xor      edx,edx
.mulE:
       add      edx,eax
       dec      cx
       jnz      .mulE
       mov      eax,edx
       ret
;------/
 
 
virtual at TmpData+28
.saveRegs dd 0,0,0,0,0,0,0,0
end virtual
 
.ptrToMemForBuf dd TempBuf
.numstr dd 0
 
 
;in eax=ptr to buffer for ASCIIZ string
;ebx = num of saved string
RepHistoryGetStr: ;history.asm
       call     .PushAll
 
       mov      eax,ebx
       call     RepHistorySaveStr.mulEax
 
       mov      esi,[.ptrToMemForBuf]
       add      esi,eax
       mov      edi,dword [.saveRegs]
       mov      ecx,MAX_SIZE_FOR_ENTERED_WORD-1
 
.l1:
       mov      al,byte [esi]
       mov      byte [edi],al
       test     al,al
       jz       .l1_ok
       inc      esi
       inc      edi
       dec      ecx
       jnz      .l1
       mov      byte [edi-1],0
 
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
 
virtual at TmpData
.saveRegs dd 0,0,0,0,0,0,0
end virtual
 
.ptrToMemForBuf dd TempBuf
 
 
incVarCheck:
;ebx=ptr to variable
;eax=limit
       mov      dword [.saveEdx],edx
       mov      edx,dword [ebx]
       inc      edx
       cmp      eax,edx
       jae      .ok ;may be ja only?
       xor      edx,edx
.ok:
       mov      dword [ebx],edx
       mov      edx,dword [.saveEdx]
       ret
 
.saveEdx dd 0
 
TempBuf rb DIP_HISTORY*MAX_SIZE_FOR_ENTERED_WORD
rb MAX_SIZE_FOR_ENTERED_WORD ;ower here
 
 
;EOF
