;erase.asm
 
 
EraseMemory:
 
       .SIZE_ERASED_MEMORY = 40*25 ;2 page
 
       pusha
 
       mov      edi,dword [StartMemory]
       add      edi,dword [SizeTextFormatted]
 
       mov      eax,dword [.index]
       test      eax,eax
       jz       .firstTime ;only 1 time work
 
       sub      eax,dword .SIZE_ERASED_MEMORY/2 ;20*25
       cmp      edi,eax
       jb       .ok
 
.firstTime:
       mov      ecx,dword .SIZE_ERASED_MEMORY
       mov      eax,dword [EndMemory]
       sub      eax,dword .SIZE_ERASED_MEMORY*5
 
       cmp      edi,eax
       jae      .memoryProblemEnd
 
.erase_mem:
 
       mov      [edi],dword 0x020202020;32x4
       add      edi,4
 
       dec      ecx
       jnz      .erase_mem
 
.ok1:
 
       mov      [.index], edi
 
.ok:
       popa
       ret
 
.memoryProblemEnd:
 
            xor edi,edi
jmp     .ok1
 
 
.index dd 0 ;save old top of erased memory for optimisation
;EOF
