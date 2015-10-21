;vesa16.asm
 
;set video mode
 
;call BIOS for set video mode
;work in real cpu mode
 
;list of calls:
;set_VESA_mode - VESA
;SetTxtVMode - text
 
;vesa_mode = 101h ;640x480x256 8-bit
;vesa_mode = 4114h ;600x800 16-bit
       vesa_mode = 4115h ;600x800 32-bit
;vesa_mode = 4101h
 
       mode_info = buf ;emd.asm
 
PotentialModes600_800_32:
dd 4115h
dd 4122h
 
CheckMode:
       mov      di,word mode_info
       mov      ax,4F01h
       int      10h
 
       mov      al,byte [mode_info+25]
       cmp      al,32
       jnz      .notOk
       movzx    eax,word [mode_info+12h]
       cmp      eax,800
       jnz      .notOk
 
       movzx    eax,word [mode_info+14h]
       cmp      eax,600
       jnz      .notOk
       clc
       ret
 
.notOk:
       stc
 
       ret
 
set_VESA_mode:
 
       push     ds
       pop      es
 
       mov      bx,word PotentialModes600_800_32
       add      bx,4
       mov      ecx,dword [bx]
       call     CheckMode
       jnc      .SetIt
 
 
       mov      bx,word PotentialModes600_800_32
       mov      ecx,dword [bx]
       call     CheckMode
       jnc      .SetIt
 
 
       jmp      .error
 
 
.SetIt:
       mov      ebx,dword vesa_mode;4101h
       mov      eax,4F02h
       int      10h
       or       ah,ah
       jnz      .error
 
; movzx eax,word [mode_info+10h]
; mov [video_pitch],eax
; movzx eax,word [mode_info+12h]
; mov [video_width],eax
; movzx eax,word [mode_info+14h]
; mov [video_height],eax
       mov      eax,dword [mode_info+28h]
       mov      [VideoLinear],eax
       test     eax,eax
       jz       .error
 
; mov [video_granularity],0
 
       clc
       ret
 
.error:
       stc
       ret
 
 
SetTxtVMode:
       mov      word ax,3 ;text mode
       int      10h
       ret
 
;VideoLinear dd ? ; address of video linear memory
;video_pitch dd ? ; bytes per line in video memory
;video_width dd ? ; width of video screen
;video_height dd ? ; height of video screen
;video_granularity dw ? ; granularity of video memory
;video_window dw ? ; number of video memory window
;video_window_select dd ? ; window positioning function
 
;align 4
;mode_info rb 256 ; VESA video mode information
 
 
;EOF
