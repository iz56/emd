;emd.asm
;emd text editor - main suorce file
 
;cpu: real & unreal x86
;used: bios, dos, ports API
;OS: MS-DOS (v7.10-tested ok)
;compile: fasm emd.asm emd.com
;flat assembler version 1.20+ need
;license: Public Domain
;written by iz56 12/2014 for EMD
 
 
;macroses
       include  'inc\const.asm'
       include  'inc\macro.asm'
       include  'inc\video.asm'
 
       org      100h
       use16
 
;x86 cod start here
       push     cs
       pop      ds
 
       call     IntroDos ;intro.asm checks
 
       call     DetectMemory ;inc/detectm.asm
       cmp      dword eax,MEMORY_MIN
       jb       quit ;----exit[x]
 
       mov      [EndMemory],dword eax
 
       cld
       call     FlatrmInit ;set CPU to unreal mode
       jc       quit ;----exit[x]
 
 
;flat real mode CPU cod start here :)
 
;get size of memory
       call     MemChk ;inc/memch.asm
 
;scan command line for a file name - return dx=ptr to ASCIIZ string
       call     ScanCmd ;inc/scancmd.asm
       jc       quit ;----exit[x]
 
       mov      [PtrNameFileText],dx ;save ptr to file name
 
;create file
       mov      ah,5bh
       mov      cx,0
       int      21h
       jc       .OpenFile
 
       mov      bx,ax
 
;close file
       mov      ah,3eh
       int      21h
 
;delete file
       mov      dx,word [PtrNameFileText]
       mov      ah,41h
       int      21h
       jc       quit
 
       mov      [FlagNewFile],byte 1
       jmp      new_file
 
.OpenFile:
       mov      dx, word [PtrNameFileText] ;dx=ptr to file name
       mov      edi, dword [StartMemory] ;read to memory start from [edi]
 
       call     ReadOperation ;read.asm ecx=size of readed data
 
;eax = error cod, = zero if not error
       mov      [CodError],dword eax ;save err cod
       test     eax,eax
       jnz      quit ;-----exit[x]
 
       mov      [SizeFile],dword ecx
 
       call     DisplayReadingBytes ;inc\drbytes.asm
       call     WaitPressAnyKey
 
;processing text
;add spaces to lines to 80 - create array of fixed size lines
       call     FormText ;inc\form.asm
 
;print welcom screen - display info
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
 
;erase memory into end text (for del trash from screen)
       call     EraseMemory ;inc\erase.asm
 
       unpackFont ;font was packed LZW
 
;set fs gs
       mov      ax,SEG_VIDEO_MEMORY
       mov      gs,ax
       xor      ax,ax
       mov      fs,ax
;fs = 0, gs = 0x0b800
 
;if file name end ".asm,0"
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
       cmp      eax, dword [.AsmTxtStr] ;compare it
       jnz      .notAsmText
 
;set light syntax flag ON
       mov      byte [FlagModeColor],1
 
.notAsmText:
 
;+
;if size of text = last start program text
;then load position of cursor
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
 
 
;create empty line, if text not exist
       cmp      dword [SizeTextFormatted],0
       jnz      NextKey
 
       mov      ebx,[StartMemory]
       mov      eax,0x020202020 ;4 spaces
       mov      cx,CHAR_ON_LINE/4
.l1:
       mov      [ebx],dword eax
       add      ebx,dword 4
       dec      cx
       jnz      .l1
       mov      dword [SizeTextFormatted],CHAR_ON_LINE
 
 
; START - main program loop here
NextKey:
;call Save_Screen.reset ;reset scr.asm
       call     EraseMemory
 
 
;call StartProf
       redraw
       colored
;call EndProf
NoRedraw:
call Save_Screen.reset ;reset scr.asm
 
       mov      esi,dword [VideoBufMemory]
       call     DrawPage
 
       cmp      [VideoMode],dword 3
       jnz      .vesa
 
;------------------cursor\
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
;------------------cursor/
 
.vesa: ;if vesa - draw cursor not here
 
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
;get data from BIOS
;read KBD buffer directly
;wait pressed any key
       mov      dword [CountWait],0
 
 
       HIDE_CURSOR_TIME = 100
 
;-hide-cursor--1\
       mov      dword [F_waitHideCursor],1
       mov      eax, dword [waitHideCursorValue]
 
       mov      dword [waitHideCursor],eax ;HIDE_CURSOR_TIME
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
.hltSet:
       call     Save_Screen ;scr.asm
 
