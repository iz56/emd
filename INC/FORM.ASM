;form.asm
 
;magic value for .CheckDosUnx
       DOS_OK   = 0x0555
       DOS_WRONG = 0x0333
 
 
       ASCII_CARRIAGE_RETURN = 0x0d
       ASCII_LINE_FEED = 0x0a
 
 
SpecEOFbyte db 0 ;here save (old format text) byte (very old)
 
 
FormText:
 
       call     .SetSpecEOFbyte
 
       call     .CheckDosUnx
       cmp      eax, DOS_OK
       jnz      .atherTxt
 
       call     .FormTextDos
       ret
 
.atherTxt:
 
       call     FormTextBinaryFile
       ret
 
 
.SetSpecEOFbyte:
;first init SpecEOFbyte by defualt value
       xor      eax,eax
       mov      [SpecEOFbyte], byte al
 
       call     .GetLastByte
 
       cmp      al,20h ;all above 20h = chars
       jae      .okTxt ;if text not old style
 
       cmp      al,ASCII_LINE_FEED ;2 byte
       jz       .okTxt ;if text not old style
 
       mov      [SpecEOFbyte], byte al
.okTxt: ;if text not old style
       ret
 
 
.CheckDosUnx:
 
       xor      ebx,ebx
       mov      esi,[StartMemory]
       mov      ecx,160;[SizeFile]
 
.ll1:
       mov      al,byte [esi]
       cmp      al,ASCII_CARRIAGE_RETURN; first byte
       jz       .Dos1013
       inc      esi
       dec      ecx
       jnz      .ll1
 
       mov      eax, DOS_WRONG
       ret
 
 
.Dos1013:
       mov      al,byte [esi+1]
       cmp      al,ASCII_LINE_FEED ;2 byte
       jz       .DosOK
 
       mov      al,byte [esi-1]
       cmp      al,ASCII_LINE_FEED ;2 byte
       jz       .DosOK
 
       mov      eax, DOS_WRONG
       ret
 
 
.DosOK:
       mov      eax, DOS_OK
       ret
 
 
;return al = last byte of text
.GetLastByte:
       mov      eax,dword [StartMemory]
       add      eax,dword [SizeFile]
       mov      ebx,eax
       xor      eax,eax
       mov      al,byte [ebx-1]
       ret
 
 
 
;.FormTextUnx:
;mov eax,
;       ret
 
 
.FormTextDos:
 
;+
;если файл не оканчивается на 10(дес), то корректируем SizeFile
       call     .GetLastByte
       cmp      al,10
       jz       .l1
       inc      dword [SizeFile]
.l1:
;-
 
       call     FormText1
 
       mov      esi,[StartMemory]
       mov      ecx,ebx
       xor      ebx,ebx
       mov      edi,esi
       add      edi,ecx
       mov      edx,edi
 
NextLine:
       add      dword [SizeCheckEr],CHAR_ON_LINE
       mov      byte [CountCHAR_ON_LINE],CHAR_ON_LINE+1
 
.extract:
       cmp      ecx,0
       jz       .out_extract
 
       dec      [CountCHAR_ON_LINE]
       jz       .cut_line;new_extract_line_start
 
       dec      ecx
       jz       .out_extract
 
       mov      al,[esi]
       inc      esi
 
       cmp      al,0
       jz       .enter_end_of_line32
 
       mov      [edi],al
       inc      edi
       inc      ebx;[SizeTextFormatted]
       jmp      .extract
 
.cut_line:
       cmp      byte [esi],0
       jnz      NextLine
 
       inc      esi
       dec      ecx
       jmp      NextLine
 
.enter_end_of_line32:
       cmp      byte [CountCHAR_ON_LINE],0
       jz       NextLine
 
       mov      byte [edi],32
       inc      edi
       inc      ebx;[SizeTextFormatted]
       dec      [CountCHAR_ON_LINE]
       jmp      .enter_end_of_line32
 
.out_extract: ;конечная строка
       cmp      byte [CountCHAR_ON_LINE],0
       jz       .out_e_l
 
       mov      al,byte [CountCHAR_ON_LINE]
.l1:
       mov      byte [edi],32
       inc      edi
       inc      ebx;[SizeTextFormatted]
       dec      byte al ;[CountCHAR_ON_LINE]
       jnz      .l1
.out_e_l:
 
 
       mov      edi,[StartMemory]
       mov      esi,edx
       mov      eax,ebx;[SizeTextFormatted]
       mov      [SizeTextFormatted],dword ebx;---------------------|
       shr      eax,2 ;divide 4
       inc      eax
       mov      ecx,eax
 
       xor      edx,edx
