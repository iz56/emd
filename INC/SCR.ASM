;scr.asm
       
       
       ON_SAVESCREEN_TICS=1000
       
       
Save_Screen: ;scr.asm
       
       cmp      dword [.counterOfCalls],0
       jz       .work
       dec      dword [.counterOfCalls]
       ret
.work:
       cmp      [.flag],byte SET_OFF
       jz       .clsScreen
       
       ret
.clsScreen:
       pusha
       call     cls
       mov      [.flag],byte SET_ON
       popa
       ret
       
.reset:
       mov      dword [.counterOfCalls],ON_SAVESCREEN_TICS
       mov      [.flag],byte SET_OFF
       ret
       
.flag db 0
.counterOfCalls dd 0
       
       
;EOF
       
       