;emd.asm
;v1.70 (size 21925 bytes) [25/11/2014]
 
;x86 cpu real & unreal mode cod
;/for fasm (flat assembler version 1.20)/
 
;macros files
       include  'inc\const.asm'
       include  'inc\macro.asm'
       include  'inc\video.asm'
 
       org      100h
       use16
 
;x86 cod start here
       push     cs
       pop      ds
 
       SIZE_REAL_OF_FONT=2048
       macro    unpackFont {
;cx=size
;si=ptr of arh
;di=ptr to unpack data free mem
;bx=ptr to temp work buff
       mov      si,word FontPack
       mov      cx,word font_size
       mov      di,word Font
       mov      bx,word buf
       call     LZW_unpack
       }
 
       call     IntroDos ;intro.asm checks
 
       call     DetectMemory ;inc/detectm.asm
       cmp      dword eax,MEMORY_MIN
       jb       quit
 
       mov      [EndMemory],dword eax
 
       cld
       call     FlatrmInit
 
;flat real mode CPU cod
 
;����塞 ࠧ��� ����㯭�� �����
       call     MemChk ;inc/memch.asm
 
;scan command line for a file name
       call     ScanCmd ;inc/scancmd.asm
       jc       quit
 
       mov      [PtrNameFileText],dx
 
;create file
       mov      ah,5bh
       mov      cx,0
       int      21h
       jc       .OpenFile
 
       mov      bx,ax
 
;close file
       mov      ah,3eh
       int      21h ;dos service
 
;delete file
       mov      dx,word [PtrNameFileText]
       mov      ah,41h
       int      21h
; jc .ErrorDeleteFile
       jc       quit
 
       mov      [FlagNewFile],byte 1
       jmp      new_file
 
.OpenFile:
 
       mov      dx, word [PtrNameFileText];㪠��⥫� �� ��� 䠩��
       mov      edi, dword [StartMemory];㪠��⥫� - �㤠 ����㦠��
 
       call     ReadOperation ;read.asm
 
;eax = error cod|zero if not error
       mov      [CodError],dword eax ;����頥� ��� �訡��
       test     eax,eax
       jnz      quit
 
       cmp      eax,dword 0
       jnz      quit
 
       mov      [SizeFile],dword ecx
 
       call     DisplayReadingBytes ;inc\drbytes.asm
       call     WaitPressAnyKey
 
;��ࠡ��뢠�� ⥪��
;ࠧ���稢��� � ���ᨢ ��ப 䨪�஢����� ����� 80 ᨬ�����
       call     FormText ;inc\form.asm
 
;print welcom screen
drawInfoBox:
       call     Welcom ;inc\welcom.asm
       nop      ;need for "/f"
       nop
;only for debug - you can delete this line
       call     DebugCheckSizeFormTxt ;checkf.asm
       jmp      intro_0
 
new_file:
       xor      eax,eax
       mov      [SizeTextFormatted],eax
 
intro_0:
 
;��頥� ������ ��᫥ ���� ⥪�� (�㦭� �᫨ ���� ⥪�� ����� ��࠭�)
       call     EraseMemory ;inc\erase.asm
 
       unpackFont
 
;set fs gs
       mov      ax,SEG_VIDEO_MEMORY
       mov      gs,ax
       xor      ax,ax
       mov      fs,ax
;fs = 0, gs = 0x0b800
 
;�᫨ � ����� 䠩�� .asm,0
       mov      si,[PtrNameFileText]
.l1:
       mov      al,[si]
       cmp      al,'.'
       jz       .checkAsm
       inc      si
       cmp      al,0
       jnz      .l1
       jmp      .notAsmText
 
.AsmTxtStr:
db 'asm',0
 
.checkAsm:
       inc      si
       mov      eax,dword [si]
       cmp      eax, dword [.AsmTxtStr] ;�ࠢ������ � ���७���
       jnz      .notAsmText
 
;��⠭�������� 䫠� ��� ����祭�� ���ᢥ⪨ ᨭ⠪��
       mov      byte [FlagModeColor],1
 
.notAsmText:
 
