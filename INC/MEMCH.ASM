;memch.asm


MemChk:
;����塞 ࠧ��� ����㯭�� �����
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

;o���뢠�� ��᮪ ����� ��� (vesa-mode3)-���������
       sub      eax,dword SIZE_VIDEO_BUF+2 ;����窠!
       mov      dword [VideoBufMemory],eax


       sub      dword eax,SIZE_TXT_BUF ;cut

;���� ���� ���� ��� ��⠢�� � ����஢���� ������ ��ப
mov [ptrCopyPasteBuffer],dword eax
       mov      [EndMemory],eax ; �����稢��� � �������


;����塞 ࠧ��� ����㯭�� �����2 - �� ࠧ �஢��塞
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
