;bitmap.asm
 
;x86 cpu unreal mode cod
 
macro AddEaxLi {
add eax,dword [Lighit]
}
 
 
 ADD_LIGHIT = 0x0f0f0f;0x0101010
 DEF_LIGHIT = 0x0404040;0x0101010
 
 COM_COLOR32 = 0x03a3a3a
 
 
        BACKCOLOR = 0x0;0x028a8f8;fffff
 
;        BACKCOLOR = 0x01;028a8f8;fffff
;       ���_����_��������_����� = 0x0ffcc00
;       ���_����_����� = 0x0c8c8c8
;       ���_����_��������� = 0x07898c8
;       ���_����_���������_������� = 0x0bdc7d6
;       ���_����_������� = 0x0008080
;       ���_����_��������_������� = 0x074744a
;       ���_����_������_������� = 0x0c0dcc0
;       ���_����_������������������ = 0x0eec585
;       ���_����_�����_������� = 0x028a8f8
 
 
       SELECT_COLOR = 0x00101010;0x0777878;0x01111
 
 
 
 
 
;       ������_�������� = 8
;       �����_�������� = 8
;       ������_�������_�����_������ = 8
       ������_������ = 800*4*10
       ������_����� = 8
       ������_����� = 0;80*4;\
       ������_������ = 0;79*4 ;80*4;/
       �����������_�������� = 800*14*4
       �������������_�������� = 8 ;4
 
 
       ����_������� = 0x04444;0x03333;535353
       ����_���� = BACKCOLOR
 
;esi = ���ᨢ ᨬ����� � ���ਡ�⮢ 80 �� 25 ��ப
;edi = font
;�ᯮ��㥬 ���� 8x8
 
    tempflag dd 0 ; ]]]]]]]]]
 
 
DrawVideoPage:
 
cmp   [tempflag],dword 0  ; ]]]]]]]]
jnz .fffff ;]]]]]]]]]
      call     DrawBack  ;]]]]]]]]]
mov   [tempflag],dword 1   ;]]]]]]]]]
.fffff:  ; ]]]]]]]]]
 
       call     DrawCursorY
       call     DrawCursorX
 
       call     .Init
 
       mov      ebx,dword [VideoLinear]
       add      ebx,dword ������_������
 
       mov      [.saveEbx],dword ebx ;��砫쭮� ���祭��
 
       mov      esi,dword [.ArrayChrs80x25]
       mov      [.saveEsi],dword esi ;��砫쭮� ���祭��
 
       mov      cx,25 ;���-�� ��ப �� ��࠭�
 
.mainCycle:
       push     cx
       call     .GetAttr ;��࠭塞 ���ਡ��� � ���� �⤥�쭮
       call     .GetStr ;� ���� ᨬ����� �८�ࠧ㥬 � ���-�����
       call     .Draw
       pop      cx
       dec      cx
       jnz      .mainCycle
 
       ret
 
 
 
.Draw:
; ����� ebx - 㪠��⥫� �� �����-������
       mov      ebx,dword [.saveEbx]
       add      ebx,dword �����������_��������
 
macro put_pix { mov [fs:ebx],dword eax }
 
       mov      esi,edi
       mov      ax,word 8 ;�ᥣ� �㦭� ���ᮢ��� 8 �����
 
.nextLine:
       add      ebx,dword ������_�����
 
       mov      edi,20 ;edi - ����� �ப� ���ᥫ�� � dword-ax
       push     ax
 
       xor      eax,eax
       mov      dword [.�����፠����騩���ਡ��],eax
       call     .GetNextColor ;���樠������� ��६���� .CharColor .FonColor
 
.nextDD:
       mov      eax,dword [esi]
       add      esi,dword 4
 
       mov      edx,eax
       mov      ecx,32
.DrawDrord:
       mov      eax,edx
       shl      eax,31
       test     eax,eax
       jz       .zeroPix
       mov      eax,dword [.CharColor]
AddEaxLi
 
       put_pix
       jmp      .okk
.zeroPix:
       mov      eax,dword [.FonColor]
 
       put_pix