;+
;����㦠�� ������ �����
;�᫨ ࠧ��� �ଠ�஢������ ⥪��
;ᮢ������ � ⥬ ,�� �� � �����
;fs=0
 
mov dword eax,[fs:0+04f0h]
       cmp      eax,dword [SizeTextFormatted]
       jnz      not_set_x_y
mov byte al,[fs:0+04f0h+4]
       mov      [x],byte al
mov byte al,[fs:0+04f0h+5]
       mov      [y],byte al
mov dword eax,[fs:0+04f0h+6]
       mov      [IndexPageActive],dword eax
not_set_x_y:
; -
 
 
;�᫨ ⥪�� ��� ᮧ���� ������ ��ப�
       cmp      dword [SizeTextFormatted],0
       jnz      NextKey
 
       mov      ebx,[StartMemory]
       mov      eax,0x020202020
       mov      cx,CHAR_ON_LINE/4
.l1:
       mov      [ebx],dword eax
       add      ebx,dword 4
       dec      cx
       jnz      .l1
       mov      dword [SizeTextFormatted],CHAR_ON_LINE
 
 
 
; START - main program loop - 横� ।����
NextKey:
 
;call StartProf
       redraw
       colored
;call EndProf
NoRedraw:
 
 
       mov      esi,dword [VideoBufMemory]
       call     DrawPage
 
       cmp      [VideoMode],dword 3
       jnz      .vesa
 
;------------------cursor---------
       mov      bx,0
       mov      bl,[x]
       xor      eax,eax
       mov      al,[y]
       imul     ax,CHAR_ON_LINE
       add      ax,bx
       mov      bx,ax
       mov      al, 0x0E
       mov      ah, bh
       mov      dx, 0x3D4
       out      dx, ax
       inc      ax
       mov      ah, bl
       out      dx, ax
 
.vesa: ;����� � ��. ०. ��㥬 � ��. ����
 
;------------------cursor------------------
; mov ah,02h - bios servis ��⠢���� ��� ᮢ���⨬���
; mov bh,0
; mov dh,[y]
; mov dl,[x]
; int 10h
;------------------------------------------
 
NoRedraw_0:
       cmp      byte [Replay.f_OldKey],0
       jz       .l1
; dec byte [Replay.f_OldKey]
; jc .l1
       mov      ax,[Replay.OldKey]
       mov      byte [Replay.f_OldKey],0
       jmp      key_repeat
.l1:
 
       call     AutoCompletePushChar ;inc/auto/auto.asm
 
;------------getkey--------------\
;���頥��� � ������ ������ BIOS
;�⠥� ���� ����������
;������� ����⨥ ������
       mov      dword [CountWait],0
 
 
       HIDE_CURSOR_TIME = 100
 
;-hide-cursor--1\
       mov      dword [F_waitHideCursor],1
       mov      dword [waitHideCursor],HIDE_CURSOR_TIME
;-hide-cursor--1/
 
 
       xor      eax,eax
       mov      ebx,eax
; mov fs,ax
mov word ax,[fs:0+041ah]
mov word bx,[fs:0+041ch]
wait_kbd:
 
;-hide-cursor--2\
       dec      dword [waitHideCursor]
       cmp      dword [waitHideCursor],0
       jnz      .noHideCursor
 
       cmp      dword [F_waitHideCursor],0
       jz       .noHideCursor
       mov      dword [F_waitHideCursor],0
 
;hide cursor
       mov      ah,02h ;- bios servis
       mov      bh,0
       mov      dh,25
       mov      dl,25
       int      10h
 
.noHideCursor:
;-hide-cursor--2/
 
 
;<clock>
; cmp [VideoMode],dword 3
; jnz .noClock
 
       cmp      [y],byte 0 ;not draw clock if cursor in her area
       jz       .l11
 
       call     Clock ;inc\clock.asm
       jmp      .noClock
.l11:
       cmp      [x],byte 70
       ja       .noClock
       call     Clock ;inc\clock.asm
 
.noClock:
;</clock>
hlt ;���㦠�� ������ :)
; nop
       inc      dword [CountWait]
cmp word bx,[fs:0+041ch]
       jz       wait_kbd
 
NoWaitKBD:
;�⠫쭮 ��⠥� ������
       inc      dword [CountPressKbdTotal]
 
