;rep.asm
 
 
       PROGRESS_X = 10 ;how many info points print to user
 
       macro    AbortUser {
       inc      byte [.Chet]
       mov      al, [.Chet]
       test     al,al
       jz       .noCheckEsc
 
       cmp      [SizeTextFormatted],dword CHAR_ON_LINE*1000
       jbe      .noCheckEsc
       pusha
       mov      ah,1 ;check to see if a char is ready
       int      16h
       jz       .ReadLoop ;nope, continue
 
       mov      ah,0
       int      16h ;get the character & put in AX
       cmp      ah,1 ;?Esc ...
       jnz      .ReadLoop ;nope, continue
 
       popa
       jmp      .Cansel
.Chet db 0
.ReadLoop:
       popa
.noCheckEsc:
       }
 
;in
;ax=ptr to str1
;bx=ptr to str2
 
;out
;ecx=num of replaces
 
FindAndReplace:
       mov      esi,dword [StartMemory]
       mov      ecx,dword [SizeTextFormatted]
       mov      di,ax
 
.nextCh:
       AbortUser
 
       mov      dword [.saveEcx],ecx
       call     .Compare ;
       jnc      .notFind
 
       clc
       inc      dword [.numOfReplaces]
       call     ReplaceIt ;ret eax = size for correct esi ,ecx
       dec      eax
       mov      ecx,dword [.saveEcx]
       cmp      ecx,eax
       jbe      .Cansel ;end text exit
       sub      ecx,eax ;correct ecx
       add      esi,eax ;correct esi
       jmp      .afterR
 
.notFind:
       mov      ecx,dword [.saveEcx]
.afterR:
       inc      esi
       dec      ecx
       jnz      .nextCh
 
.Cansel: ;if user press Esc - go to here
;ecx=num of replaces
       mov      ecx, dword [.numOfReplaces]
       mov      dword [.numOfReplaces],0
       ret      ;- - - - - - - - - - - - - - - - - - - exit
.saveEcx dd 0
.numOfReplaces dd 0
 
 
.Compare:
       mov      byte [.firstChOnLineFlag],0
       mov      dword [.saveEsi],esi
 
       push     di
       mov      cl,MAX_SIZE_FOR_ENTERED_WORD
 
.lll:
       cmp      byte [di],0
       jnz      .notEnd
       pop      di
       mov      esi ,dword [.saveEsi]
 
       stc
       ret
 
.notEnd:
       mov      al,byte [esi]
       cmp      al,byte [di]
       jz       .okMath
 
.misMatch:
       pop      di
       mov      esi ,dword [.saveEsi]
       clc
       ret
 
.okMath:
       call     TestEsiForRangeLine
       jc       .rangeErr
 
.firstSkip:
       mov      byte [.firstChOnLineFlag],1
       inc      esi
       inc      di
       dec      cl
       jnz      .lll
 
       pop      di
       mov      esi ,dword [.saveEsi]
 
       clc
       ret
 
.rangeErr:
       cmp      byte [.firstChOnLineFlag],0
       jz       .firstSkip
       jmp      .misMatch
 
.saveEsi dd 0
.firstChOnLineFlag db 0
 
 
IfStr1EqaStr2:
       mov      edi,esi
       mov      si,bx
       mov      cx,word MAX_SIZE_FOR_ENTERED_WORD
.go:
       mov      al,byte [si]
       test     al,al
       jz       .ok
       mov      [edi],byte al
       inc      edi
       inc      si
       dec      cx
       jnz      .go
.ok:
       ret
 
 
;bx=str for repalce
;esi=here do it (in text)
IfStr1_b_Str2:
       mov      edi,esi
       mov      si,bx
       mov      cx,word [ReplaceIt.str1size]
.go:
       mov      al,byte [si]
       mov      [edi],byte al
       inc      edi
       inc      si
       dec      cx
       jnz      .go
 
;str1size=0 , then enter text
.nextEnter:
       push     si
       mov      eax,edi
       sub      eax,dword [StartMemory]
       call     DivEaxCHAR_ON_LINE
       pop      si
       test     ecx,ecx
       jz       .ok
       push     si
       add      edx,dword CHAR_ON_LINE
       add      edx,dword [StartMemory]
       mov      esi,edx
       call     .shiftChToEndOfLine
       pop      si
       mov      al,byte [si]
       mov      [edi],byte al
       inc      edi
       inc      si
       mov      al,byte [si]
       test     al,al
       jnz      .nextEnter
.ok:
       ret
 
.shiftChToEndOfLine:
.l1:
       cmp      esi,eax
       jz       .okShift
       dec      esi
       mov      bl,byte [esi-1]
       mov      byte [esi],bl
       dec      ecx
       jnz      .l1
.okShift:
       ret
 
 
IfStr1_a_Str2:
       mov      edi,esi
       mov      si,bx
       mov      cx,word [ReplaceIt.str1size]
.go:
       mov      al,byte [si] ;si=ptr to str2
       test     al,al
       jz       .EndStr2
 
       mov      [edi],byte al
       inc      edi
       inc      si
       dec      cx
       jmp      .go
 
.EndStr2:
;need del _cx_ num of chars
       push     cx ;save it
       mov      eax,edi
       mov      dword [.ptrToStartDel],edi
 
       sub      eax,dword [StartMemory]
       call     DivEaxCHAR_ON_LINE
       pop      ax
       test     ecx,ecx
       jz       .ok
 
       mov      cx,ax
       add      edx,dword CHAR_ON_LINE
       add      edx,dword [StartMemory]
