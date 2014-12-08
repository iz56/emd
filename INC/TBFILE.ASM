;tbfile.asm
 
 
LoadTBFile:
 
;open
       mov      ax,3d02h
       mov      dx,NameTbufFile
       int      21h
       jc       .error
       mov      [.h],ax
 
       xor      eax,eax
       mov      [SizeTextSelect],eax ;must be 0
 
.next:
;read next part
       mov      ah,3fh
       mov      bx,[.h]
       mov      cx,SIZE_READ_BUF
       mov      dx,buf
       int      21h
       jc       .close
 
       test     ax,ax
       jz       .close
 
       push     ax;----------------------------save-ax
 
       mov      eax,[ptrCopyPasteBuffer]
       mov      edi,[SizeTextSelect]
       add      edi,eax
       xor      eax,eax
 
       pop      ax
       push     ax ;-------->
 
       add      dword [SizeTextSelect],eax
       add      dword [save_SizeTextSelect],eax
 
       mov      esi,buf
       mov      ecx,eax
       call     movsbVersion32 ;like "rep movsb"
 
       pop      ax ;--------------------------restore ax
       cmp      word ax,SIZE_READ_BUF
       jz       .next
 
;---------------------[+]
       mov      ebx,[ptrCopyPasteBuffer]
       mov      ecx,[SizeTextSelect]
 
       call     Calc_c8
       mov      [c8],al
;---------------------[-]
 
.close:
       mov      ax,3e00h
       mov      bx,[.h]
       int      21h
       ret
 
.error:
       pop      ax
       jmp      NextKey
 
.h dw 0
 
;----------------------------------------------------------------
 
 
SaveTBFile:
 
       cmp      dword [SizeTextSelect],0
       jnz      .work
       ret
 
.work:
       mov      eax,[SizeTextSelect]
       cmp      eax,[save_SizeTextSelect]
       jnz      .write
;------------------------
       mov      ebx,[ptrCopyPasteBuffer]
       mov      ecx,eax
 
       call     Calc_c8
       cmp      byte [c8],al
       jnz      .write
 
       ret
;------------------------
 
.write:
;delete file and creat
       mov      dx,NameTbufFile
       mov      ah,41h
       int      21h
       jc       .exit
 
       mov      dx,NameTbufFile
       mov      ah,3ch
       mov      cx,0
       int      21h
       jc       .exit
 
       mov      [.h],ax
 
.next:
       mov      eax,[SizeTextSelect]
       cmp      dword eax,SIZE_READ_BUF
       jbe      .writeEnd
       mov      esi,[ptrCopyPasteBuffer]
 
       add      esi,[iTbuf]
       mov      edi,buf
       mov      dword ecx,SIZE_READ_BUF
 
       call     movsbVersion32 ;like "rep movsb"
 
       mov      cx,SIZE_READ_BUF
       mov      ah,40h
       mov      bx,[.h]
       mov      dx,buf
       int      21h
       jc       .close
 
       add      dword [iTbuf],SIZE_READ_BUF
       sub      dword [SizeTextSelect],SIZE_READ_BUF
       jmp      .next
 
.writeEnd:
 
       mov      esi,[ptrCopyPasteBuffer]
 
       add      esi,[iTbuf]
       mov      edi,buf
       mov      ecx,[SizeTextSelect]
       cmp      ecx,0
       jz       .close
 
       call     movsbVersion32 ;like "rep movsb"
 
       mov      ecx,[SizeTextSelect]
       mov      ah,40h
       mov      bx,[.h]
       mov      dx,buf
       int      21h
 
.close:
       mov      ax,3e00h
       mov      bx,[.h]
       int      21h
.exit:
       ret
.h dw 0
 
;--
Calc_c8:
       mov      al,[ebx]
       add      al,[ebx+1]
       inc      ebx
       dec      ecx
       jnz      Calc_c8
       ret
 
;EOF