mov word ax,[fs:0+bx+0400h]
 
       cmp      dword [CountWait],REPEAT_X;2;4
       ja       .l1
;-------
       cmp      ax,[Replay.OldKey]
       jnz      .l1
 
 
       inc      byte [Replay.count]
       cmp      byte [Replay.count],SPEEDREPEAT
       jnz      .l3
 
 
       mov      byte [Replay.f_OldKey],1
       mov      byte [Replay.count],0
 
       jmp      .l3
 
.l2:
;-------
.l1:
       mov      [Replay.OldKey],ax
       mov      byte [Replay.f_OldKey],0
       mov      byte [Replay.count],0
.l3:
 
mov bx,word [fs:0+041ch]
mov [fs:0+041ah],word bx
 
; xor ax,ax - bios servis
; int 16h
 
 
key_repeat:
 
;+
;����� �஢��塞 ����⨥ ������ Shift
;� ��⠭�������� FlagKeyShift
       mov      dx,ax ;push ax
       mov      [FlagKeyShift],byte 0
;䫠� ���ﭨ� ���������� (BIOS data area)
mov al,byte [fs:0+00417h]
       shl      al,6
       cmp      al,0
       jz       .notShiftPressed
       mov      [FlagKeyShift],byte 1 ; 1 = pressed
.notShiftPressed:
       mov      ax,dx ; pop ax
;-
 
       mov      dx,word [FlagKeyShift]
; mov dh,[FlagTextSelect] - ��६���� ��� �� ��㣮�
       cmp      dx,0
       jz       .ldd2
 
       push     ax
       call     SelectBlockText ;inc\select.asm
       pop      ax
 
.ldd2:
 
       call     AutoComplete ;inc\auto\auto.asm
 
 
;here handler kbd keys
 
       macro    VariantJmp { ;variant #1
       push     bx
 
       xor      bx,bx
       mov      bl,ah
       shl      bl,1
       add      bx,word .KeyTable
       mov      dx, word [bx]
 
       mov      word [.addrJmp],dx
       pop      bx
       jmp      word [.addrJmp]
.addrJmp dw 0
       }
 
       macro    VariantCall { ;variant #2
       push     bx
       xor      bx,bx
       mov      bl,ah
       shl      bl,1
       add      bx,word .KeyTable
       mov      dx, word [bx]
       pop      bx
       call     .CallTempLabel
.CallTempLabel:
       pop      cx ;destroy cx!
       push     dx
       ret      ;''''''
       }
 
       VariantCall ;it is small then jmp variant
 
.KeyTable:
dw CharAddText
dw close ;#1 ESC
dw CharAddText ;2
dw CharAddText ;3
dw CharAddText ;4
dw CharAddText ;5
dw CharAddText ;6
dw CharAddText ;7
dw CharAddText ;8
dw CharAddText ;9
dw CharAddText ;10
 
dw CharAddText ;11
dw CharAddText
dw CharAddText
dw backspace ;--- ;14
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText ;20
 
dw CharAddText ;21
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw enter_line ;--- ;28
dw CharAddText
dw CharAddText ;30
 
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText ;40
 
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText ;50
 
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw KeyHelpMenu ;--- ;59
dw SaveTextAndExit ;--- ;60
 
dw F3GotoLabel ;--- ;61
dw CharAddText
dw actionEnterTextBuffer ;--- ;63
dw CharAddText
dw KeySpecMenu ;--- ;65
dw F8VideoMode ;--- ;66
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText ;70
 
dw home ;--- ;71
dw decy ;--- ;72
dw page_up ;--- ;73
dw CharAddText
dw decx ;--- ;75
dw CharAddText
dw incx ;--- ;77
dw CharAddText
dw end_c ;--- ;79
dw incy ;--- ;80
 
dw page_down ;--- ;81
dw KeyInsert ;--- ;82
dw key_del ;--- ;83
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText ;90
 
dw F8VideoMode ;--- ;91
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText ;100
 
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText ;110
 
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText ;120
 
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText
dw CharAddText ;130
 
;-------------------------------+++
 
