;menu.asm
 
INFO_MENU_TIPE = 0x0f1f1f1;⨯ �����⬠ ����
ACTION_MENU_TIPE = 0x01f1f1f;⨯ �����⬠ ����
 
;ᬥ饭�� �� ⠡���� 㪠��⥫�� ��뢠����� �� ���� ����
       _pCodsTbl = 0;
;ᬥ饭�� �� ⠡���� ⥪�⮢�� ��ப ᮮ⢥������� �㭪⠬ ����
       _pStrTbl = 4
       _cItems  = 8 ;�᫮ items �㭪⮢ ���� (�ᥣ�|total)
       _SizeStr = 12 ; size of 1 text string
       _PosW    = 16 ; position of text window
       _ActiveItem = 20 ; ⥪��� ��ப�
       _colorNotActivItem = 24 ;梥� ����⨢��� �㭪⮢ ����
       _colorActivItem = 28 ;梥� ��⨢��� �㭪⮢ ����
       _TipeOfMenu = 32;⨯ �����⬠ ����
 
 
DrawMenu:
;ptr to block of menu data
; mov bx,SimpleMenu ;temp$$$$$$$$$$$$$$
; mov bx,HelpMenu ;temp$$$$$$$$$$$$$$
 
       mov      [.pMenu],bx
 
       mov      ax,word _TipeOfMenu ;⨯ �����⬠ ����
       call     .GetData ;ret data from menu data block
       mov      [.tipeMenu],dword eax
 
 
       mov      ax,word _colorActivItem ;梥� ��⨢��� �㭪⮢ ����
       call     .GetData ;ret data from menu data block
       mov      [.colorActiv],byte al
 
       mov      ax,word _colorNotActivItem ;梥� not��⨢���
       call     .GetData
       mov      [.colorBack],byte al
 
.NextKey:
;       call     .DrawText
       cmp      [.tipeMenu],dword INFO_MENU_TIPE
       jnz      .notTipeInfo
       call     .DrawUserTxt ;����㥬 ⥪�� ���᪠��� ᮮ⢥�����騩 ⥪. �㭪
.notTipeInfo:
 
       call     .DrawText
 
       call     .GetKey
 
;-----cursor keys-------
       cmp      ah,4Bh
       je       .decx
 
       cmp      ah,4Dh
       je       .incx
 
       cmp      ah,48h
       je       .decy
 
       cmp      ah,50h
       je       .incy
;------
 
       cmp      ah,1;esc
       je       .close
 
       cmp      ah,14 ;bsp
       jz       .backspace
 
       cmp      ah,28 ;enter
       jz       .enter_line
 
cmp al,'9'
ja .setNextA
cmp al,'1'
jb .setNextA
  sub al,48
jmp .goto1
    .setNextA:
 
       call     .SetNextActiveItem
       jmp      .NextKey
 
.goto1:
shl eax,24
shr eax,24
 
call .SetActiveItem
       jmp      .NextKey
 
; ret
 
;-----cursor keys-------
.decy:
.decx:
 
call .SetPreActiveItem
       jmp      .NextKey
.incx:
.incy:
       call     .SetNextActiveItem
       jmp      .NextKey
 
;-----------------------
.close:
.backspace:
       ret
 
.enter_line:
       cmp      [.tipeMenu],dword INFO_MENU_TIPE
       jz      .notTipeInfoEnterKey
       call     .DrawUserTxt ;����㥬 ⥪�� ���᪠��� ᮮ⢥�����騩 ⥪. �㭪
   .notTipeInfoEnterKey:
 
       ret
 
.DrawUserTxt: ;����㥬 ⥪�� ���᪠��� ᮮ⢥�����騩 ⥪. �㭪
 
       mov      ax,word _ActiveItem
       call     .GetData ;ret data from menu data block
       shl      ax,1
       push     ax
 
       mov      ax,word _pCodsTbl
       call     .GetData ;ret data from menu data block
       pop      bx
       sub      ax,2 ;correct adress -2
       add      bx,ax
       call     word [bx]
 
       ret
 
.SetActiveItem:
      mov      edx,eax
 
       mov      ax,word _cItems ;�᫮ items �㭪⮢ ���� (�ᥣ�|total)
       call     .GetData ;ret data from menu data block
