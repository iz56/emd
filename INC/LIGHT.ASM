;light.asm
;see emd.asm > include 'inc/light.asm'
;���ᢥ⪠ ᨭ⠪�� ��ᥬ���� ��� � �⮬ 䠩��
 
LIGHT_ON = 1
LIGHT_OFF = 0
 
DEF_COLOR=7 ;���� ����� 梥� ⥪��
;CHAR_ON_LINE=80 ;ࠧ��� ��࠭��� ��ப�
 
LightText:
       cmp      byte [FlagModeColor],LIGHT_OFF
       jnz       .work
       ret
 
.work:
       xor      edi,edi
       mov      ebx,dword [VideoBufMemory]
 
.nextLn:
;��ࠡ��뢠�� �����筮 (81=����� ��ப�+1)
       mov      cl,CHAR_ON_LINE+1
       mov      dword [ColoredFlagsAll],0
;�� ���� 䫠�� ���孥� ��ப�� �� ࠧ ���������
; mov byte [FlagLabel],0
; mov byte [FlagComment],0
; mov byte [FlagTextAscii],0
; mov byte [PtrFlagTextAscii],0
 
       mov      byte [ColorDefaultChar],DEF_COLOR
 
;---------
       push     di cx
 
.CheckLabelText:
       mov      word ax,[ebx+edi]
       add      edi,2
 
       cmp      ah,23 ;�뤥����� ⥪��
       jz       .CheckLabelTextEnd
 
       cmp      al,'[' ;
       jz       .CheckLabelTextEnd
 
       cmp      al,';' ;
       jz       .CheckLabelTextEnd
 
       cmp      al,27h
       jz       .CheckLabelTextEnd
 
       cmp      al,':'
       jz       .CheckLabelTextOk
 
       dec      cl
       jnz      .CheckLabelText
 
       jmp      .CheckLabelTextEnd
 
.CheckLabelTextOk:
       cmp      cl,byte 55 ;����� �� ���ன ������� 梥�
       jb       .CheckLabelTextEnd
 
       mov      byte [ColorDefaultChar],COLOR_LABEL_TXT
       mov      byte [FlagLabel],1
 
.CheckLabelTextEnd:
       pop      cx di
;------
 
.Redraw:
       dec      cl
       jz       .nextLn
       mov      word ax,[ebx+edi]
 
       cmp      ah,23 ;�뤥����� ⥪��
       jz       .NextStep
 
       cmp      al,';'
       jz       .SetFlagComment
 
       cmp      al,'['
       jz       .ItIs_AsciiText
 
       cmp      al,']'
       jz       .ItIs_AsciiText
 
       cmp      al,27h
       jz       .AsciiText
 
       cmp      al,':'
       jz       .LabelTextIsEnd
 
.DoIt_1:
       mov      ah,[ColorDefaultChar]
.DoIt:
       mov      word [ebx+edi],ax
 
.NextStep:
       add      edi,2
       cmp      edi,4000 ;size of video buf
       jbe      .Redraw
 
       ret ;exit-------------------------------------------[!]
 
.LabelTextIsEnd:
       cmp      byte [FlagLabel],0
       jz       .DoIt
 
       mov      byte [FlagLabel],0
       mov      byte [ColorDefaultChar],DEF_COLOR
 
 
       mov      ah,byte COLOR_LABEL_TXT
       jmp      .DoIt
 
.SetFlagComment:
       cmp      byte [FlagTextAscii],0
       jnz      .DoIt
 
       mov      byte [FlagComment],1
       mov      byte [ColorDefaultChar],8
 
       mov      ah,8
       jmp      .DoIt
 
.AsciiText:
       cmp      byte [FlagTextAscii],0
       jz       .SetFlagTextAscii
 
 
       mov      byte [FlagTextAscii],0
       mov      byte [ColorDefaultChar],DEF_COLOR
       mov      byte ah,COLOR_ASCII_TXT
       jmp      .DoIt
 
.SetFlagTextAscii:
       cmp      byte [FlagComment],0
       jnz      .DoIt_1
 
       mov      byte [FlagTextAscii],1
       mov      byte [ColorDefaultChar],COLOR_ASCII_TXT
       mov      ah,COLOR_ASCII_TXT
       jmp      .DoIt
 
.ItIs_AsciiText:
       cmp      byte [PtrFlagTextAscii],0
       jz       .SetFlagTextAsciiPtr
 
       mov      byte [PtrFlagTextAscii],0
       mov      byte [ColorDefaultChar],DEF_COLOR
       mov      byte ah,COLOR_ASCII_TXT_OFFSET
       jmp      .DoIt
 
.SetFlagTextAsciiPtr:
       cmp      byte [FlagComment],0
       jnz      .DoIt_1
 
       cmp      byte [FlagTextAscii],0
       jnz      .DoIt_1
 
       mov      byte [PtrFlagTextAscii],1
       mov      byte [ColorDefaultChar],COLOR_ASCII_TXT_OFFSET2
       mov      ah,COLOR_ASCII_TXT_OFFSET
       jmp      .DoIt
 
ColoredFlagsAll:
FlagLabel db 0
FlagComment db 0
FlagTextAscii db 0
PtrFlagTextAscii db 0
ColorDefaultChar db DEF_COLOR
FlagModeColor db 0
 
 
SwithColorOnOff:
       cmp      byte [FlagModeColor],LIGHT_OFF
       jz       .set_FlagModeColor
       mov      byte [FlagModeColor],LIGHT_OFF
       ret
.set_FlagModeColor:
       mov      byte [FlagModeColor],LIGHT_ON
       ret
 
 
;EOF
