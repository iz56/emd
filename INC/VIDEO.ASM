;video.asm
 
 
       macro    colored
       {
       call     LightText
       }
 
       macro    cls color
       {
       mov      ah,color
       call     ClrScr ;inc\cls16.asm
       }
 
 
       macro    cursor col,line
       {
       mov      dword ebx, 80 * line + col
       call     SetCursor
; mov ah,02h
; mov dl,col
; mov dh,line
; mov bh,0
; int 10h
       }
 
 
       macro    redraw
       {
       local    redraw1
       local    redraw2
       local    FastRedraw
       local    nofilter
       local    redrawfilter
       local    redrawfilter2
       local    exit
 
;проверяем FlagTextSelect
       cmp      byte [FlagTextSelect],0
       jz       FastRedraw
 
;;;;;;;;;call StartProf
;старый вариант 693128
       mov      esi,[StartMemory]
       add      esi,[IndexPageActive]
;       mov      ecx,4000
       mov      ecx,[SizeVideoPageBytes] ;4000
 
       mov      edi,dword [VideoBufMemory]
 
redraw1:
       mov      al,[esi]
       inc      esi
       mov      byte [edi],al
       add      edi,2
       dec      ecx
       jnz      redraw1
;call EndProf
       jmp      exit
 
FastRedraw:
;новый вариант 427720
       mov      esi,[StartMemory]
       add      esi,[IndexPageActive]
; xor ebx,ebx
       mov      ebx,dword [VideoBufMemory]
       mov      ecx,2000/4
 
redraw2:
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
;mov dword [gs:ebx],eax
; add ebx,dword 4
       mov      eax,edi
       shr      eax,16
       mov      edx,eax
       shl      edx,24
       shr      edx,24
       shr      eax,8
       shl      eax,16
       add      eax,edx
       add      eax,0x07000700
;mov byte [gs:0+di],al
       mov      dword [ebx],ebp
; add ebx,dword 4
       mov      dword [ebx+4],eax
       add      ebx,dword 8
;mov byte [gs:ebx],al
; add ebx,dword 2
       dec      ecx
       jnz      redraw2
;;;;;;;;;;;;;;;;;call EndProf
 
exit:
       }
 
 
;EOF