CharAddText: ;label for /inc/auto/auto.asm direct jmp to here
       inc      dword [CountPressKbdChar]
; al = char
 
       push     ax
       mov      ebx,[IndexPageActive]
       add      ebx,[StartMemory]
       xor      eax,eax
       mov      al,[y]
       imul     ax,CHAR_ON_LINE
       add      ebx,eax
       xor      eax,eax
       mov      al,[x]
       add      ebx,eax
       pop      ax
 
       cmp      byte [InsertKeyStatus],0
       jz       EnterChar
 
       mov      [ebx],al
 
       redraw
       colored
 
       jmp      incx
 
EnterChar:
 
       mov      cl,[x]
.l1:
       mov      ah,[ebx]
       mov      [ebx],al
       mov      al,ah
       inc      ebx
       inc      cl
 
       cmp      cl,CHAR_ON_LINE
       jnz      .l1
 
       redraw
       colored
       jmp      incx
 
 
;---------------------------------------------------------------------------
 
set_FlagModeColor:
       mov      byte [FlagModeColor],1
       jmp      NextKey
 
 
;---------------------------------------------------------------------------
;��४���⥫� ��⠢�� - ������ �����
       KEY_INSERT_ON = 1
       KEY_INSERT_OFF = 0
KeyInsert:
       cmp      byte [InsertKeyStatus],KEY_INSERT_OFF
       jz       .setON
       mov      [InsertKeyStatus],KEY_INSERT_OFF
       jmp      NoRedraw_0
.setON:
       mov      byte [InsertKeyStatus],KEY_INSERT_ON
       jmp      NoRedraw_0
 
InsertKeyStatus db 0 ;0=enter 1=insert
 
;---------------------------------------------------------------------------
KeySpecMenu: ;F7
 
       mov      bx, F7Menu
       call     DrawMenu ;���⢠ �䠪�ਭ��
 
       jmp      NextKey
 
 
 
F8VideoMode:
;��४��祭�� ����� ��. � ⥪�� �����-०����
 
       mov      al,[FlagKeyShift]
       test     al,al
       jz       .notShift
 
       mov      eax,dword [Lighit]
       cmp      eax,dword DEF_LIGHIT
       jz       .Zero
 
       mov      eax,dword DEF_LIGHIT
       mov      dword [Lighit],dword eax
       jmp      NextKey
.Zero:
       mov      eax,dword ADD_LIGHIT;0x0101010
       mov      dword [Lighit],dword eax
       jmp      NextKey
 
;mov eax,dword [Lighit]
;sub eax,dword 0x00010101
;mov dword [Lighit],dword eax
 
 
.notShift:
 
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
       cmp      [VideoMode],dword 3
       jnz      .vesa
       mov      [VideoMode],dword 1
       jmp      NextKey
.vesa:
       mov      [VideoMode],dword 3
       mov      [VideoLinear], dword 0
       call     SetTxtVMode ;vesa16.asm
       jmp      NextKey
;----------------------------------------------------------------|
 
;���� �����
KeyHelpMenu:
       mov      bx,HelpMenu ;����� ���� �ᮢ���
       call     DrawMenu
       jmp      NextKey
 
 
;---------
F3GotoLabel:
       call     GotoLabel ;inc\goto.asm
       jmp      NextKey
;---------
 
;---------------------------------------------------------------------------
 
 
;��⠢�塞 ⥪�� �� text_buf
actionEnterTextBuffer:
       call     EnterTextBuffer ;inc\keys\f5.asm
       jc       close
       jmp      NextKey
 
 
;---------------------------------------------------------------------------
;��ࠡ��뢠�� ����⨥ ������ ��६�饭�� �����
;���塞 ��६���� x,y
decx:
       mov      al,[x]
       cmp      al,0
       jz       NoRedraw
       dec      [x]
       jmp      NoRedraw
incx:
       mov      al,[x]
       cmp      al,79
       jz       down_cur
       inc      [x]
       jmp      NoRedraw;NextKey
down_cur:
       mov      byte [x],0
