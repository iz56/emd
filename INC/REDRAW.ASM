;redraw.asm
       
       
Redraw_1st_old:
       
       cmp      byte [FlagTextSelect],0
       jz       .FastRedraw
       
;;;;;;;;;call StartProf
;old variant 693128
       mov      esi,[StartMemory]
       add      esi,[IndexPageActive]
       mov      ecx,[SizeVideoPageBytes] ;4000
       
       mov      edi,dword [VideoBufMemory]
       
.redraw1:
       mov      al,[esi]
       inc      esi
       mov      byte [edi],al
       add      edi,2
       dec      ecx
       jnz      .redraw1
;call EndProf
       jmp      .exit
       
.FastRedraw:
;new variant 427720
       mov      esi,[StartMemory]
       add      esi,[IndexPageActive]
       mov      ebx,dword [VideoBufMemory]
       mov      ecx,2000/4
       
.redraw2:
       mov      eax,dword [esi]
       add      esi,4
       mov      edi,eax
       shl      eax,16
       shr      eax,16
       mov      edx,eax
       shl      edx,24
       shr      edx,24
       shr      eax,8
       shl      eax,16
       add      eax,edx
       add      eax,0x07000700
       mov      ebp,eax
       mov      eax,edi
       shr      eax,16
       mov      edx,eax
       shl      edx,24
       shr      edx,24
       shr      eax,8
       shl      eax,16
       add      eax,edx
       add      eax,0x07000700
       mov      dword [ebx],ebp
       mov      dword [ebx+4],eax
       add      ebx,dword 8
       dec      ecx
       jnz      .redraw2
;;;;;;;;;;;;;;;;;call EndProf
       
.exit:
       ret
       
       
;EOF
       