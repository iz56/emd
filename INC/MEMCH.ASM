;memch.asm


MemChk:
;вычисляем размер доступной памяти
pop ax
mov [.saveRet],ax

       mov      eax,dword [EndMemory]
       mov      ebx,dword [StartMemory]
       cmp      eax,ebx
       jb       quit

       sub      eax,ebx

;check minimal size
       cmp      dword eax,MEMORY_MIN
       jb       quit
       shr      eax,1

.MemSizeOk:

      add      eax,dword [StartMemory]

;oткусываем кусок памяти для (vesa-mode3)-видеобуфера
       sub      eax,dword SIZE_VIDEO_BUF+2 ;двоечка!
       mov      dword [VideoBufMemory],eax


       sub      dword eax,SIZE_TXT_BUF ;cut

;инит адрес буфера для вставки и копирования блоков строк
mov [ptrCopyPasteBuffer],dword eax
       mov      [EndMemory],eax ; заканчиваем с памятью


;вычисляем размер доступной памяти2 - еще раз проверяем
       mov      eax,dword [EndMemory]
       sub      eax,dword [StartMemory]
       mov      [SizeMemoryAviable],dword eax

;check minimal size-2
       cmp      dword eax,MEMORY_MIN
       jbe      quit

mov ax,[.saveRet]
push ax
ret
.saveRet dw 0





;EOF
