;smenu.asm

SimpleMenu:

;ᬥ饭�� �� ⠡���� 㪠��⥫�� ��뢠����� �� ���� ����
.pCodsTbl dd .CodsPtrsTbl

;ᬥ饭�� �� ⠡���� ⥪�⮢�� ��ப ᮮ⢥������� �㭪⠬ ����
.pStrTbl dd .StrsTbl

.cItems dd 7 ;�᫮ items �㭪⮢ ���� (�ᥣ�|total)

.SizeStr dd 27 ; size of 1 text string

.PosW dd 16  ; position of text window (*2)

.ActiveItem dd 1 ;⥪��� ��ப�

.colorNotActivItem dd 7;梥� ����⨢��� �㭪⮢ ����

.colorActivItem dd 23;梥� ��⨢��� �㭪⮢ ����

.StrsTbl:
db ' 1        *---------------- ',0
db ' 2       t*---------------- ',0
db ' 3   *text*---------------- ',0
db ' test*text*---------------- ',0
db ' test*text*---------------- ',0
db ' test*text*---------------- ',0
db ' test*text*---------------- ',0


;-------------------------------------------------------------------------------
.CodsPtrsTbl:
dw .dum ;����⢨� �� 㬮�砭��
dw .dum ;����⢨� �� 㬮�砭��
dw .dum ;����⢨� �� 㬮�砭��
dw .dum ;����⢨� �� 㬮�砭��
dw .dum ;����⢨� �� 㬮�砭��
dw .dum ;����⢨� �� 㬮�砭��
dw .dum ;����⢨� �� 㬮�砭��

;-------------------------------------------------------------------------------

.dum: ;����⢨� �� 㬮�砭��
       ret


;EOF