hlt ;save CPU power :)
; nop
       inc      dword [CountWait]
cmp word bx,[fs:0+041ch]
       jz       wait_kbd
 
cmp byte [Save_Screen.flag],SET_ON
jz NextKey
 
NoWaitKBD:
;all press keys here
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
; Shift ?
;than set FlagKeyShift=ON
       mov      dx,ax ;push ax
       mov      [FlagKeyShift],byte 0
;flag KBD (BIOS data area)
mov al,byte [fs:0+00417h]
       shl      al,6
       cmp      al,0
       jz       .notShiftPressed
       mov      [FlagKeyShift],byte 1 ; 1 = pressed
.notShiftPressed:
       mov      ax,dx ; pop ax
;-
 
       mov      dx,word [FlagKeyShift]
; mov dh,[FlagTextSelect] - order vars
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
 
;---------------------------------------------------------------------------
KeySpecMenu: ;F7
 
       mov      bx, F7Menu
       call     DrawMenu
       jmp      NextKey
 
 
F8VideoMode:
;swith video modes
 
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
 
;\
       cmp      [VideoMode],dword 3
       jnz      .vesa
       mov      [VideoMode],dword 1
       jmp      NextKey
.vesa:
       mov      [VideoMode],dword 3
       mov      [VideoLinear], dword 0
       call     SetTxtVMode ;vesa16.asm
       jmp      NextKey
;/
 
 
KeyHelpMenu:
       mov      bx,HelpMenu ;dx=ptr to menu description
       call     DrawMenu
       jmp      NextKey
 
 
F3GotoLabel:
       call     f3key ;inc\keys\f3.asm
;       call     GotoLabel ;inc\goto.asm
       jmp      NextKey
 
 
;enter text lines from text_buf
actionEnterTextBuffer:
       call     EnterTextBuffer ;inc\keys\f5.asm
       jc       close
       jmp      NextKey
 
 
;cursor keys here
;use x,y , x-char pos in line , y - line pos in screen
decx:
       mov      al,[x]
       cmp      al,0
       jz       NoRedraw
       dec      [x]
       jmp      NoRedraw
incx:
       mov      al,[x]
       cmp      al,80-1
       jz       down_cur
       inc      [x]
       jmp      NoRedraw
down_cur:
       mov      byte [x],0
incy:
;if end text
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
 
;set cursor to end of line
end_c:
       mov      ebx,[StartMemory]
       add      ebx,[IndexPageActive]
       xor      eax,eax
       mov      al,[y]
       imul     ax,CHAR_ON_LINE
       add      ebx,eax
       mov      esi,ebx ; esi = ptr to start of line into memory
       add      esi,80-1
       mov      cl,80+1
 
check_size_of_line: ;get spaces count from end of line
       mov      al,[esi]
       dec      esi
       dec      cl
 
       jz       NoRedraw
       cmp      al,32
       jz       check_size_of_line
 
       cmp      cl,CHAR_ON_LINE
       jae      set_x_80
 
       mov      [x],cl ;cursor right to space on end text into line
       jmp      NoRedraw
 
set_x_80:
       mov      byte [x],80-1
       jmp      NoRedraw
 
 
home:
       mov      byte [x],0
       jmp      NoRedraw
 
 
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
 
 
key_del:
;delete char or empty line
 
;if one line ------\
       mov      eax, dword [SizeTextFormatted] ;check size of text
       cmp      eax, dword CHAR_ON_LINE ;if lines more then 1 - out
       ja       .next
 
       mov      ebx,[StartMemory] ;calc adr
 
       cmp      byte [FlagKeyShift],1
       jz       .delLine
 
;ebx = [StartMemory]
       xor      eax,eax
       mov      al,[x]
       add      ebx,eax
       mov      cx, word CHAR_ON_LINE
.del:
       mov      al, byte [ebx+1] ;shift chars in line
       mov      [ebx], byte al
       inc      ebx
       dec      cx
       jnz      .del
       jmp      NextKey
 
;if pressed Shift - delete line
.delLine:
;ebx = [StartMemory]
       mov      eax, dword 20202020h ;4 spaces
       mov      cx, word CHAR_ON_LINE/4
.erase:
       mov      [ebx], dword eax
       add      ebx, dword 4
       dec      cx
       jnz      .erase
       jmp      NextKey
.next:
;if one line ------/
 
 
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
 
;check if line in end of text
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
 
