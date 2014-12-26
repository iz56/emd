;f5.asm
 
 
EnterTextBuffer:
       cmp      dword [SizeTextSelect],0
       jnz      .work
       call     LoadTBFile ;load from disk
 
.work:
       beep ;send user sound
 
       xor      eax,eax
       mov      al,[y]
       inc      al
       imul     ax,CHAR_ON_LINE
       add      eax,dword [IndexPageActive]
       cmp      eax,dword [SizeTextFormatted]
       jb       .normal_enter_block
 
       mov      eax,dword [SizeTextFormatted]
       add      eax,dword [StartMemory]
       mov      edi,eax
 
       mov      eax,dword [SizeTextSelect]
       add      [SizeTextFormatted],dword eax ;update size
 
       mov      esi,[ptrCopyPasteBuffer]
       mov      ecx,[SizeTextSelect]
 
       call     movsbVersion32
       ret  ;----------------exit[1]
 
.normal_enter_block:
       xor      eax,eax
       mov      al,[y]
       imul     ax,CHAR_ON_LINE
       add      eax,[StartMemory]
       add      eax,[IndexPageActive]
       mov      ebx,eax
       mov      esi,[SizeTextFormatted]
       add      esi,[StartMemory]
       mov      edi,esi
       add      edi,[SizeTextSelect]
       cmp      edi,[EndMemory]
       jb       .shiftText
 
;error - memory is end
       stc
       ret  ;----------------exit[2]
 
.shiftText:
       mov      al,[esi]
       mov      [edi],al
       dec      esi
       dec      edi
       cmp      esi,ebx
       jae      .shiftText
       mov      eax,[SizeTextSelect]
       add      [SizeTextFormatted],eax
 
       xor      eax,eax
       mov      al,[y]
       imul     ax,CHAR_ON_LINE
       add      eax,[StartMemory]
       add      eax,[IndexPageActive]
       mov      edi,eax
 
       mov      esi,[ptrCopyPasteBuffer]
       mov      ecx,[SizeTextSelect]
       call     movsbVersion32
       ret  ;----------------exit[3]
 
 
;EOF
