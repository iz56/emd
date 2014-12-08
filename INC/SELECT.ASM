;select.asm
 
 
;�室: ah ᮤ�ন� ᪠���� ����⮩ ������
;dl = [FlagKeyShift] ,dh = [FlagTextSelect]
 
SelectBlockText:
 
 
;�஢��塞 ����⨥ ������ � 䫠���
       cmp      dl,0;[FlagKeyShift];,byte 0
       jz       .NotKeyShiftPress
 
;�����a shift - �஢��塞 䫠� �뤥����� ����� ��ப
       cmp      dh,0;[FlagTextSelect];,byte 0
       jz       .FlagTextSelectZero
 
;�஢��塞 ᪠���� - �᫨ �� 50h �����稢��� �뤥�����
       cmp      ah,50h ;⥯��� ॣ���� ax is free
       jnz      .EndSelect
 
 
;----------------------
;�஢��塞 ����� ⥪��
;�᫨ ⥪��� ��ப� � ���� ⥪�� - �����稢��� �뤥����� �ਭ㤨⥫쭮
       mov      ebx,[IndexPageActive]
       xor      eax,eax
       mov      al,[y]
       inc      al
 
; imul ax,CHAR_ON_LINE
       imulEax80
 
       add      ebx,eax
       cmp      ebx,[SizeTextFormatted]
       jae      .EndSelect
;----------------------
 
 
       add      dword [SizeTextSelect],CHAR_ON_LINE ;㢥��稢��� ���稪
; ��. ⥪��
 
;����� �஢��塞 ࠧ��� �뤥������� ⥪��
       cmp      dword [SizeTextSelect],SIZE_TXT_BUF
       ja       .EndSelect;�����稢��� �뤥�����
 
;����� ���ᢥ稢��� �뤥�塞� ⥪��
       xor      eax,eax
       mov      al,[y]
;�஢��塞 �������� ��࠭�
       cmp      al,24
       jnz      .OnPage
 
;���ᢥ稢��� ��ப� �� ��࠭� ᢥ���
       mov      esi,0
; mov ebx,dword [VideoBufMemory]
 
.scan23:
       mov      ebx,dword [VideoBufMemory]
       add      ebx,esi
       mov      al, byte [ebx+1]
       add      esi,160;2
       cmp      esi,4000
       jz       .OnPage;�������
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
;shl edi,16
;shr edi,16
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
 
;����頥� �뤥����� ⥪�� �
       mov      edi,[ptrCopyPasteBuffer]
 
;05.02.2012
 
;�����㥬 ⥪�� ��࠭�� ,��������� �������� ����
       mov      ecx, dword SIZE_TXT_BUF ;!
 
       call     movsbVersion32
 
 
;����� ���ᢥ稢��� �뤥�塞� ⥪�� (- line)
       xor      eax,eax
       mov      al,[y]
       jmp      .OnPage ;�. ���
 
 
.NotKeyShiftPress:
 
;�஢��塞 FlagTextSelect
       cmp      byte [FlagTextSelect],0
       jnz      .EndSelect
       ret
 
;�����稢��� �뤥����� ⥪��
.EndSelect:
       beep
       xor      eax,eax
       mov      [FlagTextSelect], byte al
       redraw   ;����������
       colored
       ret
 
;EOF