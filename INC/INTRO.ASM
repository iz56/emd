;intro.asm
 
 
IntroDos:
 
;Проверяем номер версии dos
       mov      ah,30h ;ah=30h (функция о┐ределения версии dos)
       int      21h ;al = старший номер версии dos
 
;ah = младший номер версии dos
       cmp      al,7 ;7я версия dos?
       jz      .dos_ok
 
       mov      si, .MsgErr1
       call     OutTextRadix50RealMode
       int      20h ;завершение ┐рограммы (выход для старых версий)
 
.dos_ok:
       mov      al,[80h];если нет параметров -
       cmp      al,1
       ja       .l1
 
       mov      si, .MsgErrParameters
       jmp      .ExitError
 
.l1:
       call     .CheckNameFile ;разбор командной строки
       jnc      .l2
       mov      si, .MsgErrParameters
       jmp      .ExitError
.l2:
 
;┐роверяем наличие видеоада┐тера vga
       xor      al,al ;al=0 (включeниe экрана)
       mov      ah,12h ;ah=12h (функция прeрывания int 10h)
       mov      bl,36h ;bl = подфункция гашeния/включeния экрана
       int      10h
 
       cmp      al,12h ;это vga?
       je       .vga_ok
 
       mov      si, .MsgErr2
       jmp      .ExitError
 
.vga_ok:
       mov      ah,0fh
       int      10h ;Получить текущий видеорежим
 
;       cmp      al,02h
;       je       .VidOK
 
;       cmp      al,07h
;       je       .VidOK
 
       cmp      al,03h
       je       .VidOK ;Если текстовой режим
 
; mov ax,0003h ;set 80x25x16 char mode
; int 10h
 
       mov      si, .MsgErr5
       jmp      .ExitError
 
.VidOK:
; проверить, находимся ли мы уже в защищенном режиме
       mov      eax,cr0 ; прочитать регистр CR0
       test     al,1 ; проверить бит РЕ,
       jz       .no_V86 ; если он ноль - мы можем продолжать,
 
; иначе - сообщить об ошибке и выйти
       mov      si, .MsgErr3
       jmp      .ExitError
 
.no_V86:
; может быть, это Windows 95 делает вид, что РЕ = О?
       mov      ax,1600h
       int      2Fh
       test     al,al
       jz       .no_windows
 
; сообщить и выйти
       mov      si, .MsgErr4
       jmp      .ExitError
 
; итак, мы точно находимся в реальном режиме
.no_windows:
 
;       mov      al,[80h];если нет параметров -
;       cmp      al,1
;       ja       .all_ok
 
;       mov      si, .MsgErrParameters
;       jmp      .ExitError
 
.all_ok:
       ret
 
.ExitError:
       call     OutTextRadix50RealMode
 
       mov      al,0ffh ;al=0ffh (kод возврата)
;завeршeниe программы
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
 
 
;проверяем имя файла и обрабатываем параметры (если есть)
.CheckNameFile:
 
; символы допустимые в имени файла ! @ # $ % ^ & ( ) ' ~ - _
 
       mov      si,81h+1
       mov      cx,80
 
.scancmd:
 
       mov      byte al,[si]
       inc      si
 
       cmp      al ,' '
       jz       .endLine
 
       cmp      al ,'-'
       jz       .endLineParam
 
       cmp      al ,'/'
       jz       .endLineParam
 
;недопустимый символ в имени файла (обрабатывать как ошибку)
       cmp      al ,'?'
       jz       .errorNameFile
 
;недопустимый символ в имени файла (обрабатывать как ошибку)
       cmp      al ,'*'
       jz       .errorNameFile
 
;конец строки
       cmp      al ,13
       jz       .endLine
 
       cmp      al ,10
       jz       .endLine
 
;проверим на всякий случай
       cmp      al ,0
       jz       .endLine
       dec      cx
       jnz      .scancmd
 
.errorNameFile:
       stc
       ret
 
.endLineParam:
       mov      byte al,[si]
       cmp      al,'f' ;параметр означает - без стартового экрана
       jnz      .endLine
 
;делаем сброс стартового экрана
;посредством прямой модификации кода
;забиваем вызов кодами инструкции nop
       mov      bx,drawInfoBox
       mov      eax,090909090h
       mov     dword [bx],eax
.endLine:
       dec      si
       mov      [si], byte 13
 
 
;       call     .GetTime ;задаём параметры - зависимые от времени
 
       clc
       ret
 
;.GetTime:
;       nop
;mov ah,02h ;функция 02h прерывания 1Ah:
;       int      1Ah ;чтение времени из RTC
;       jc       .GetTime ;если часы заняты
;AL = число часов в BCD формате
;       cmp      al,0x07
;       ja       .ab07
;.ab07:
;       cmp      al,0x19
;       jb       .ok3
;       mov      [VideoMode],dword 8;определяет какой режим при старте программы
;.ok3:
;       ret
 
 
;EOF
