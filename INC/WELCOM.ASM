;welcom.asm
 
 
Welcom:
       cls      7
 
.LINE = 12
 
;------------------cursor------------------
       mov      ah,02h ;- bios servis
       mov      bh,0
       mov      dh,.LINE
       mov      dl,0
       int      10h
;------------------------------------------
 
       mov      esi,.msgWelcom
       mov      di,buf
       call     OutTextRadix50RealMode
       call     WaitPressAnyKey ;emd.asm
 
       ret
 
.msgWelcom:
db 04ch ,021h ,025h ,003h ,020h ,099h ,0e9h ,01fh ,06ah ,07fh ,0c0h ,0a8h
 
;EOF