.moved_line_for_del:
       cmp      cl,CHAR_ON_LINE
       jz       .moved_line_for_del_back
       mov      al,[esi]
       mov      [edi],al
       inc      esi
       inc      edi
       inc      cl
       jmp      .moved_line_for_del
 
.moved_line_for_del_back:
       mov      al,32
       mov      [edi],al
       mov      esi,buf
       inc      esi
       mov      edi,ebx
       mov      cl,[x]
 
.moved_line_for_del_back_start:
       cmp      cl,CHAR_ON_LINE
       jz       .out
       mov      al,[esi]
       mov      [edi],al
       inc      esi
       inc      edi
       inc      cl
       jmp      .moved_line_for_del_back_start
.out:
       jmp      NextKey
 
 
;enter key here
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
       jae      .page_down_end_of_text
       mov      [IndexPageActive],eax
       jmp      NextKey
 
.page_down_end_of_text:
       mov      [IndexPageActive],ebx
       mov      [x],0
       mov      [y],24
 
       jmp      NextKey
 
 
page_up:
       mov      eax,[IndexPageActive]
       cmp      eax,2000
       ja       .do_page_up
       xor      eax,eax
       mov      [x],al
       mov      [y],al
       mov      [IndexPageActive],eax
       jmp      NextKey
 
.do_page_up:
       sub      eax,2000
       mov      [IndexPageActive],eax
       jmp      NextKey
 
 
;end main program cycle
 
 
SaveTextAndExit:
;check size text and size free memory
       mov      eax,dword [SizeTextFormatted]
       shl      eax,1
       cmp      eax, dword [SizeMemoryAviable]
       jbe      .MemOk
       mov      eax, dword 4
       mov      [CodError], dword eax
       jmp      close
 
.MemOk:
 
;---save cursor pos---\
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
;---save cursor pos---/
 
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
       mov      dword [CodError],eax
 
close:
       call     SaveTBFile ;TBFile - temp buf filea
 
quit:
       call     SetTxtVMode ;vesa16.asm
 
       push     cs
       pop      ds
ExitToOs:
       mov      ax,250Dh
mov dx,word [irq_5] ;irq_5 see: /inc/flatrm.asm
       mov      ds,word [irq_5+2]
       int      21h
 
       mov      eax, dword [CodError]
       test     eax,eax ;if not error - exit
       jz       .Exit
 
.l0:
       cmp      eax, dword MAX_MSGS_ERRORS_NUM
       ja       .Exit
       shl      ax,1
       mov      bx,TablePtrMsgErr ;msgerr.asm
       add      bx,ax
       mov      si,[bx-2]
       call     OutTextRadix50RealMode ;print msg
 
       mov      al,0ffh ;set err cod for dos
       mov      [Exit2OsCod], byte al
.Exit:
       mov      al,[Exit2OsCod] ;(return cod for ah=4ch,int 21h)
 
ExitDosInt21h:
       mov      ah,4ch
       int      21h ;-------------------main exit from program
 
;----------
SaveXY:
 
       mov      al,[y]
       mov      [.y],al
       mov      al,[x]
       mov      [.x],al
       ret
.re:
       mov      al,[.y]
       mov      [y],al
       mov      al,[.x]
       mov      [x],al
       ret
.y db 0
.x db 0
 
 
 
 
 
;------
SetCursor:
       xor      ebx,ebx
       mov      bl,[x]
       xor      eax,eax
       mov      al,[y]
       imulEax80
       add      ebx,eax
       mov      al,0x0E
       mov      ah,bh
       mov      dx,03d4h
       out      dx,ax
       inc      ax
       mov      ah,bl
       out      dx,ax
       ret
 
 
;------
 
GetLnAdr:
;calc adr active line (cursor y)
       xor      eax,eax
       mov      al,[y]
       imulEax80
       add      eax,dword [IndexPageActive]
       add      eax,dword [StartMemory]
 
;eax =ptr
       ret
 
 
GetChAdr:
;calc adr active char (cursor x)
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
; biosKBDwait ;inc\macro.asm
BiosKBDWait:
WaitPressAnyKey:
       xor      ax,ax
       int      16h
       ret
;++++++
 