;       inc      eax
       cmp      edx,eax
       jbe      .okData3
ret
.okData3:
       mov      ax,word _ActiveItem ; ⥪��� ��ப�
       call     .PutData ;ret data from menu data block
       ret
 
 
 
 
.SetNextActiveItem:
;------
       mov      ax,word _ActiveItem ; ⥪��� ��ப�
       call     .GetData ;ret data from menu data block
;eax= active line
;------
       inc      eax
       mov      edx,eax
 
       mov      ax,word _cItems ;�᫮ items �㭪⮢ ���� (�ᥣ�|total)
       call     .GetData ;ret data from menu data block
       inc      eax
       cmp      eax,edx
       jnz      .okData
       mov      edx,dword 1
.okData:
       mov      ax,word _ActiveItem ; ⥪��� ��ப�
       call     .PutData ;ret data from menu data block
       ret
 
 
.SetPreActiveItem:
;------
       mov      ax,word _ActiveItem ; ⥪��� ��ப�
       call     .GetData ;ret data from menu data block
;eax= active line
;------
       dec      eax
       jnz      .okData2
       mov      ax,word _cItems ;�᫮ items �㭪⮢ ���� (�ᥣ�|total)
       call     .GetData ;ret data from menu data block
.okData2:
mov edx,eax
       mov      ax,word _ActiveItem ; ⥪��� ��ப�
       call     .PutData ;ret data from menu data block
       ret
 
 
.GetKey:
 
mov word ax,[fs:0+041ah]
mov word bx,[fs:0+041ch]
.wait_kbd:
       call     Clock ;inc\clock.asm
 
       hlt
cmp word bx,[fs:0+041ch]
       jz       .wait_kbd
mov word ax,[fs:0+bx+0400h]
mov word bx,[fs:0+041ch]
mov word [fs:0+041ah],bx
       ret
 
;------
.DrawText:
       call     .PutLinesBlockVesa
;esi = ���ᨢ ᨬ����� � ���ਡ�⮢ 80 �� 25 ��ப
       mov      esi,dword [VideoBufMemory]
       call     DrawPage ;�뢮� ���ᥫ��
       ret
 
 
.PutLinesBlockVesa:
 
       mov      ax, word _cItems;�᫮ items �㭪⮢ ���� (�ᥣ�|t
       call     .GetData ;ret data from menu data block
       mov      cx, ax
 
 
       mov      ax,word _pStrTbl
       call     .GetData
       mov      esi,eax
 
;si = ptr, cx = total lines of menu
       mov      ax,word _PosW
       call     .GetData
       mov      edx,eax
       mov      edi,dword [VideoBufMemory]
       add      edi,edx
 
       mov      ax,word _ActiveItem ; ⥪��� ��ப�
       call     .GetData
;eax= active line
       mov      bl,al
 
.vs0: ;--------------------------(~2)
       mov      ah,[.colorBack]
       dec      bl ;bl = counter for active item
       jnz      .vs1
       mov      ah,[.colorActiv] ; do it
 
.vs1: ;-------------------------- (~1)
 
       mov      al,[esi]
       inc      esi
 
       cmp      al,0
       jz       .vs2
       mov      word [edi],ax
 
       add      edi,2
       jmp      .vs1 ;------------------(1)
.vs2:
       add      edx,160
       mov      edi,dword [VideoBufMemory]
       add      edi,edx ;vesa add
 
       dec      cx
       jnz      .vs0 ;-----------------(2)
 
       ret
 
;------
 
.GetData: ;ax= adr in block
       push     bx
       mov      bx,[.pMenu]
       add      bx,ax
       mov      eax,dword [bx]
       pop      bx
       ret      ;return eax
 
.PutData: ; ax= adr in block , edx = value
       push     bx
       mov      bx,[.pMenu]
       add      bx,ax
       mov      dword [bx],edx
       pop      bx
       ret
 
virtual at TmpData
 
.colorBack db 0 ;color for text of menu
.colorActiv db 0 ;color for active line of menu
.pMenu dw 0
.tipeMenu dd 0
 
end virtual
 
;EOF
