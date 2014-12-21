;select.asm
 
 
;ah= scan code of pressed key
;dl = [FlagKeyShift]
;dh = [FlagTextSelect]
 
SelectBlockText:
 
       cmp      dl,0
       jz       .NotKeyShiftPress
 
;shift pressed - check flag select
       cmp      dh,0
       jz       .FlagTextSelectZero
 
;check scan code - if not 50h ended selecting
       cmp      ah,50h ;now ax is free
       jnz      .EndSelect
 
 
;check end text
;if activ line in end of text - close selecting forsed
       mov      ebx,[IndexPageActive]
       xor      eax,eax
       mov      al,[y]
       inc      al
 
; imul ax,CHAR_ON_LINE
       imulEax80
 
       add      ebx,eax
       cmp      ebx,[SizeTextFormatted]
       jae      .EndSelect
 
 
       add      dword [SizeTextSelect],CHAR_ON_LINE ;inc size of selected text
 
;here check size of selected text
       cmp      dword [SizeTextSelect],SIZE_TXT_BUF
       ja       .EndSelect ;end selecting
 
;lighting
       xor      eax,eax
       mov      al,[y]
;check if moved screen
       cmp      al,24
       jnz      .OnPage
 
;light upper line on page
       mov      esi,0
 
.scan23:
       mov      ebx,dword [VideoBufMemory]
       add      ebx,esi
       mov      al, byte [ebx+1]
       add      esi,160 ;2
       cmp      esi,4000
       jz       .OnPage ;never
       cmp      al,23
       jnz      .scan23
       cmp      esi,160
       jz       .si_is_good
       sub      esi,160*2
.si_is_good:
       mov      edi,esi
       mov      cx,CHAR_ON_LINE
       jmp      .ColoredLine
 
.OnPage:
 
; imul ax, word CHAR_ON_LINE
       imulEax80
 
       mov      bx,ax
       add      ax,bx
       mov      di,ax
;inc di
       mov      cx, word CHAR_ON_LINE
 
.ColoredLine:
; gs=0b800h
       mov      bx,di
       xor      edi,edi
       mov      di,bx
       mov      ebx,dword [VideoBufMemory]
       add      ebx,edi
       mov      [ebx+1], byte 23
       add      edi,dword 2
       dec      cx
       jnz      .ColoredLine
       ret
 
 
.FlagTextSelectZero:
       cmp      ah,50h
       jz       .l1
       ret
.l1:
 
       xor      eax,eax
       mov      al,byte [y]
; imul ax,CHAR_ON_LINE
       imulEax80
 
       mov      ebx,dword [StartMemory]
       add      ebx,dword [IndexPageActive]
 
       add      eax,ebx
       mov      esi,eax
       mov      byte [FlagTextSelect],1
       mov      dword [SizeTextSelect],CHAR_ON_LINE
 
       mov      edi,[ptrCopyPasteBuffer]
 
;copy selected text preverse max size buf
       mov      ecx, dword SIZE_TXT_BUF ;!
       call     movsbVersion32
 
;lighting selected text (- one line)
       xor      eax,eax
       mov      al,[y]
       jmp      .OnPage
 
.NotKeyShiftPress:
       cmp      byte [FlagTextSelect],0
       jnz      .EndSelect
       ret
 
.EndSelect:
       beep
       xor      eax,eax
       mov      [FlagTextSelect], byte al
       redraw
       colored
       ret
 
 
;EOF
