;error.asm

Err:

.SetCod:
       mov      [.erCod],eax
       ret

.GetCod:
       mov      eax,[.erCod]
       ret

;ret ptr on str
.GetMsg:
       call     .GetCod

       mov      bx,.tableOfMsgPtrs
       shl      ax,1 ;*2
       cmp      ax,word .SIZE_OF_TABLE_MSG_PTRS
       jae      .ErrorTableDebug

       add      bx,ax
       mov      si,[bx]
       ret

;temp---------------------[+]
.ErrorTableDebug:
       mov      si,.msgErr
       ret
.msgErr db 'Error table ptr. See file /inc/error.asm/$'
;temp---------------------[-]


.erCod dd 0

.tableOfMsgPtrs:
dw .msgOk
dw .Usage
dw .InFileOpen
dw .InFileRead
dw .InFileClose
dw .DskFileOpen
dw .DskFileSeek
dw .DskFileRead
dw .DskFileWrite
dw .DskFileClose
dw .fsUsageDebug
dw .fileBig

.SIZE_OF_TABLE_MSG_PTRS = $ -.tableOfMsgPtrs

.msgOk db ' ok.$'
.Usage db ' укажите имя файла с исходным текстом'
db '(файл должен быть в текущем к.)$'
.InFileOpen db ' не могу открыть ваш файл$'
.InFileRead db ' не могу прочитать ваш файл$'
.InFileClose db ' не могу закрыть ваш файл$'
.DskFileOpen db ' не открыть файл-образ диска$'
.DskFileSeek db ' не установить указатель чтения-записи на файл-образ диска$'
.DskFileRead db ' не прочитать файл-образ диска$'
.DskFileWrite db ' не могу записать в файл-образ диска$'
.DskFileClose db ' не могу закрыть файл-образ диска$'
.fsUsageDebug db ' смотри где идёт работа с ФС диска ВМ56$'
.fileBig db 'The (incoming) file is too match.$'





;EOF
