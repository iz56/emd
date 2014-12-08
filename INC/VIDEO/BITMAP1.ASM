;bitmap1.asm
 
 
;то же что и в файле bitmap.asm только для одной (первой) строки
 
DrawVideoPageFirstLine:
 
       call     DrawVideoPage.Init
 
       mov      ebx,dword [VideoLinear]
       add      ebx,dword ОТСТУП_СВЕРХУ
 
       mov      [DrawVideoPage.saveEbx],dword ebx ;начальное значение
 
       mov      esi,dword [DrawVideoPage.ArrayChrs80x25]
 
       mov      [DrawVideoPage.saveEsi],dword esi ;начальное значение
 
       call     DrawVideoPage.GetAttr ;сохраняем аттрибуты в буфер отдельно
call DrawVideoPage.GetStr ;и коды символов преобразуем в бит-карту
       call     DrawVideoPage.Draw
 
       ret
 
 
;EOF
