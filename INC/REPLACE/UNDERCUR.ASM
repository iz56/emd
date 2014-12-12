;undercur.asm
       
       
       macro    getCharPtrMain {
       mov      eax,dword [ReplaceWord.ptrCh] ;inc/replace.asm
       }
       
       macro    getLinePtrMain {
       mov      eax,dword [ReplaceWord.ptrLn] ;inc/replace.asm
       }
       
       
; esi,ptrToString
; ecx,dword size_buffer
; replace text in buffer - esi = ptr
       
FromCurorLast:
       call     .PushAll
       
       getLinePtrMain
; eax=ptr to current pos in main text
       mov      edx,eax
       add      edx,dword CHAR_ON_LINE
       
       getCharPtrMain
       mov      edi,eax
       mov      esi,dword [.saveRegs+16]
       mov      ecx,dword [.saveRegs+20]
       
.nextCh:
       mov      al,byte [edi]
       cmp      al,32 ;32=space (ASCII)
       jz       .ok
       mov      [esi],byte al
       inc      esi
       inc      edi
       cmp      edi,edx
       jz       .ok
       
       dec      ecx
       jnz      .nextCh
       mov      esi,dword [.saveRegs+16]
       mov      [esi],byte '@'
       inc      esi
       mov      [esi],byte 0
       
.ok:
       mov      [esi],byte 0
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
       
.saveRegs dd 0,0,0,0,0,0,0,0
       
;----------------
       
       
; esi,ptrToString
; ecx,dword size_buffer
; replace text in buffer - esi = ptr
       
FromCurorFirst:
       call     .PushAll
       
       getLinePtrMain
       mov      edx,eax
       
       getCharPtrMain
       
;if x=0 - if current char first on line ----\
       cmp      eax,edx ;check
       jnz      .work
       call     .PopAll
       mov      edi,esi
       xor      esi,esi
       mov      si,[PtrNameFileText] ;samething text may be here
       mov      cl,11
.l11:
       mov      al,[esi]
       mov      [edi],al
       inc      esi
       inc      edi
       cmp      byte [esi],0
       jz       .ok_l11
       dec      cl
       jnz      .l11
       mov      [edi],byte 0
.ok_l11:
       
       call     .PopAll
       ret      ;----------------------exit[1]
       
.work:
;if x=0 - if current char first on line ----/
       
       mov      edi,eax
       mov      esi,dword [.saveRegs+16]
       mov      ecx,dword [.saveRegs+20]
       
       mov      ebx, edi
       
.nextCh:
       mov      al,byte [edi-1]
       cmp      al,32 ;32=space (ASCII)
       jz       .nextCh2
       dec      edi
       cmp      edi,edx
       jnz      .nextCh
       
.nextCh2:
       mov      al,byte [edi]
       mov      [esi],byte al
       
;+
       cmp      al,32 ;32=space (ASCII)
       jz       .ok
;+
       inc      esi
       inc      edi
       cmp      edi,ebx
       jz       .ok
       
       dec      ecx
       jnz      .nextCh2
       
.ok:
       
       mov      [esi],byte 0
       call     .PopAll
       cmp      [esi],byte 0
       jnz      .okStrSizeNotZero
       mov      [esi],byte '@'
       mov      [esi+1],byte 0
       
       
.okStrSizeNotZero:
       
       ret      ;----------------------exit[2]
       
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
       
.saveRegs dd 0,0,0,0,0,0,0,0
       
       
;EOF
       