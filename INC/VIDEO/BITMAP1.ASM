;bitmap1.asm
 
 
;� �� �� � � 䠩�� bitmap.asm ⮫쪮 ��� ����� (��ࢮ�) ��ப�
 
DrawVideoPageFirstLine:
 
       call     DrawVideoPage.Init
 
       mov      ebx,dword [VideoLinear]
       add      ebx,dword ������_������
 
       mov      [DrawVideoPage.saveEbx],dword ebx ;��砫쭮� ���祭��
 
       mov      esi,dword [DrawVideoPage.ArrayChrs80x25]
 
       mov      [DrawVideoPage.saveEsi],dword esi ;��砫쭮� ���祭��
 
       call     DrawVideoPage.GetAttr ;��࠭塞 ���ਡ��� � ���� �⤥�쭮
call DrawVideoPage.GetStr ;� ���� ᨬ����� �८�ࠧ㥬 � ���-�����
       call     DrawVideoPage.Draw
 
       ret
 
 
;EOF
