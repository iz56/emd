;backsp.asm
 
;return eax=111 �᫨ ��祣� �� ������ - ���� �� NextKey
BackspaceLine:
       call     GetLnAdr
 
       mov      ecx,dword CHAR_ON_LINE
       mov      esi,eax
       dec      eax
       mov      edi,eax
 
.lw1:
       mov      al,[edi]
       cmp      al,20h
       jnz      .lw2
       dec      edi
       dec      ecx
       jnz      .lw1
 
;��室 - ��ப� ����
       dec      byte [y]
       call     .DelLine
       ret
 
.lw2:
       mov      [.shift_x],cl
 
       inc      edi ; ������ ����筮�� ᨬ���� ���孥� ��ப�
 
       cmp      edi,esi
       jnz      .okok
 
       mov      eax,111 ;�
       ret
 
.okok:
       mov      edx,ecx ;edx = ���⮪ �।��饩 ��ப�
       mov      ecx,dword CHAR_ON_LINE
 
.l1:
       mov      al,[esi]
       cmp      al,20h
       jnz      .l2
       inc      esi
       dec      ecx
       jnz      .l1
 
;��室 - ��ப� ����
       call     .DelLine
       ret
 
       mov      ecx,dword CHAR_ON_LINE
.l2:
       mov      al,[esi]
       mov      [edi],al
       inc      esi
       inc      edi
       dec      ecx
       jnz      .l2
 
       call     .DelLine
       call     .ShiftCheck
       ret      ;��室 �� BackspaceLine ---------------------------------------]
 
.DelLine:
       call     GetLnAdr
 
       mov      edi,eax
       add      eax,dword CHAR_ON_LINE
       mov      esi,eax
 
       mov      ebx,[IndexPageActive] ;⥪��� ��࠭��
       xor      eax,eax
       mov      al,[y]
 
       imul     ax,CHAR_ON_LINE
       add      ebx,eax
 
       mov      eax,[SizeTextFormatted]
       sub      eax,ebx
       mov      ecx,eax
       mov      eax,[SizeTextFormatted]
       sub      eax,dword CHAR_ON_LINE
       mov      [SizeTextFormatted],eax
 
       call     movsbVersion32
       ret
 
.ShiftCheck:
; ����� ������ shift ?
       cmp      byte [FlagKeyShift],1
       jz       .Shift_ok
       ret
 
.Shift_ok:
;㧭��� �ࠢ� ��� ���� shift
;䫠� ���ﭨ� ���������� (BIOS data area)
mov al,byte [fs:0+00417h]
       shl      al,7
       cmp      al,0
       jz       .leftShiftPressed
 
;����� ��ࠡ��뢠�� �ࠢ� shift+backspace
       xor      eax,eax
       ret
 
.leftShiftPressed:
       mov      al,[.shift_x]
       mov      [x],al
       dec      [y]
       ret
.shift_x db 0
 
;EOF