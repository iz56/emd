;help.asm
 
HelpMenu:
 
;ᬥ饭�� �� ⠡���� 㪠��⥫�� ��뢠����� �� ���� ����
.pCodsTbl dd .CodsPtrsTbl
 
;ᬥ饭�� �� ⠡���� ⥪�⮢�� ��ப ᮮ⢥������� �㭪⠬ ����
.pStrTbl dd .StrsTbl
 
.cItems dd 7 ;�᫮ items �㭪⮢ ���� (�ᥣ�|total)
 
.SizeStr dd 27 ; size of 1 text string
 
.PosW dd 16 ; position of text window (*2)
 
.ActiveItem dd 1 ;⥪��� ��ப�
 
.colorNotActivItem dd 7;梥� ����⨢��� �㭪⮢ ����
 
.colorActivItem dd 23;梥� ��⨢��� �㭪⮢ ����
 
.TipeOfMenu dd INFO_MENU_TIPE;⨯ �����⬠ ����
 
.StrsTbl:
db ' 1 - Help Exit  ---------- ',0
db ' 2 - Save Document ------- ',0
db ' 3 - Exit to OS ---------- ',0
db ' 4 - Copy&Paste ---------- ',0
db ' 5 - Swith Video Mode ---- ',0
db ' 6 - F3 key -------------- ',0
db ' 7 - Cut Strings --------- ',0
 
 
dw .dum ;����⢨� �� 㬮�砭��
;-------------------------------------------------------------------------------
.CodsPtrsTbl:
dw .item1
dw .item2
dw .item3
dw .item4
dw .item5
dw .item6
dw .item7
dw .dum ;����⢨� �� 㬮�砭��
 
;-------------------------------------------------------------------------------
.dum:
       ret
;--------
; mov esi , dword .saveText
.item:
;clear back area
       mov      edi,dword [VideoBufMemory]
       mov      ax,0720h
       mov      ecx,1000
.l1:
       mov      [edi],dword eax
       add      edi,4
       dec      ecx
       jnz      .l1
 
       mov      edi,dword [VideoBufMemory]
;print topic ,start on 10th line
       add      edi,dword 160*10
; mov esi , dword .saveText
       call     .PrintHelpTopicText
       ret
 
.item1:
       mov      esi , dword .ExitHelpText
       call     .item
       ret
 
.ExitHelpText:
db '��室 �� ����� <ESC> . ' ,0
 
;----
 
 
;--------
.item2:
       mov      esi , dword .saveText
       call     .item
       ret
.saveText:
db '���࠭���� �����񭭮�� ⥪�� �������� '
db '⮫쪮 � �����६���� ��室�� �� �ணࠬ�� �� ����⨨ <F2>'
db '. ��⮬ ����᪠�� ।���� ᭮�� - ����� �㤥� ⠬ �� ��� � ��',0
 
;----
 
 
.item3:
       mov      esi , dword .escText
       call     .item
       ret
.escText:
db '��室 �� �ணࠬ�� ��� ��࠭���� ��������� � ⥪�� - '
db '�ᥣ�� �� ����⨨ <ESC>.'
db '�᫨ ����᪠�� ।���� ᭮�� - ����� �㤥� ⠬ ��� ��,'
db '�� ��᫥����� ��࠭����. �᫨ ⮫쪮 �� ࠡ�⠥� � ��᪮�쪨�� '
db '䠩���� ⥪�⮢ �����६���� - ������������ ��᫥���� ��࠭��.'
db '���� �࠭���� ���न��� ����� � ����� � ��ࠥ��� �� �⪫. ��⠭��.',0
 
;----
.item4:
       mov      esi , dword .CopyPastText
       call     .item
       ret
.CopyPastText:
db '����஢���� � ��⠢�� ⥪�� �������� ⮫쪮 ��ப��� . ��� �뤥����� '
db '�㦭�� ��ப ⥪�� - ��५�� ���� � ���. ��⠢�� - <F5>.'
db ' ��ப� �� ���� ��࠭����� �� ����. ��᪥, �᫨ ������� 䠩� -'
db ' c:\tmp\emd.tmp . ����� ��७���� ⥪�� �� 䠩�� � 䠩�' ,0
 
;----
 
.item5:
       mov      esi , dword .SwithVideoModeText
       call     .item
       ret
.SwithVideoModeText:
db '��४��祭�� �� ⥪�⮢���, �⠭���⭮�� �����०��� � ����᪨� - <'
db 'F8>. � ���⭮ - � �� ������. ��室��� � ��. ०��� - ����� 㤥ন��'
db '� <Shift>+<F8> - �������� ������� - 㬥����� �મ��� 梥⮢. ',0
 
;----
 
.item6:
       mov      esi , dword .GoToF3Text
       call     .item
       ret
 
.GoToF3Text:
db '�� ����⨨ <F3> ,�� �᫮��� , �� ⥪��� ��ப� - ��ப� ��।�� '
db '�ࠢ����� (��ᥬ����) , ����� ��३��� �� 楫���� ��ப�. ',0
 
;----
 
.item7:
       mov      esi , dword .CutStrText
       call     .item
       ret
 
.CutStrText:
db '�� ����⨨ <Shift>+<Enter> - ��ப� ����� ࠧ१��� �� ���.'
db ' �ࠢ� ��� ���� <Shift> - ����� ���祭��.' ,0
 
;----
 
 
;-----
;print topic
.PrintHelpTopicText:
       pusha
       mov      eax,[.leftSpaces]
       shl      eax,1 ;x2
       add      edi,eax
       mov      ecx,[.checkRightSpaces]
 
.PrintItLine:
       mov      al,byte [esi]
       inc      esi
       mov      ah,7
       mov      word [edi],ax
       add      edi,dword 2
       test     al,al
       jz       .PrintHelpTopicTextOut
       dec      ecx
       jnz      .PrintItLine
       mov      eax,[.leftSpaces]
       add      eax,[.rightSpaces]
       shl      eax,1 ;x2
       add      edi,eax
       mov      ecx,[.checkRightSpaces]
       jmp      .PrintItLine
 
 
.PrintHelpTopicTextOut:
       popa
       ret
 
.leftSpaces dd 8
.rightSpaces dd 12 ;80-60-8
.checkRightSpaces dd 60
 
 
;EOF