.moves_on_StartMemory:
       mov      eax,dword [esi+edx]
       mov      [edi+edx],dword eax
       add      edx,dword 4
       dec      ecx
       jnz      .moves_on_StartMemory
 
       ret
 
 
FormText1:
       xor      ebx,ebx ;ebx - счетчик форматированного текста
       mov      esi,[StartMemory]
       mov      ecx,[SizeFile]
       inc      ecx
       mov      eax,esi
       add      eax,ecx
       mov      edi,eax
       mov      edx,edi ;save адрес
 
.form_0:
       cmp      ecx,dword 0
       jz       .out_form_0
       mov      al,byte [esi]
       cmp      al,13
       jz       .enter_0
       cmp      al,32
       jb       .enter_32
 
.go_form:
       mov      [edi],al
       inc      esi
       inc      edi
       inc      ebx;[SizeTextFormatted]
       dec      ecx
       jmp      .form_0
 
.enter_0:
       mov      byte [edi],0
       add      esi,2
       inc      edi
       inc      ebx;[SizeTextFormatted]
       dec      ecx
       jz       .out_form_0
       dec      ecx
       jmp      .form_0
.enter_32:
       mov      al,32
       jmp      .go_form
 
.out_form_0:
 
       dec      ebx
 
       mov      edi,[StartMemory]
       mov      esi,edx
       mov      eax,ebx ;ebx - счетчик форматированного текста
 
       shr      eax,2 ;divide 4
       inc      eax
       mov      ecx,eax
 
       xor      edx,edx
.moves_on_StartMemory:
       mov      eax,dword [esi+edx]
       mov      [edi+edx],dword eax
       add      edx,dword 4
       dec      ecx
       jnz      .moves_on_StartMemory
 
;dec ebx
       ret
 
 
FormTextBinaryFile:
       mov      esi,[StartMemory]
       mov      ecx,[SizeFile]
       mov      edi,esi
       add      edi,ecx
 
 
       xor      edx,edx ;edx = new size of formatted text
 
.nextLine:
       add      dword [SizeCheckEr],CHAR_ON_LINE
 
 
       .SIZEOFLINEONDEFAULT = 80;79
       mov      bl,byte .SIZEOFLINEONDEFAULT
.nextByte:
 
       dec      ecx
       jz       .ItEndOfIncomingData
 
       mov      ax,word [esi]
       inc      esi
       cmp      ax,0
       jz       .nextByte
 
       cmp      ax,0d0ah
       jz       .nextByte
 
       cmp      ax,0a0dh
       jz       .nextByte
 
 
       mov      al,byte [esi-1]
       cmp      al,0
       jz       .itLineEnd
; cmp al,'$'
; jz .itLineEnd
 
       cmp      al, ASCII_CARRIAGE_RETURN
       jz       .itLineEnd
 
       cmp      al, ASCII_LINE_FEED
       jz       .itLineEnd
 
       cmp      al,32
       jae      .itTrueChar
       .SPECCHAR = '?'
       mov      al,byte .SPECCHAR
.itTrueChar:
       mov      [edi],byte al
       inc      edi
       inc      edx
 
       dec      bl
       jz       .nextLine
 
 
       .MAXSIZEOFFORMATTEDTEXT = 100000000
       cmp      edx, dword .MAXSIZEOFFORMATTEDTEXT
       jb       .nextByte
 
.errorSize:
 
 
;pppppppppppppppppp
 
jmp .ItEndOfIncomingData
 
 
 
 
.itLineEnd:
 
       mov      al,32
.PasteSpaces:
       mov      [edi],byte al
       inc      edi
       inc      edx
       cmp      edx, dword .MAXSIZEOFFORMATTEDTEXT
       jae      .errorSize
       dec      bl
       jz      .nextLine
       jmp      .PasteSpaces
 
 
.ItEndOfIncomingData:
 
 
;++
       mov      al,32
.PasteSpacesLastTime:
       mov      [edi],byte al
       inc      edi
       inc      edx
       cmp      edx, dword .MAXSIZEOFFORMATTEDTEXT
       jae      .errorSize
       dec      bl
       jz      .outPasteSpaces
       jmp      .PasteSpacesLastTime
.outPasteSpaces:
;++
 
       mov      edi,dword [StartMemory]
       mov      eax,[SizeFile]
       mov      esi,edi
       add      esi,eax
       mov      ecx,edx
       mov      [SizeTextFormatted],dword ecx;---------------------|
 
.moeStart:
       mov      al,byte [esi]
       mov      byte [edi],al
       inc      esi
       inc      edi
       dec      ecx
       jnz      .moeStart
 
       ret
 
 
;EOF