.okk:
 
       add      ebx,4
       shr      edx,1
 
 ;;
       cmp      ecx,dword 32-7
       jnz      .AAffff
       add      ebx,dword �������������_��������
       call     .GetNextColor
.AAffff:
       cmp      ecx,dword 17
       jnz      .AAffff2
       add      ebx,dword �������������_��������
       call     .GetNextColor
.AAffff2:
       cmp      ecx,dword 9
       jnz      .AAffff23
       add      ebx,dword �������������_��������
       call     .GetNextColor
.AAffff23:
       cmp      ecx,dword 1
       jnz      .AAffff231
       add      ebx,dword �������������_��������
       call     .GetNextColor
.AAffff231:
 ;;
 
       dec      ecx
       jnz      .DrawDrord
       dec      edi
       jnz      .nextDD
 
       add      ebx,dword ������_������
 
       pop      ax
       dec      ax
       jnz      .nextLine
 
       mov      dword [.saveEbx],ebx
 
       ret
 
 
.GetNextColor: ;������ ���ਡ��� � ��।���� 梥� ���ᥫ��
 
       mov      eax, dword [.�����፠����騩���ਡ��]
       cmp      eax,dword 80
       jz       .�⮣��멏��GNC
 
       mov      [.tmpEsi],dword esi
       mov      eax,dword [.�����፠����騩���ਡ��]
       inc      eax
       mov      [.�����፠����騩���ਡ��],dword eax
       dec      eax
       mov      esi,dword [.tmpBufForStringAttrbs]
       add      esi,eax
 
;�� 㬮�砭�� ���� 梥� 䮭�
       mov      eax,dword ����_����
       mov      [.FonColor],dword eax
 
       xor      eax,eax
       mov      al,byte [esi]
       cmp      al,7
       jnz      .not7
       mov      eax,dword ����_�������
AddEaxLi
 
       mov      [.CharColor],dword eax
       mov      esi,dword [.tmpEsi]
       ret
 
.not7:
       cmp      al,23 ;23 - �� �ਧ���-��ਡ�� �뤥����� ⥪��
       jnz      .not23
 
       mov      eax,dword ����_�������
;mov eax,dword SELECT_COLOR
AddEaxLi
 
       mov      [.CharColor],dword eax
;       mov      eax,dword 0x0111000
mov eax,dword SELECT_COLOR
 
AddEaxLi
 
       mov      [.FonColor],dword eax
       mov      esi,dword [.tmpEsi]
ret
 
.not23:
 
       cmp      al,8 ;8 - �� �ਧ���-��ਡ�� ���������஢������ ⥪��
       jnz      .not8
 
       mov      eax,dword COM_COLOR32;0x01a1a1a;02000;����_�������+0x0ff
AddEaxLi
 
       mov      [.CharColor],dword eax
 
       mov      esi,dword [.tmpEsi]
       ret
 
 
.not8:
 
       cmp      al,byte COLOR_ASCII_TXT
       jnz      .notCOLOR_ASCII_TXT
       mov      eax,dword 0x01113000;����_�������+0x0ff
AddEaxLi
 
       mov      [.CharColor],dword eax
       mov      esi,dword [.tmpEsi]
       ret
 
 
.notCOLOR_ASCII_TXT:
       mov      eax,dword 0x0333000;����_�������+0x0ff
AddEaxLi
 
       mov      [.CharColor],dword eax
       mov      esi,dword [.tmpEsi]
       ret
 
.�⮣��멏��GNC:
       xor      eax,eax
       mov      dword [.�����፠����騩���ਡ��],eax
       ret
 
.�����፠����騩���ਡ�� dd 0
.tmpEsi dd 0
 
;end GetNextColor
 
 
;============
.GetAttr:
       mov      ecx,80
       mov      ebx,dword [.tmpBufForStringAttrbs]
       mov      esi,dword [.saveEsi]
 
 
.fl1:
       mov      al,byte [esi+1] ;⥯��� ᮡ�ࠥ� 梥�
       mov      [ebx],byte al
       inc      ebx
       inc      esi ;2
       inc      esi ;2
       dec      ecx
       jnz      .fl1
       mov      esi,dword [.saveEsi]
 
       ret
 
