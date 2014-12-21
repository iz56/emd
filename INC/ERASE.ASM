;erase.asm
 
 
EraseMemory:
       inc      word [.workQ] ;work times/2
 
       mov      ax,word [.workQ]
       shl      ax,15
       test     ax,ax
       jnz      .work
       ret ;---------exit[1]
 
.work:
       .SIZE_ERASED_MEMORY = 20*25 ;2 page
 
       mov      edi,dword [StartMemory]
       add      edi,dword [SizeTextFormatted]
 
       mov      eax,dword [EndMemory]
       sub      eax,dword .SIZE_ERASED_MEMORY*8
 
       cmp      edi,eax
       jb       .memoryOk
       ret ;---------exit[2]
 
.memoryOk:
       mov      eax,dword 0x020202020 ;32x4
       mov      ecx,dword .SIZE_ERASED_MEMORY
 
.erase_mem:
       mov      [edi],dword eax
       add      edi,4
       mov      [edi],dword eax
       add      edi,4
 
       dec      ecx
       jnz      .erase_mem
 
       ret ;---------exit[3]
 
.workQ dw 0
 
 
;EOF
