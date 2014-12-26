;flatrm.asm
;It is based on fasm 1.20 by Tomasz Grysztar.
 
 
FlatrmInit:
       mov      ax,350Dh
       int      21h
 
       mov      word [irq_5],bx
       mov      word [irq_5+2],es
       push     cs
       pop      es
       mov      ax,250Dh
       mov      dx,int_13
       int      21h
 
       push     ds
       push     0
       pop      ds
       call     enable_a20 ; enable A20
       call     test_a20 ; is A20 enabled?
       jz       .a20_ok
       pop      ds
       stc
       ret
.a20_ok:
       pop      ds
       clc
       ret
 
 
enable_a20:
       call     test_a20 ; is A20 already enabled?
       jz       .a20_enabled ; if yes, done
 
       in       al,92h ; PS/2 A20 enable
       or       al,2
       out      92h,al
       call     test_a20 ; is A20 enabled?
       jz       .a20_enabled ; if yes, done
 
       call     kb_wait ; AT A20 enable
       jnz      .a20_enabled
 
       mov      al,0D1h
       out      64h,al
       call     kb_wait
       jnz      .a20_enabled
 
       mov      al,0DFh
       out      60h,al
       call     kb_wait
 
.a20_enabled:
       ret
 
 
kb_wait: ; wait for safe to write to 8042
       xor      cx,cx
.loop:
       in       al,64h ; read 8042 status
       test     al,2 ; buffer full?
       loopnz   .loop ; if yes, loop
       ret
 
 
test_a20: ; test for enabled A20
mov al,[0] ; get byte from 0:0
       mov      ah,al ; preserve old byte
       not      al ; modify byte
xchg al,[100000h] ; put modified byte to 0FFFFh:10h
cmp ah,[0] ; set zero if byte at 0:0 not modified
mov [100000h],al ; restore byte at 0FFFFh:10h
       ret      ; return, zero if A20 enabled
 
 
       align    4
int_13:
       push     eax
       mov      al,00001011b ; OCW3 - read IRQ in-service register
       out      20h,al
       in       al,20h
       test     al,00100000b ; is IRQ 5 in service?
       jz       exception
       pop      eax
jmp dword 0:0
       label    irq_5 dword at $-4
exception:
       push     ds es fs gs
       cli      ; disable interrupts
       xor      eax,eax ; calculate linear address of GDT
       mov      ax,cs
       shl      eax,4
       add      eax,GDT
mov dword [cs:GDTR+2],eax
lgdt pword [cs:GDTR] ; load GDT register
       mov      eax,cr0 ; switch to protected mode
       or       al,1
       mov      cr0,eax
       jmp      pm_start
pm_start:
       mov      ax,1 shl 3 ; load 32-bit data descriptor
       mov      ds,ax ; to all data segment registers
       mov      es,ax
       mov      fs,ax
       mov      gs,ax
       mov      eax,cr0 ; switch back to real mode
       and      al,not 1
       mov      cr0,eax
       jmp      pm_end
pm_end:
       sti      ; enable interrupts
       pop      gs fs es ds
       pop      eax
       iret
 
       align    16
 
GDTR dw 2*8-1 ; limit of GDT
dd ? ; linear address of GDT
GDT rw 4 ; null descriptor
dw 0FFFFh,0,9200h,8Fh ; 32-bit data descriptor
 
 
;EOF