;edx=ptr to end of line
       dec      edx
 
.nextShiftCycle:
       mov      esi,dword [.ptrToStartDel]
.nextShift:
       mov      al,byte [esi+1]
       mov      byte [esi+1],32
       mov      [esi],byte al
       inc      esi
       cmp      esi,edx
       jnz      .nextShift
       dec      cx
       jnz      .nextShiftCycle
.ok:
       ret
 
.ptrToStartDel dd 0
 
 
 
;------\
;in eax=value/CHAR_ON_LINE
;out edx=ptr ,eax=num from start line ,ecx=num chars to end of line
DivEaxCHAR_ON_LINE:
       mov      edx,eax
.l1:
       cmp      eax,dword CHAR_ON_LINE
       jbe      .ok
       sub      eax,dword CHAR_ON_LINE
       jmp      .l1
.ok:
       sub      edx,eax
       mov      ecx,dword CHAR_ON_LINE
       sub      ecx,eax
       ret
;------/
 
 
;di=str to replace
;bx=str for repalce
;esi=here do it (in text)
ReplaceIt:
       call     .PushAll
 
;variant 1 : s1=s2
;------- 2 : s1>s2
;------- 3 : s1<s2
 
       mov      si,bx
       call     CalcChStrZ
       mov      [.str2size],ax
       push     ax
       mov      si,di
       call     CalcChStrZ
       mov      [.str1size],ax
 
       pop      dx
       cmp      ax, dx ;ax=str1 size,dx=str2 size
       jnz      .notEqa
 
       call     .PopAll
;1=2
       call     IfStr1EqaStr2
       xor      eax,eax
       mov      ax,word [.str1size]
       mov      dword [.saveRegs],eax
       jmp      .ok
 
.notEqa:
       ja       .above
       call     .PopAll
;1<2
       call     IfStr1_b_Str2
       xor      eax,eax
       mov      ax,word [.str2size] ;!
       mov      dword [.saveRegs],eax
       jmp      .ok
 
.above:
;1>2
       call     .PopAll
       call     IfStr1_a_Str2
       xor      eax,eax
       mov      ax,word [.str1size]
       mov      dword [.saveRegs],eax
 
.ok:
;\
       mov      eax,dword [.progressDisplayX]
       test     eax,eax
       jnz      .noDisplay
 
       mov      dword [.progressDisplayX],PROGRESS_X
       cmp      [SizeTextFormatted],dword CHAR_ON_LINE*1000
       jb       .l1
       mov      dword [.progressDisplayX],PROGRESS_X*2
.l1:
;signal to user, then do it
       printToScr PROGRESS_SPEC_CHAR
.noDisplay:
       dec      dword [.progressDisplayX]
;/
       call     .PopAll
       ret
 
.progressDisplayX dd 0
 
.PushAll:
       mov      dword [.saveRegs],eax
       mov      dword [.saveRegs+4],ebx
       mov      dword [.saveRegs+8],edx
       mov      dword [.saveRegs+12],edi
       mov      dword [.saveRegs+16],esi
       mov      dword [.saveRegs+20],ecx
       ret
 
.PopAll:
       mov      eax,dword [.saveRegs]
       mov      ebx,dword [.saveRegs+4]
       mov      edx,dword [.saveRegs+8]
       mov      edi,dword [.saveRegs+12]
       mov      esi,dword [.saveRegs+16]
       mov      ecx,dword [.saveRegs+20]
 
       ret
 
.saveRegs dd 0,0,0,0,0,0,0
.str1size dw 0
.str2size dw 0
 
 
;si=ptr to str
CalcChStrZ:
macro var1ttt {
       push     di
       push     si
       mov      di,si
.l1:
       mov      al,byte [si]
       inc      si
       test     al,al
       jnz      .l1
       dec      si
       sub      si,di
       mov      ax,si
       pop      si
       pop      di
       ret
}
macro var1t {
       push     si
       mov      ax,si
.l1:
       cmp      byte [si],0
jz .ok
       inc      si
       jmp      .l1
.ok:
       sub      si,ax
       mov      ax,si
       pop      si
       ret
}
var1t
;-------------------[-]
 
 
;in esi = ptr to char into test
;set carry flag if it first char in line
TestEsiForRangeLine:
 
       call     .PushAll
       mov      eax,esi
       sub      eax,dword [StartMemory]
 
       cmp      eax,dword CHAR_ON_LINE*10000
       jb       .l0
       sub      eax,dword CHAR_ON_LINE*10000
.l0:
 
       cmp      eax,dword CHAR_ON_LINE*1000
       jb       .l1
       sub      eax,dword CHAR_ON_LINE*1000
.l1:
 
       cmp      eax,dword CHAR_ON_LINE*100
       jb       .l2
       sub      eax,dword CHAR_ON_LINE*100
.l2:
       test     eax,eax
       jz       .ok
 
       cmp      eax,dword CHAR_ON_LINE
       jb       .Noo
 
       sub      eax,dword CHAR_ON_LINE
       jmp      .l2
.Noo:
       call     .PopAll
       clc
       ret
 
.ok:
       call     .PopAll
       stc
       ret
 
 
.PushAll:
       mov      dword [.saveRegs],eax
       mov      dword [.saveRegs+4],esi
       ret
 
.PopAll:
       mov      eax,dword [.saveRegs]
       mov      esi,dword [.saveRegs+4]
       ret
 
.saveRegs dd 0,0
 
 
;EOF
