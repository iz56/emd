;unform.asm

UnForm:
;---unformat text---
       mov      esi,[StartMemory]
       mov      edi,esi
       mov      ecx,dword [SizeTextFormatted]
       xor      eax,eax
       xor      edx,edx ;new counter
       xor      bx,bx
       add      edi,ecx ;edi = буфер для работы
       add      edi,dword 100h ;;;;;;;;*!.>>>>>>>>>>>>>>>>>>>>!!!
       mov      [SizeTextFormatted], dword edi ;save ptr

       mov      bl, byte CHAR_ON_LINE


.AddZero:
       cmp      ecx,0
       jz       .outAddZero
       mov      al,[esi]
       mov      [edi],al
       inc      esi
       inc      edi
       inc      edx
       dec      ecx
       dec      bl
       jnz      .AddZero

.Paste:
       mov      bl, byte CHAR_ON_LINE

       mov      [edi],byte 0
       inc      edi
       inc      edx
       jmp      .AddZero

.outAddZero:

       mov      esi,[SizeTextFormatted]
       mov      edi,[StartMemory]
       mov      ecx,edx
       xor      edx,edx

.lineCut:
mov ebx , dword 80
       cmp      ecx,0
       jz       .outLineCut
       mov      al,[esi]
       cmp      al,0
       jz       .EndLine
       mov      [edi],al
       inc      esi
       inc      edi
       inc      edx
       dec      ecx
       jnz      .lineCut
       jmp      .outLineCut

.EndLine:
       dec      edi
       dec      edx
jz .TextEnd
dec ebx
jz .linerrrrrrrrrr

.nott:
       mov      al,[edi]
       cmp      al,32
       jz       .EndLine

.linerrrrrrrrrr:
       inc      edi
       inc      edx
       mov      byte [edi],13
       inc      edi
       inc      edx
       mov      byte [edi],10
       inc      edi
       inc      edx
       inc      esi
       dec      ecx
       jnz      .lineCut

.outLineCut:
       mov      [SizeTextFormatted], dword edx
       ret

.TextEnd:
cmp ecx,80
ja .nott
       mov      edi,[StartMemory]
       mov      byte [edi],13
       mov      byte [edi+1],10
       mov      [SizeTextFormatted], dword 2
       ret




;EOF
