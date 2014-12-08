;clock.asm

       CLOCK_ON = 1
       CLOCK_OFF = 0


UserClockFlag db CLOCK_OFF


Clock:
       cmp      [UserClockFlag],byte CLOCK_ON
       jnz      .okClock
       ret

.okClock:

       cmp      [VideoMode],dword 3
       jz       .vgaMode

       call     PrintClockVESA

       ret
.vgaMode:

       call     PrintClockVGA

       ret


       COLOR_CLOCK=19

       macro    SetClockColor {
       mov      byte ah,COLOR_CLOCK
mov byte [gs:ebx+1],ah
       }


PrintClockVGA:

       pusha
; cmp [VideoMode],dword 3
; jz vgaMode
; mov ebx,dword [VideoBufMemory]
;
;
; vgaMode:

       xor      ebx,ebx
       mov      ah,02h
       int      1ah
       mov      al,ch
       shr      al,4
       add      al,48
       mov      bx,150
mov byte [gs:ebx],al

       SetClockColor

       add      bx,2
       mov      al,ch
       shl      al,4
       shr      al,4
       add      al,48
mov byte [gs:ebx],al

       SetClockColor


       add      bx,2
mov al,':'
mov byte [gs:ebx],al

       SetClockColor

       add      bx,2
       mov      al,cl
       shr      al,4
       add      al,48
mov byte [gs:ebx],al

       SetClockColor

       add      bx,2
       mov      al,cl
;cmp al,9
;jb ok_form
;mov al,0
;ok_form:
       shl      al,4
       shr      al,4
       add      al,48
mov byte [gs:ebx],al

       SetClockColor

       popa
       ret
;------------------------------------

       COLOR_CLOCK=7

       macro    SetClockColorVESA {
       mov      byte ah,COLOR_CLOCK
       }


PrintClockVESA:

       pusha

; xor ebx,ebx
       mov      ah,02h
       int      1ah
       mov      al,ch
       shr      al,4
       add      al,48
       mov      ebx,dword [VideoBufMemory]
       add      ebx,150

       SetClockColorVESA
       mov      word [ebx],ax

       add      ebx,2
       mov      al,ch
       shl      al,4
       shr      al,4
       add      al,48

       SetClockColorVESA
       mov      word [ebx],ax


       add      ebx,2
mov al,':'

       SetClockColorVESA
       mov      word [ebx],ax

       add      ebx,2
       mov      al,cl
       shr      al,4
       add      al,48

       SetClockColorVESA
       mov      word [ebx],ax

       add      ebx,2
       mov      al,cl
;cmp al,9
;jb ok_form
;mov al,0
;ok_form:
       shl      al,4
       shr      al,4
       add      al,48

       SetClockColorVESA
       mov      word [ebx],ax

       cmp      [.saveMinutes],al
       jnz      .Draw
       mov      [.saveMinutes],al
       ret

.Draw:
       mov      esi,dword [VideoBufMemory]
       call     DrawPageFirstLine ;вывод пикселей

       popa
       ret

.saveMinutes db 0

;------------------------------------
SwithClockOnOff:
       cmp      [UserClockFlag],byte CLOCK_ON
       jz       .okClock

       mov      [UserClockFlag],byte CLOCK_ON
       ret

.okClock:

       mov      [UserClockFlag],byte CLOCK_OFF


       ret


;EOF