;===========
.GetStr:
       mov      ecx,80
       mov      ebx,dword [.tmpBufForStringChars]
       mov      esi,dword [.saveEsi]
 
 
.l1:
       mov      al,byte [esi]
       mov      [ebx],byte al
       inc      ebx
       inc      esi ;2
       inc      esi ;2
       inc      edi
       dec      ecx
       jnz      .l1
 
;save esi
       mov      [.saveEsi],dword esi
 
       mov      esi,dword [.tmpBufForStringChars]
       mov      edi,dword [.tmpBufForArrayPixs]
       mov      ecx,80
.l2:
       xor      eax,eax
       mov      al,byte [esi]
       imul     eax,8
       mov      ebx,dword [.Font]
       add      ebx,eax
;⥯��� � ebx (ptr) ��⮢�� ���� ᨬ����
 
;       repeat   8
;       mov      al,[ebx]
;       inc      ebx
;       mov      [edi],byte al
;       inc      edi
;       end      repeat
 
       repeat   2
       mov      eax,dword [ebx]
       mov      [edi],dword eax
       add      ebx,4
       add      edi,4
       end      repeat
 
 
       inc      esi
       dec      ecx
       jnz      .l2
 
       call     .Convert
 
       ret
 
 
;-----------
.Convert:
;�८�ࠧ㥬 �।� ����ࠦ���� ᨬ����� � ���� - 楫쭮� ��-��� ��ப�
       mov      edx,8
       mov      esi,dword [.tmpBufForArrayPixs]
       mov      eax,esi
       add      eax,80*8
       mov      edi,eax
       add      edi,edx
.DFF:
;inc dword [.tmpBufForArrayPixs]
       mov      esi,dword [.tmpBufForArrayPixs]
       mov      ecx,80
       inc      dword [.tmpBufForArrayPixs]
 
.MovL:
       xor      eax,eax
       mov      al,[esi]
 
;------------���塞 ���⠬� ���� - ��ઠ��
       push     dx
       mov      dl,1
       call     .Cycle
       mov      dl,010b
       call     .Cycle
       mov      dl,0100b
       call     .Cycle
       mov      dl,01000b
       call     .Cycle
       mov      dl,010000b
       call     .Cycle
       mov      dl,0100000b
       call     .Cycle
       mov      dl,01000000b
       call     .Cycle
       mov      dl,010000000b
       call     .Cycle
       jmp      .ok
 
.Cycle:
       rol      al,1
       jnc      .not1
       add      ah,dl
.not1:
       ret
 
.ok:
       pop      dx
;-----------------------------------------
 
       mov      [edi],ah ;al|ah = ��ઠ�쭮 ����� ���冷� ��⮢
       add      esi,8
       inc      edi
       dec      ecx
       jnz      .MovL
       dec      edx
       jnz      .DFF
 
       mov      eax,dword [.tmpBufForArrayPixs]
       add      eax,80*8
       mov      edi,eax
 
       ret
 
.Init:
;�����⮢��
       mov      [.ArrayChrs80x25], dword esi
       mov      [.Font], dword edi
       mov      eax,dword [StartMemory]
       mov      edx,dword [SizeTextFormatted]
       add      eax,edx
       add      eax,dword 1000h
 
       mov      dword [.tmpBufForStringChars],eax
       add      eax,dword 80
       mov      dword [.tmpBufForStringAttrbs],eax
       add      eax,dword 80
 
       mov      dword [.tmpBufForArrayPixs],eax
 
       xor      eax,eax
       mov      [.x],dword eax
       mov      [.y],dword eax
 
       ret
 
.x dd 0
.y dd 0
.ArrayChrs80x25 dd 0
.Font dd 0
 
.tmpBufForStringChars dd 0
.tmpBufForStringAttrbs dd 0
.tmpBufForArrayPixs dd 0
 
.saveEsi dd 0
.saveEbx dd 0
 
.CharColor dd ����_�������
.FonColor dd ����_����
Lighit dd DEF_LIGHIT ;global variable - use in emd.asm (F8 key)
 
 
;EOF