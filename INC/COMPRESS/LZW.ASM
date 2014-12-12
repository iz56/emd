;lzw.asm
 
 
;esi=ptr of arh
;edi=ptr to unpack data free mem
;ebx=ptr to temp work buff
 
LZW_unpack:
 
       MAX_SIZE_READ_BUF=16000;2200
;Decompress - decompresses data compressed by Lempel-Ziv Welch method.
; AX - Pointer to temporary buffer (17K min.).
; CX - Pointer to compressed data.
; SI - Pointer to buffer to decompress.
; Exit: AX - size of decompressed data.
       mov      ax,bx
       mov      cx,si
       mov      si,di
       call     LZWDecompr
       xor      ecx,ecx
       mov      cx,ax
       ret
 
OutByte:
       mov      byte [ bp],al
       inc      bp
       ret
 
;Decompress - decompresses data compressed by Lempel-Ziv Welch method.
; AX - Pointer to temporary buffer (17K min.).
; CX - Pointer to compressed data.
; SI - Pointer to buffer to decompress.
; Exit: AX - size of decompressed data.
 
LZWDecompr:
       push     bp
 
       mov      [Temp_Offs], ax
       mov      [InputOffs], cx
       mov      bp, si
       mov      [OutPutOffs2],si
 
       call     LZWDecomp
 
       mov      ax,bp
       sub      ax,[OutPutOffs2]
       pop      bp
 
       ret
 
LZWDecomp:
       push     si
       push     di
       mov      [le72],0
       mov      [le78],9
       mov      [le70],102h
       mov      [le74],200h
       xor      ax,ax
       mov      [le6a],ax
       mov      [le6c],ax
       mov      [le6e],ax
       mov      [le76byte],al
       mov      [le77byte],al
       mov      [le82a],ax
       mov      [le82b],ax
       mov      [le7a_0],1FFh
       mov      [le7a_2],3FFh
       mov      [le7a_4],7FFh
       mov      [le7a_6],0FFFh
L1_01:
       call     GetNextCode
       cmp      ax,101h
       jnz      L1_02
       jmp      L1_end
L1_02:
       cmp      ax,100h
       jnz      L1_03
       call     InitTable
       call     GetNextCode
       mov      [le6a],ax
       mov      [le6c],ax
       mov      [le77byte],al
       mov      [le76byte],al
       mov      al,[le77byte]
       call     OutByte
       jmp      L1_01
L1_03:
       mov      [le6a],ax
       mov      [le6e],ax
       cmp      ax,[le70]
       jb       L1_04
       mov      ax,[le6c]
       mov      [le6a],ax
       mov      al,[le76byte]
       push     ax
       inc      [le72]
 
L1_04:
       cmp      [le6a],0ffh
       jbe      L1_05
       mov      si,word [Temp_Offs]
       mov      bx,[le6a]
       shl      bx,1
       add      bx,[le6a]
       mov      al,byte [ bx+si+2]
       push     ax
       inc      [le72]
       mov      ax,word [bx+si]
       mov      [le6a],ax
       jmp      L1_04
L1_05:
       mov      ax,[le6a]
       mov      [le76byte],al
       mov      [le77byte],al
       push     ax
       inc      [le72]
       mov      cx,[le72]
       jcxz     L1_07
L1_06:
       pop      ax
       call     OutByte
       loop     L1_06
L1_07:
       mov      [le72],0
       call     AddInTable
       mov      ax,[le6e]
       mov      [le6c],ax
       mov      bx,[le70]
       cmp      bx,[le74]
       jl       L1_08
       cmp      byte [ le78],0ch
       jz       L1_08
       inc      byte [ le78]
       shl      [le74],1
L1_08:
       jmp      L1_01
L1_end:
       pop      di
       pop      si
       ret
 
InitTable :
       mov      byte [ le78],9
       mov      [le74],200h
       mov      [le70],102h
       ret
 
GetNextCode :
       mov      bx,[le82a]
       mov      ax,[le82b]
       add      bx,[le78]
       adc      ax,0
       xchg     bx,[le82a]
       xchg     ax,[le82b]
       mov      cx,bx
       and      cx,7 ;!!!!!
       shr      ax,1
       rcr      bx,1
       shr      ax,1
       rcr      bx,1
       shr      ax,1
       rcr      bx,1
       mov      si,word [InputOffs]
       mov      ax,word [bx+si]
       mov      dl,byte [ bx+si+2]
       or       cx,cx
       jz       GetCode2
GetCode1:
       shr      dl,1
       rcr      ax,1
       loop     GetCode1
GetCode2:
       mov      bx,[le78]
       sub      bx,9
       shl      bx,1
       and      ax,[bx+le7a_0]
       ret
 
AddInTable :
       push     si
       mov      bx,[le70]
       shl      bx,1
       add      bx,[le70]
       mov      si,word [Temp_Offs]
       mov      al,[le77byte]
       mov      byte [ bx+si+2],al
       mov      ax,[le6c]
       mov      word [bx+si],ax
       inc      [le70]
       pop      si
       ret
 
InputOffs rw 1
Temp_Offs rw 1
OutPutOffs2 rw 1
 
le6a rw 1
le6c rw 1
le6e rw 1
le70 rw 1
le72 rw 1
le74 rw 1
le78 rw 1
le7a_0 rw 1
le7a_2 rw 1
le7a_4 rw 1
le7a_6 rw 1
le82a rw 1
le82b rw 1
le76byte rb 1
le77byte rb 1
 
 
;EOF
