;video.asm
 
 
       macro    colored
       {
       call     LightText
       }
 
       macro    cls color
       {
       mov      ah,color
       call     ClrScr ;inc\cls16.asm
       }
 
       macro    cursor col,line
       {
       mov      al,col
       mov     byte [x],al
       mov      al,line
       mov     byte [y],al
 
       call     SetCursor
       }
 
       macro    redraw
       {
       call     Redraw_1st_old ;redraw.asm
       }
 
 
 
;EOF