incy:
;�᫨ ����� ⥪��
       mov      ebx,[IndexPageActive]
       xor      eax,eax
       mov      al,[y]
       inc      al
       imul     ax,CHAR_ON_LINE
       add      ebx,eax
       cmp      ebx,[SizeTextFormatted]
       jae      NoRedraw
 
       inc      [y]
       mov      al,[y]
       cmp      al,LINES_ON_SCR
       jnz      NoRedraw
       mov      al,24
       mov      [y],al
       add      dword [IndexPageActive],CHAR_ON_LINE
       jmp      NextKey
decy:
 
       mov      al,[y]
       cmp      al,0
       jnz      dodecy
       mov      eax,[IndexPageActive]
       cmp      eax,0
       jz       NoRedraw
       sub      eax,CHAR_ON_LINE
       mov      [IndexPageActive],eax
       jmp      NextKey
dodecy:
       dec      [y]
       jmp      NoRedraw
;---------------------------------------------------------------------------
;��६�饭�� ����� � ����� ⥪�� � ��ப�
end_c:
       mov      ebx,[StartMemory]
       add      ebx,[IndexPageActive]
       xor      eax,eax
       mov      al,[y]
       imul     ax,CHAR_ON_LINE
       add      ebx,eax
       mov      esi,ebx ;� esi ���� ��砫� ��ப� � �����
       add      esi,79 ;⥯��� ����
       mov      cl,81;79
 
 
 
check_size_of_line: ;横� ������ �஡���� �� ���� ��ப�
       mov      al,[esi]
       dec      esi
       dec      cl
 
       jz       NoRedraw
       cmp      al,32
       jz       check_size_of_line
 
       cmp      cl,CHAR_ON_LINE
       jae      set_x_80
 
       mov      [x],cl ;����� ��ࠢ� �� �஡�� � ���� ⥪��
 
       jmp      NoRedraw
 
set_x_80:
       mov      byte [x],79
 
       jmp      NoRedraw
;----------------------------------------
home:
       mov      byte [x],0
       jmp      NoRedraw
;---------------------------------------------------------------------------
backspace:
       cmp      [x],0
       jnz      .l1
       cmp      [y],0
       jz       NextKey
       call     BackspaceLine ;inc\keys\backsp.asm
       cmp      eax,111
       jz       NoRedraw
       jmp      NextKey
.l1:
       dec      [x]
;---------------------------------------------------------------------------
 
key_del:
;㤠����� ᨬ���� ��� ���⮩ ��ப�
 
;+ ��砩 � ����� ��ப�� (start) . . . . . . . . . . . . . . . . . . . . . . .
       mov      eax, dword [SizeTextFormatted] ;�஢��塞 ࠧ���
       cmp      eax, dword CHAR_ON_LINE ;�᫨ �� ���� ��ப� - ��室 �����
       ja       .next
 
       mov      ebx,[StartMemory] ;����塞 ����
 
       cmp      byte [FlagKeyShift],1
       jz       .delLine
 
;ebx = [StartMemory]
       xor      eax,eax
       mov      al,[x]
       add      ebx,eax
       mov      cx, word CHAR_ON_LINE ;���� ���稪 (ࠧ��� ��ப�)
.del:
       mov      al, byte [ebx+1] ;ᤢ�� ᨬ����� � ��ப�
       mov      [ebx], byte al
       inc      ebx
       dec      cx
       jnz      .del
       jmp      NextKey
 
;��砩 � ����⮩ �����襩 Shift - delete line
.delLine:
;ebx = [StartMemory]
       mov      eax, dword 20202020h ;4 �஡���
       mov      cx, word CHAR_ON_LINE/4
.erase:
       mov      [ebx], dword eax
       add      ebx, dword 4
       dec      cx
       jnz      .erase
       jmp      NextKey
.next:
;- ��砩 � ����� ��ப�� (end) . . . . . . . . . . . . . . . . . . . . . . . .
 
       mov      ebx,[IndexPageActive]
       add      ebx,[StartMemory]
       xor      eax,eax
       mov      al,[y]
       imul     ax,CHAR_ON_LINE
       add      ebx,eax
;--check empty line
       mov      esi,ebx
       mov      cl,CHAR_ON_LINE
       cmp      byte [FlagKeyShift],1
       jz       del_line
 
