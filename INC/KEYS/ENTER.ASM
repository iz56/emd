;enter.asm
 
 
;��ࠡ��뢠�� ����⨥ enter
EnterLine:
 
;��頥� ������ ��᫥ ���� ⥪�� (�㦭� �᫨ ���� ⥪�� ����� ��࠭�)
       call     EraseMemory ;inc\erase.asm
 
;�஢��塞 ����稥 ᢮������
;����� � ������� ����ᮬ (����������� ��ࠡ���� ⥪�� ��� ��࠭����)
       mov      eax,[SizeTextFormatted] ;⥪�騩 ࠧ��� ��ᦠ⮣� ⥪��
       shl      eax,1 ;(㬭����� �� 2)
       add      eax,dword CHAR_ON_LINE*2
       mov      ebx,eax
       add      ebx,dword [StartMemory]
 
       cmp      ebx,dword [EndMemory]
       jae      .close ;���� �����
 
;��࠭塞 ��� ���� shift+enter
       mov      al,[x]
       mov      [.tmpX],al
 
;�᫨ ����� ⥪��
       mov      ebx,[IndexPageActive]
       xor      eax,eax
       mov      al,[y]
       inc      al
       imul     ax,CHAR_ON_LINE
       add      ebx,eax
       cmp      [SizeTextFormatted],ebx
       jbe      .end_of_text
;�।��� � ��砫�
       mov      ebx,[StartMemory] ;��砫� ⥪��
       add      ebx,[IndexPageActive] ;⥪��� ��࠭��
       xor      eax,eax ;����塞 eax
       inc      [y]
       mov      al,[y] ;al - ᫥����� ��ப�
       cmp      al,LINES_ON_SCR
       jz       .end_of_page
 
.ok_page:
       imul     ax,CHAR_ON_LINE
       add      ebx,eax ;ebx - ���� ��⠢�� ���⮩ ��ப�
       mov      edi,[SizeTextFormatted]
       add      edi,[StartMemory]
       mov      esi,edi
       add      edi,CHAR_ON_LINE
 
.shift_text80:
       mov      al,[esi]
       mov      byte [esi],32
       mov      [edi],al
       dec      esi
       dec      edi
       cmp      esi,ebx
       jae      .shift_text80;-------------------
 
       add      dword [SizeTextFormatted],CHAR_ON_LINE
 
       mov      byte [x],0;��ॢ���� ����� � ��砫�
       jmp      .pasteLineComplete
 
;����� �㦭� ��६���� ��࠭ ����
.end_of_page:
       mov      al,24
       mov      [y],al
       inc      al
       add      dword [IndexPageActive],CHAR_ON_LINE
       jmp      .ok_page
 
.end_of_text:
 
       add      dword [SizeTextFormatted],CHAR_ON_LINE
 
       mov      byte [x],0 ;��ॢ���� ����� � ��砫� ��ப�
       inc      [y]
       cmp      [y],LINES_ON_SCR
       jnz      .pasteLineComplete
       add      dword [IndexPageActive],CHAR_ON_LINE
       mov      [y],24
; jmp .pasteLineComplete
 
 
.pasteLineComplete:
; ����� ������ shift ?
       cmp      byte [FlagKeyShift],1
       jz       .EnterShift_CutLine
 
       ret      ; ࠡ�� ᤥ���� ��� �����筮�� Enter
 
 
;shift+enter - ��ࠡ��뢠��
.EnterShift_CutLine:
 
;㧭��� �ࠢ� ��� ���� shift
;䫠� ���ﭨ� ���������� (BIOS data area)
mov al,byte [fs:0+00417h]
       shl      al,7
       cmp      al,0
       jz       .leftShiftPressed
 
 
;����� ��ࠡ��뢠�� �ࠢ� shift+enter
       xor      eax,eax
       mov      al,[.tmpX]
       cmp      al,0
       jnz      .go
       ret
.go:
       push     ax ;ax=���� ࠧ१� ��ப�
 
       mov      ebx,[StartMemory] ;��砫� ⥪��
       add      ebx,[IndexPageActive] ;⥪��� ��࠭��
 
       xor      eax,eax
       mov      al,[y]
 
       imul     ax,CHAR_ON_LINE
       add      ebx,eax ;ebx - ����� ��ப�
       mov      eax,ebx
 
 
       mov      edi,eax
       mov      [.tmp_edi],dword edi
       sub      eax,dword CHAR_ON_LINE
       mov      esi,eax
       pop      cx
       mov      bl,20h
       mov      dx, word CHAR_ON_LINE
 
.copyCharsDown:
       mov      al,[esi]
       mov      [esi],bl
       mov      [edi],al
       inc      esi
       inc      edi
       dec      dx
       dec      cx
       jnz      .copyCharsDown
       mov      cx,dx
 
       mov      eax,dword [.tmp_edi]
       sub      eax, dword CHAR_ON_LINE ;���᫨� ��⠢訥�� ᨬ���� - ������⢮
       mov      edi,eax
       mov      dx, word CHAR_ON_LINE
 
.move0:
       mov      al,[esi]
       mov      [edi],al
       inc      esi
       inc      edi
       dec      dx
       dec      cx
       jnz      .move0
 
       mov      cx,dx
       mov      al,32 ;�������� ��ப� �஡�����
.move32:
       mov      [edi],al
       inc      edi
       dec      cx
       jnz      .move32
 
       dec      [y]
 
       ret      ; ࠡ�� ᤥ���� ��� Enter+Shift(�ࠢ�)
 
 
.tmp_edi dd 0
 
.leftShiftPressed:
 
       mov      ebx,[StartMemory] ;��砫� ⥪��
       add      ebx,[IndexPageActive] ;⥪��� ��࠭��
 
       xor      eax,eax
       mov      al,[y]
 
       imul     ax,CHAR_ON_LINE
       add      ebx,eax ;ebx - ����� ��ப�
       mov      eax,ebx
 
       mov      edi,eax
       sub      eax,dword CHAR_ON_LINE
 
       xor      ebx,ebx
       mov      bl,[.tmpX]
       add      eax,ebx
 
       mov      esi,eax
       mov      ecx,dword CHAR_ON_LINE
       sub      ecx,ebx
.copyLine:
       mov      al,[esi]
       mov      [esi],byte 32
       mov      [edi],al
       inc      esi
       inc      edi
       dec      ecx
       jnz      .copyLine
 
       ret      ; ࠡ�� ᤥ���� ��� Enter+Shift(����)
 
.tmpX db 0
 
 
.close:
;�᫨ ����� ����
       sub      dword [SizeTextFormatted],CHAR_ON_LINE
 
 
;���⪠ ��࠭�
       mov      eax,07200720h
       mov      edi,dword 4000
.cls:
mov dword [gs:0+di],eax
 
       sub      edi,dword 4
       jnz      .cls
mov dword [gs:0+di],eax
 
;------------------cursor------------------
       mov      ah,02h ;- bios servis
       mov      bh,0
       mov      dh,24
       mov      dl,0
       int      10h
;------------------------------------------
 
       mov      si,.msgErrorMemory
       mov di,buf
       call     OutTextRadix50RealMode
 
 biosKBDwait ;inc\macro.asm
       ret ;�뢥�襭�� � �뢮��� ᮮ�饭�� �訡��
 
.msgErrorMemory:
db 022h ,022h ,090h ,060h ,0ech ,059h ,00dh ,002h ,0aah ,053h ,078h ,0a0h
 
 
 
;EOF