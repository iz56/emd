;f3.asm
 
 
f3key: ;inc\keys\f3.asm
 
;check light syntax flag ON
       cmp      byte [FlagModeColor],1
       jz       .work
       ret
 
.work:
 
       call     .CopyStringFromMainTxt_asm_comm_cuted
       test     al,al
       jnz      .noZeroSz
       call     Go2NextZeroLine
       ret
.noZeroSz:
       call     Old_F3_Worker
       ret
 
       virtual  at TmpData
.fullSpaces db ?
.onlyComment db ?
.bufStringSz db ?
       end      virtual
 
.buf rb CHAR_ON_LINE+1
 
;--\
.CopyStringFromMainTxt_asm_comm_cuted:
 
       call     GetLnAdr
 
       mov      ebx,eax
       mov      edi,dword .buf
       call     SmartLine
       mov      byte [.bufStringSz],al
 
       ret
 
 
Go2NextZeroLine:
       call     GetLnAdr
       mov      dword [.i],eax
       mov      ecx,dword [.szOfStopBlockOfTrueAsmText]
.l1:
       mov      ebx,dword [.i]
       add      ebx,dword CHAR_ON_LINE
       mov      eax,ebx
       call     CheckEaxToEndOfText
       jae      .exit
       mov      dword [.i],ebx
       mov      edi,dword .buf
       call     SmartLine
 
 
     test     al,al
       jz       .EmptyLine
       dec      ecx
       jnz      .l1
.exit:
       ret
.EmptyLine:
;---\
       mov      dword ebx, [.i]
       add      ebx,dword CHAR_ON_LINE
       mov      eax,ebx
       call     CheckEaxToEndOfText
       jae      .exit
       mov      edi,dword .buf
       call     SmartLine
 
 
     test     al,al
       jnz       .EmptyLineIsEndInLineArray
 
       mov      ebx,dword [.i]
       add      ebx,dword CHAR_ON_LINE
       mov      eax,ebx
       call     CheckEaxToEndOfText
       jae      .exit
       mov      dword [.i],ebx
       jmp .l1
 
;---/
 
.EmptyLineIsEndInLineArray:
 
 
       mov      eax,dword [.i]
 
       sub      eax,dword [StartMemory]
       mov      [IndexPageActive],eax
       mov      [y],0
 
       ret
 
.buf rb CHAR_ON_LINE+1
.i dd ?
.szOfStopBlockOfTrueAsmText dd 100 ;here magic number of lines of code
 
 
;--\
; ebx - data
; edi - temp buffer (size 1 line +1)
;-- return al = size of line
SmartLine:
       push     cx
       mov      cx,CHAR_ON_LINE
       xor      dx,dx
.l1:
       mov      al,[ebx]
       cmp      al,' '
       jz       .itIsSpace
       inc      dl
.itIsSpace:
 
       mov      [edi],al
       cmp      al,';'
       jz       .commentChFound
       inc      edi
       inc      ebx
       dec      cx
       jnz      .l1
 
.commentChFound:
       mov      al,0
       mov      [edi],al
       mov      ax,word CHAR_ON_LINE
       sub      ax,cx
 
       test     dl,dl
       jnz      .notOnlySpacesInLine
       xor      al,al
 
.notOnlySpacesInLine:
       pop      cx
       ret      ;-- return al = size of line
 
 
GetAdrFromNumOfLine:
;eax - num
;return eax - adr
       imulEax80
       add      eax,dword [StartMemory]
       ret
 
GetNumFromAdrOfLine:
;eax - adr
;return eax - num
       sub      eax,dword [StartMemory]
       call     DivEax80
       ret
 
DivEax80:
       mov      [.TmpEcx],ecx
       xor      ecx,ecx
.l1:
       cmp      eax,dword 80
       jb       .ok
       inc      ecx
       sub      eax,dword 80
       jmp      .l1
.ok:
       mov      eax,ecx
       mov      ecx,[.TmpEcx]
       ret
.TmpEcx dd ?
 
CheckEaxToEndOfText:
       sub      eax,dword [StartMemory]
       cmp      eax,dword [SizeTextFormatted]
       ret
 
 
;EOF