check_e_l:
       mov      al,[esi]
       cmp      al,32
       jnz      not_empty_line
       inc      esi
       dec      cl
       jnz      check_e_l
 
;-------del line
del_line:
       mov      edi,ebx
       mov      esi,ebx
       add      esi,CHAR_ON_LINE
 
;�஢��塞 �� ��室���� ��ப� � ���� ⥪��
       sub      ebx,[StartMemory]
       add      ebx,CHAR_ON_LINE
       cmp      ebx,[SizeTextFormatted]
       jae      cut_text
 
       mov      ecx,[SizeTextFormatted]
       add      ecx,[StartMemory]
       sub      ecx,edi
 
delete_line:
 
       cmp      dword [SizeTextFormatted],CHAR_ON_LINE
       jz       NextKey
 
       call     movsbVersion32
       sub      dword [SizeTextFormatted],CHAR_ON_LINE
       jmp      NextKey
 
cut_text:
       sub      dword [SizeTextFormatted],CHAR_ON_LINE
       cmp      [y],0
       jz       y_0
       dec      [y]
y_0:
       cmp      dword [IndexPageActive],0
       jz       ps_0
       inc      [y]
       sub      dword [IndexPageActive],CHAR_ON_LINE
ps_0:
       mov      cx,CHAR_ON_LINE
       mov      edi,[StartMemory]
       add      edi,[SizeTextFormatted]
 
erase_line:
       mov      byte [edi],32
       inc      edi
       dec      cx
       jnz      erase_line
       jmp      NextKey
;---------------
not_empty_line:
       xor      eax,eax
       mov      al,[x]
       add      ebx,eax
       mov      cl,al
       mov      edi,buf
       mov      esi,ebx
 
moved_line_for_del:
       cmp      cl,CHAR_ON_LINE
       jz       moved_line_for_del_back
       mov      al,[esi]
       mov      [edi],al
       inc      esi
       inc      edi
       inc      cl
       jmp      moved_line_for_del
 
moved_line_for_del_back:
       mov      al,32
       mov      [edi],al
       mov      esi,buf
       inc      esi
       mov      edi,ebx
       mov      cl,[x]
 
moved_line_for_del_back_start:
       cmp      cl,CHAR_ON_LINE
       jz       .out
       mov      al,[esi]
       mov      [edi],al
       inc      esi
       inc      edi
       inc      cl
       jmp      moved_line_for_del_back_start
.out:
       jmp      NextKey
 
;---------------------------------------------------------------------------
;��ࠡ��뢠�� ����⨥ enter
enter_line:
       call     EnterLine
       jmp      NextKey
 
page_down:
       mov      eax,dword [IndexPageActive]
       add      eax,2000
       mov      ebx,dword [SizeTextFormatted]
 
       cmp      ebx,dword 2000
       ja       .l1
 
       mov      [x],0
       mov      [y],byte 0
 
       mov      eax,ebx
       cmp      eax,80
       jae      .div80
       jmp      NextKey
 
.div80:
       inc      byte [y]
       sub      eax, dword 80
       cmp      eax,80
       jae      .div80
 
       dec      byte [y]
 
       jmp      NextKey
.l1:
;-
 
       sub      ebx,2000
       cmp      eax,ebx
       jae      page_down_end_of_text
       mov      [IndexPageActive],eax
       jmp      NextKey
 
page_down_end_of_text:
       mov      [IndexPageActive],ebx
       mov      [x],0
       mov      [y],24
 
       jmp      NextKey
 
 
page_up:
       mov      eax,[IndexPageActive]
       cmp      eax,2000
       ja       do_page_up
       xor      eax,eax
       mov      [x],al
       mov      [y],al
       mov      [IndexPageActive],eax
       jmp      NextKey
 
do_page_up:
       sub      eax,2000
       mov      [IndexPageActive],eax
       jmp      NextKey
 
;����� 横�� ।����
;end main program cycle
 
 
SaveTextAndExit:
;�஢��塞 ࠧ��� ⥪�� � ࠧ��� ����� - �᫨ ���� - �訡�� � ��室
       mov      eax,dword [SizeTextFormatted]
       shl      eax,1
       cmp      eax, dword [SizeMemoryAviable]
       jbe      .MemOk
       mov      eax, dword 4
       mov      [CodError], dword eax
       jmp      close
 
