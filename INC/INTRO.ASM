;intro.asm
 
 
IntroDos:
 
;check ver MS-DOS , need v7.10
       mov      ah,30h
       int      21h
;al = major
;ah = minor
       cmp      al,3 ;is 3 dos?
       jae      .dos_ok
 
       mov      si, .MsgErr1
       call     OutTextRadix50RealMode
       int      20h ;terminate
 
.dos_ok:
       mov      al,[80h] ;cmd line args?
       cmp      al,1
       ja       .l1
 
       mov      si, .MsgErrParameters
       jmp      .ExitError
 
.l1:
       call     .CheckNameFile ;parse
       jnc      .l2
       mov      si, .MsgErrParameters
       jmp      .ExitError
.l2:
 
; vga?
       xor      al,al ;al=0 (screen on)
       mov      ah,12h
       mov      bl,36h ;bl = on/off screen
       int      10h
 
       cmp      al,12h ;is it vga?
       je       .vga_ok
 
       mov      si, .MsgErr2
       jmp      .ExitError
 
.vga_ok:
       mov      ah,0fh
       int      10h ;get video mode
 
       cmp      al,02h
       jz       .SetVid
 
       cmp      al,07h
       jz       .SetVid
 
 
       cmp      al,03h ;need 3
       je       .VidOK
 
; mov ax,0003h ;set 80x25x16 char mode
; int 10h
 
       mov      si, .MsgErr5
       jmp      .ExitError
 
.SetVid:
       mov      ax,0003h ;set 80x25x16 char mode
       int      10h
 
.VidOK:
; CPU mode
       mov      eax,cr0
       test     al,1
       jz       .no_V86
 
       mov      si, .MsgErr3
       jmp      .ExitError
 
.no_V86:
; Windows 95 > êÖ = é?
       mov      ax,1600h
       int      2Fh
       test     al,al
       jz       .no_windows
 
       mov      si, .MsgErr4
       jmp      .ExitError
 
.no_windows:
.all_ok:
       ret      ;------------------------------exit[x]
 
.ExitError:
       call     OutTextRadix50RealMode
 
       mov      al,0ffh ;al=0ffh (ret cod)
       jmp      ExitDosInt21h ;emd.asm
 
.MsgErr1:
;THIS PROGRAM REQUIRES DOS 7.10 OR LATER
db 049h ,07eh ,0d0h ,076h ,0dfh ,072h ,0b5h
db 070h ,0d5h ,002h ,091h ,06dh ,05bh ,071h
db 0afh ,000h ,0e5h ,076h ,0f6h ,0b3h ,06ah
db 002h ,0e1h ,001h ,0dah ,07dh ,0c0h ,0a8h
 
.MsgErr2:
;THIS PROGRAM REQUIRES VGA OR BETTER
db 049h ,07eh ,0d0h ,076h ,0dfh ,072h
db 0b5h ,070h ,0d5h ,002h ,091h ,06dh
db 05bh ,071h ,077h ,003h ,04fh ,006h
db 082h ,070h ,074h ,022h ,02bh ,022h
 
.MsgErr3:
;PLEASE RESTART PROGRAM IN DOS. V86 MODE DETECTED
db 0e5h ,065h ,03dh ,009h ,0d5h ,002h
db 0e1h ,079h ,0a0h ,073h ,0dfh ,066h
db 091h ,02eh ,049h ,051h ,084h ,057h
db 0d4h ,060h ,096h ,003h ,00dh ,0e1h
db 065h ,05eh ,0a5h ,000h ,0cbh ,07dh
db 0cch ,07dh ,0c0h ,0a8h
 
.MsgErr4:
;PROGRAM RUNNED UNDER WINDOWS. NOT RING 0
db 0dfh ,066h ,091h ,02eh ,052h ,051h
db 07eh ,085h ,0e0h ,01fh ,074h ,085h
db 010h ,022h ,036h ,091h ,06fh ,01bh
db 020h ,07bh ,0ech ,059h ,0d9h ,002h
db 098h ,058h ,0b8h ,0bfh
 
.MsgErr5:
;THIS PROGRAM REQUIRES VGA VIDEO MODE 3
db 049h ,07eh ,0d0h ,076h ,0dfh ,072h
db 0b5h ,070h ,0d5h ,002h ,091h ,06dh
db 05bh ,071h ,077h ,003h ,056h ,006h
db 0e5h ,038h ,0cdh ,05dh ,065h ,05eh ,043h ,005h
 
.MsgErrParameters:
;PLEASE ENTER FILE NAME IN COMMAND LINE. FILE NAME REQUIREMENTS
db 0e5h ,065h ,03dh ,009h ,0d6h ,000h ,0dah ,07dh ,0f9h ,000h ,0c8h ,04bh
db 0b5h ,057h ,049h ,01fh ,083h ,057h ,0d5h ,05fh ,074h ,008h ,0e9h ,001h
db 064h ,058h ,0f9h ,000h ,0c8h ,04bh ,0b5h ,057h ,052h ,01fh ,0fdh ,021h
db 015h ,03bh ,016h ,052h ,013h ,080h
 
 
.CheckNameFile:
 
; true chars: ! @ # $ % ^ & ( ) ' ~ - _
 
       mov      si,81h+1
       mov      cx,80
 
.scancmd:
 
       mov      byte al,[si]
       inc      si
 
;end line
       cmp      al ,13
       jz       .exit
       cmp      al ,10
       jz       .exit
 
       cmp      al ,' '
       jz       .endLine
 
       cmp      al ,'/'
       jz       .endLine
 
       cmp      al ,'?'
       jz       .errorNameFile
 
       cmp      al ,'*'
       jz       .errorNameFile
 
       cmp      al ,0
       jz       .errorNameFile
 
       dec      cx
       jnz      .scancmd
 
.errorNameFile:
       stc
       ret
 
 
.endLine:
       mov      [si-1], byte 13
 
       mov      byte al,[si]
       cmp      al ,'-'
       jz       .endLineParam
       cmp      al ,'/'
       jz       .endLineParam
       cmp      al ,'\'
       jz       .endLineParam
 
       cmp      al,'f' ;off start msg
       jz       paramF
.endLineParam:
       mov      byte al,[si+1]
       cmp      al,'f' ;off start msg
       jz       paramF
; cmp al,'e'
; jz paramE
       clc
       ret
 
.exit:
       clc
       ret
 
 
paramF:
       mov      bx,drawInfoBox
       mov      eax,090909090h ;4xnop
       mov      dword [bx],eax
       clc
       ret
 
;paramE:
 
; clc
; ret
 
 
;EOF
