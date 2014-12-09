;fnd.asm
 
FndWord: ;esi=ptr to ASCIIZ string
;edi=ptr to area for scan,ecx=size,ret edi=ptr to 1st ch
       call     .PushAll
       test     ecx,ecx
       jz       .False
       mov      [.saveMainStrPtr],esi
.l1_esi:
       mov      esi,[.saveMainStrPtr]
       mov      dl,[esi]
.l1:
       mov      al,[edi]
       inc      edi
       dec      ecx
       jz       .False
       cmp      al,dl
       jnz      .l1
;save pos
       dec      edi
       mov      [.PossiblePtrToFndString],edi
 
.nextCompare:
       mov      al,[edi]
       cmp      al,[esi]
       jnz      .l1_esi
       inc      esi
       inc      edi
       dec      ecx
       jz       .False
       cmp      byte [esi],0
       jz       .ok
       jmp      .nextCompare
 
.False:
       call     .PopAll
       stc
       ret
.ok:
       call     .PopAll
       mov      edi,[.PossiblePtrToFndString]
       clc
       ret
 
.saveMainStrPtr dd 0
 
.PossiblePtrToFndString dd 0
 
 
.PushAll:
       mov      dword [.saveRegs],eax
       mov      dword [.saveRegs+4],ebx
       mov      dword [.saveRegs+8],edx
; mov dword [.saveRegs+12],edi
       mov      dword [.saveRegs+16],esi
; mov dword [.saveRegs+20],ecx
       ret
 
.PopAll:
       mov      eax,dword [.saveRegs]
       mov      ebx,dword [.saveRegs+4]
       mov      edx,dword [.saveRegs+8]
; mov edi,dword [.saveRegs+12]
       mov      esi,dword [.saveRegs+16]
; mov ecx,dword [.saveRegs+20]
 
       ret
 
.saveRegs dd 0,0,0,0,0,0,0
 
 
;EOF