.MemOk:
 
;22:44 30.09.08<-------------------------------------
       xor      eax,eax
       mov      es,ax
 
       mov      eax,[SizeTextFormatted]
 
mov dword [es:0+04f0h],eax
       mov      al,[x]
mov byte [es:0+04f0h+4],al
       mov      al,[y]
mov byte [es:0+04f0h+5],al
       mov      eax,[IndexPageActive]
mov dword [es:0+04f0h+6],eax
;22:44 30.09.08>-------------------------------------
 
 
       call     UnForm ;inc\unform.asm
 
       mov      ecx, dword [SizeTextFormatted]
       mov      esi, dword [StartMemory]
       mov      dx, word [PtrNameFileText]
 
       call     AddOldByte
; mov dword [SizeTextFormatted], ecx
; mov ecx, dword [SizeTextFormatted]
; mov esi, dword [StartMemory]
; mov dx, word [PtrNameFileText]
 
       call     WriteOperation
;mov eax,11
       mov      dword [CodError],eax
 
 
close:
 
       call     SaveTBFile ;TBFile - temp buf filea
 
 
quit:
 
;����⠭�������� ��࠭,��� �뫮
       call     SetTxtVMode ;vesa16.asm
; restore_video 0,0,CHAR_ON_LINE,LINES_ON_SCR,bufferScreen
; cursor 0,24
;------------------cursor------------------
; mov ah,02h ; bios servis
; mov bh,0
; mov dh,24
; mov dl,0
; int 10h
;------------------------------------------
 
 
       push     cs
       pop      ds
       jmp      ExitToOs ;inc\flatrm.asm
       align    16
 
 
       include  'inc\flatrm.asm'
 
ExitDosInt21h:
;���e��e��e �ணࠬ��
       mov      ah,4ch ;ah=4ch (�㭪�� �����襭�� �ணࠬ��)
       int      21h
 
 
;--------------------------------------------
GetLnAdr:
;����塞 ���� ⥪�饩 ��ப� � �����
       xor      eax,eax
       mov      al,[y]
       imulEax80
       add      eax,dword [IndexPageActive]
       add      eax,dword [StartMemory]
 
;eax =ptr
       ret
 
 
GetChAdr:
;����塞 ���� ⥪�饣� ᨬ���� � �����
       push     bx
       shr      ebx,16
       push     bx
 
       xor      eax,eax
       mov      al,[y]
       imulEax80
       xor      ebx,ebx
       mov      bl,[x]
       add      eax,ebx
       add      eax,dword [IndexPageActive]
       add      eax,dword [StartMemory]
 
       pop      bx
       shl      ebx,16
       pop      bx
;eax =ptr
       ret
 
;--------------------------------------------
 
movsbVersion32:
.l1:
       mov      al,[esi]
       mov      [edi],al
       inc      esi
       inc      edi
       dec      ecx
       jnz      .l1
       ret
 
;----------------
PrintDosAH9:
       mov      ah,9
       int      21h
       ret
;----------------
 
;++++++
;������� ������
; biosKBDwait ;inc\macro.asm
BiosKBDWait:
WaitPressAnyKey:
       xor      ax,ax
       int      16h
       ret
;++++++
       align    16
 
       include  'inc\strings\fnd.asm'
 
       include  'inc\video\cls.asm'
 
       include  'inc/replace/ui.asm'
       include  'inc/replace/rep.asm'
       include  'inc/replace/history.asm'
       include  'inc/replace/undercur.asm'
 
 
 
       include  'inc\dec.asm' ;//////////////////////
       include  'inc\msgerr.asm'
 
       include  'inc\tbfile.asm' ;
 
       include  'inc\vesa16.asm'
       include  'inc\video\bitmap.asm'
       include  'inc\video\bitmap1.asm'
       include  'inc\video\page.asm'
       include  'inc\video\cursor.asm'
 
       include  'inc\unform.asm'
 
       include  'inc\read.asm'
       include  'inc\write.asm'
 
       include  'inc\radix50\rmode\radix50.asm' ;
 
       include  'inc\form.asm'
       include  'inc\goto.asm'
       include  'inc\gotod.asm'
       include  'inc\setpg.asm'
 
 
       include  'inc\erase.asm'
       include  'inc\select.asm' ;
       include  'inc\keys\enter.asm' ;Shift+Enter ��ࠡ��稪
       include  'inc\keys\backsp.asm' ;Backspace ��� ��砫� ��ப�
       include  'inc\keys\f5.asm'
 
 
 
       include  'inc\checkf.asm'; call DebugCheckSizeFormTxt
       include  'inc\scancmd.asm'
       include  'inc\light.asm'; LighitText
 
