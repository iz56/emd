;msgerr.asm
 
MAX_MSGS_ERRORS_NUM = 11
 
 
TablePtrMsgErr:
dw .MsgErrReadFile
dw .MsgErrReadOpenFile
dw .MsgErrSizeFile
dw .MsgErr
dw .MsgErr
dw .MsgErr
dw .MsgErrWriteCreateFile
dw .MsgErrWriteWriteFile ;8
dw .MsgErrWriteDeleteFile ;9
dw .MsgErrWriteCloseFile ;10
dw .MsgErrWriteUserAbort ;11
 
;
 
 
.MsgErrSizeFile:
db 0f4h ,026h ,054h ,01fh ,018h ,060h ,03ah ,04bh ,0a3h ,02ch
 
.MsgErrWriteCreateFile:
db 0ech ,059h ,0f9h ,002h ,064h ,08ah ,0dah ,000h ,0eah ,072h ,08ah ,000h
db 07ch ,01fh ,046h ,01fh ,025h ,03ah ,0c0h ,0a8h
 
.MsgErrReadFile:
db 022h ,022h ,090h ,060h ,0f4h ,026h ,052h ,01fh ,06ch ,01fh ,0c0h ,0a8h
 
 
.MsgErrReadOpenFile:
db 022h ,022h ,090h ,060h ,045h ,060h ,0f6h ,058h ,0c6h ,02bh ,025h
db 03ah ,0c0h ,0a8h
 
 
.MsgErr:
db 07bh ,085h ,0efh ,059h ,085h ,057h ,05fh ,073h ,0b8h ,074h
 
.MsgErrWriteWriteFile:
db 0feh ,076h ,045h ,01fh ,05fh ,073h ,080h ,070h ,099h ,092h ,0c8h
db 07dh ,0f4h
db 026h ,078h ,023h ,0feh ,076h ,045h
db 01fh ,05fh ,073h ,080h ,070h ,099h ,092h ,0c8h
 
.MsgErrWriteDeleteFile:
db 0ech ,059h ,0f9h ,002h ,064h ,08ah ,0dah ,000h ,0eah ,072h ,0a5h ,000h ,0dch
db 04bh ,046h ,01fh ,025h ,03ah ,0c0h ,0a8h ,0ech ,059h ,0f9h ,002h ,064h
db 08ah ,0dah
 
.MsgErrWriteCloseFile:
db 081h ,051h ,055h ,000h ,03fh ,002h ,013h
db 07dh ,0b5h ,009h ,005h ,0afh ,05fh
db 073h ,083h ,070h ,06bh ,04dh ,046h ,01fh
db 025h ,03ah ,0c0h ,0a8h ,081h ,051h ,055h
 
.MsgErrWriteUserAbort:
db 081h ,051h ,055h ,000h ,03fh ,002h ,013h ,07dh ,0b5h ,009h ,015h ,0afh ,09ah
db 077h ,02ah ,000h ,0a4h ,060h ,0c0h ,0a8h ,081h ,051h ,055h ,000h ,03fh ,002h
db 013h
 
 
;EOF