; include 'inc\loging.asm'
       include  'inc\dbg.asm' ;QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQq
 
 
       include  'inc\flatrm.asm'
 
       include  'inc\redraw.asm'
 
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
       include  'inc\video\all.asm'
       include  'inc\video\bitmap.asm'
       include  'inc\video\bitmap1.asm'
       include  'inc\video\page.asm'
       include  'inc\video\cursor.asm'
 
       include  'inc\unform.asm'
 
       include  'inc\read.asm'
       include  'inc\write.asm'
 
       include  'inc\radix50\rmode\radix50.asm' ;
       include  'inc\radix50\unreal\radix50.asm' ;
 
       include  'inc\form.asm'
 
       include  'inc\erase.asm'
       include  'inc\select.asm' ;
       include  'inc\keys\enter.asm' ;Shift+Enter
       include  'inc\keys\backsp.asm' ;Backspace
       include  'inc\keys\f5.asm'
       include  'inc\keys\f3.asm'
 
 
       include  'inc\checkf.asm'; call DebugCheckSizeFormTxt
       include  'inc\scancmd.asm'
       include  'inc\light.asm'; LighitText
 
;template include 'inc\dialog\cho\smenu.asm'
       include  'inc\dialog\cho\help.asm'
       include  'inc\dialog\cho\f7menu.asm'
       include  'inc\dialog\cho\menu.asm'
 
 
       include  'inc\clock.asm'
       include  'inc\delline.asm'
       include  'inc\auto\auto.asm'
 
       include  'inc\compress\lzw.asm'
 
       include  'inc\welcom.asm' ;start screen
       include  'inc\intro.asm'
       include  'inc\detectm.asm'
       include  'inc\memch.asm'
       include  'inc\cls16.asm'
       include  'inc\drbytes.asm'
 
 
       include  'inc\scr.asm'
;call Save_Screen ;scr.asm
 
 
       include  'deldir\goto.asm'
       include  'deldir\gotod.asm'
       include  'deldir\setpg.asm'
 
 
FontPack:
; file 'inc\font\cyrillic.f8'
       file     'inc\font\cyrillic.pak' ;here rus font only for graph mode ,pack
; font_size = $-FontPack
;====
 
 
;;;include 'inc\pro.asm'
       align    4
;leght of one line on page (dword)
leghtY dd 80
IndexPageActive dd 0
SizeTextFormatted dd 0
VideoBufMemory dd 0
StartMemory dd 1000000h
EndMemory dd 0
x db 0
y db 0
 
;-----tbuf.asm
iTbuf dd 0
NameTbufFile db 'c:\tmp\emd.tmp',0
       rb       66 ;81-15 (80 - max size of path to file on dos system)
h_t_f dw 0
save_SizeTextSelect dd 0
c8 db 0
;-----
 
ptrCopyPasteBuffer dd 0 ;main ptr to paste and copy text (F5 key)
 
;-hide-cursor--3\
F_waitHideCursor dd 0
waitHideCursor dd 0
waitHideCursorValue dd HIDE_CURSOR_TIME
;-hide-cursor--3/
 
 
;FlagKeyShift db 0 ; del , select.
 
;/replace to light.asm
; align 4
;ColoredFlagsAll:
;FlagLabel db 0
;FlagComment db 0
;FlagTextAscii db 0
;PtrFlagTextAscii db 0
;ColorDefaultChar db 7
;FlagModeColor db 0
 
 
;TableVAX - RADIX-50 >> ASCII
SetRadActive dd TableVAX
 
       align    4
Replay:
.OldKey dw 0
.f_OldKey db 0
.count db 0
 
FlagKeyShift db 0 ;for del , select. !!!!!!#1 -no change order
;vars for enter text
FlagTextSelect db 0 ;!!!!!!#2
SizeTextSelect dd 0
 
CountWait dd 0
CodError dd 0
FlagNewFile db 0
 
       align    4
VideoLinear dd 0 ; address of video linear memory
CountPressKbdTotal dd 0 ;all keys pressed
CountPressKbdChar dd 0 ;chars keys pressed
 
;PtrBufferText dd 0
SizeMemoryAviable dd 0
SizeFile dd 0
 
PtrNameFileText dw 0
CountCHAR_ON_LINE db 0
errors db 0 ;for debug
Exit2OsCod db 0; for ah=4ch,int 21h
InsertKeyStatus db 0 ;0=enter 1=insert
 
       align    16
Font:
rb SIZE_REAL_OF_FONT
 
       align    4
TmpData:
rb 100h
 
       align    16
buf:
       rb       SIZE_READ_BUF
       rb       1000h
 
rb 65535-$-2
       if       $ > 10000h
display 'warning: 64k limit exceeded.'
       end      if
 
;EOF