;蠡��� include 'inc\dialog\cho\smenu.asm'
       include  'inc\dialog\cho\help.asm'
       include  'inc\dialog\cho\f7menu.asm'
       include  'inc\dialog\cho\menu.asm'
 
 
       include  'inc\clock.asm'
       include  'inc\delline.asm'
       include  'inc\auto\auto.asm'
 
       include  'inc\compress\lzw.asm'
 
 
;;;include 'inc\pro.asm'
       align    16
 
 
;-----tbuf.asm
iTbuf dd 0
NameTbufFile db 'c:\tmp\emd.tmp',0
rb 66 ;81-15 (80 - max size of path to file on dos system)
h_t_f dw 0
save_SizeTextSelect dd 0
c8 db 0
;-----
 
ptrCopyPasteBuffer dd 0 ;���� ���� ��� ��⠢�� ⥪��
 
BaseProgram dd ?
StartMemory dd 1000000h ;���� ��砫� ����� ����� �ᯮ��㥬��� � �ணࠬ�
EndMemory dd 0
 
;-hide-cursor--3\
F_waitHideCursor dd 0
waitHideCursor dd 0
;-hide-cursor--3/
 
 
;FlagKeyShift db 0 ;�ᯮ������ ��� del , select.
 
;/replace to light.asm
; align 4
;ColoredFlagsAll:
;FlagLabel db 0
;FlagComment db 0
;FlagTextAscii db 0
;PtrFlagTextAscii db 0
;ColorDefaultChar db 7
;FlagModeColor db 0
 
 
;TableVAX - ⠡��� ��� ��४���஢���� RADIX-50 >> ASCII
SetRadActive dd TableVAX
 
;-----------------------------------------------------------------------------
;====
       align    16
 
FontPack:
; file 'inc\font\cyrillic.f8'
       file     'inc\font\cyrillic.pak'
 
       font_size = $-FontPack
;====
       align    16
 
 
       include  'inc\welcom.asm' ;start screen
       include  'inc\intro.asm'
       include  'inc\detectm.asm'
       include  'inc\memch.asm'
       include  'inc\cls16.asm'
       include  'inc\drbytes.asm'
 
       align    16
;       include  'inc\gotod.asm'
 
;here zero data reserv
Replay:
.OldKey dw 0
.f_OldKey db 0
.count db 0
 
FlagKeyShift db 0 ;�ᯮ������ ��� del , select. !!!!!!#1 -�� ������ ���冷�
;��६���� ��� ��⠢�� ⥪��
FlagTextSelect db 0 ;!!!!!!#2
SizeTextSelect dd 0
 
CountWait dd 0
FlagNewFile db 0
CodError dd 0
 
VideoBufMemory dd 0
 
CountPressKbdTotal dd 0 ;�ᥣ� ����⨩
CountPressKbdChar dd 0 ;char ����⨩
 
;PtrBufferText dd 0 ;���� ���� ��� ��⠢�� ⥪��
SizeMemoryAviable dd 0
SizeFile dd 0
SizeTextFormatted dd 0
 
IndexPageActive dd 0
PtrNameFileText dw 0
x db 0
y db 0
CountCHAR_ON_LINE db 0
errors db 0 ;for debug
 
       align    4
Font:
       rb       SIZE_REAL_OF_FONT
       align    16
buf:
;buf2:
rb SIZE_READ_BUF
rb 1000h
       rb       65535-$-2
       if       $ > 10000h
display 'warning: 64k limit exceeded.'
       end      if
 
;EOF