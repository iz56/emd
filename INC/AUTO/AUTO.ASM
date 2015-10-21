;auto.asm
       
       
       AUTO_COMPARE_TRUE = 0x01
       AUTO_POS_IN_WORD = 2 ;num of chars for action
       AUTO_WORD_SIZE = 8 ;min word size for work it
       SIZE_OF_WORDS_BUF = 80
       
;#1 insert tail
AutoCompletePushChar:
       cmp      byte [AutoComplete.FlagCompare], AUTO_COMPARE_TRUE
       jz       .Yes
       ret      ;exit----------------------[1]
       
.Yes:
       cmp      byte [.Stage],0
       jnz      .nextChar
       
;first time - here processing
       mov      byte [AutoComplete.FlagWork],1
       
       mov      ax, word [AutoComplete.iSaveWord]
       test     ax,ax
       jz       .StopAutoComplete
       
       cmp      al,byte AUTO_WORD_SIZE
       jbe      .StopAutoComplete
       
       sub      al,1
       mov      byte [.Stage],al
       
.nextChar:
       cmp      byte [.Stage],1
       jz       .StopAutoComplete
       
       dec      byte [.Stage]
       jz       .StopAutoComplete
       
       pop      ax ;del ret adr
       
       mov      di,word [AutoComplete.pNextChars]
       dec      di
       add      di,word [.iLastChars]
       inc      word [.iLastChars]
       
       xor      ax,ax
       mov      al,byte [di]
       
;fly to emd.asm label
       jmp      CharAddText ; exit----------------------[2]
       
.StopAutoComplete:
       mov      word [.iLastChars],0
       mov      byte [.Stage],0
       mov      [AutoComplete.FlagCompare],byte 0
       mov      byte [AutoComplete.FlagWork],0 ;ON AutoComplete
       
       mov      [AutoComplete.FlagNewWord],byte 0
       mov      [AutoComplete.iBuffer],byte 0
       
       ret      ;exit----------------------[3]
       
       
.Stage db 0 ;for next chars print (Flag)
.iLastChars dw 0 ;index for last chars in word
       
       
;#2 save word - main fun
AutoComplete:
       cmp      [.FlagWork],byte 0
       jz       .work
       
       ret      ;exit----------------------[1]
       
.work:
       call     .CheckCharsKBD ;if x=a..z , x=A..Z
       jnc      .NoAction
       clc
       
.Action:
       cmp      [.FlagNewWord],byte 0
       jnz      .AddChar
       
       mov      [.FlagNewWord],byte 1
       mov      [.iBuffer],byte 0
       
.AddChar:
       mov      ebx,dword .Buffer
       add      bl,byte [.iBuffer]
       jnc      .m1
       adc      bh,0
.m1:
       mov      [ebx],al
       mov      [.saveChar],al;save it for compare to other char - not repeating
       inc      byte [.iBuffer]
       
       cmp      byte [.iBuffer],AUTO_POS_IN_WORD
       jnz      .testSkip
       
       pusha
       call     .TestWords
       popa
       
.testSkip:
       cmp      byte [.iBuffer],SIZE_OF_WORDS_BUF-1
       jae      .NoAction
       
       ret      ;exit----------------------[2]
       
.NoAction:
       call     .CopyToWordsBuffer
       mov      [.FlagNewWord],byte 0
       mov      [.iBuffer],byte 0
       
       ret      ;exit----------------------[3]
       
       
;------[+]
.CheckRepeatChars:
       mov      bx, .Buffer
       mov      cl,byte [.iBuffer]
.CheckIt:
       mov      al,byte [bx]
       inc      bx
       cmp      al,byte [.saveChar]
       jnz      .OkNotRepeat
       dec      cl
       jnz      .CheckIt
       
       stc
       ret
       
.OkNotRepeat:
       clc
       ret
       
.saveChar db 0
;------[-]
       
;--------[+]
.TestWords:
       mov      [.FlagCompare],byte 0
       
       mov      di,word [.ptrSaveWord]
       mov      si,word .Buffer
       mov      cl,byte 3
       
       mov      al,[si]
; cmp al,byte '.' ;see here for ".label" autocomplete
; jnz .outTest
       
.CompareIt:
       mov      al,[si]
       cmp      al,byte [di]
       jnz      .outTest
       inc      si
       inc      di
       dec      cl
       jnz      .CompareIt
       
       mov      [.pNextChars],word di
       
       call     .CheckRepeatChars
       jc       .NotNeed
       mov      [.FlagCompare],byte AUTO_COMPARE_TRUE
       ret
       
.NotNeed:
       clc
.outTest:
       mov      word [.iSaveWord],0
       ret
;--------[-]
       
       
;------------[+]
.CopyToWordsBuffer:
       push     ax di si cx
       
       mov      di,word [.ptrSaveWord]
       add      di,word [.iSaveWord]
       
       mov      si,word .Buffer
       mov      cl,byte [.iBuffer]
       
       cmp      cl,byte AUTO_WORD_SIZE
       jae      .YesItIs
       
       pop      cx si di ax
       ret
       
.YesItIs:
       
;correct index
       mov      ax,word [.iSaveWord]
       add      al,cl
       mov      word [.iSaveWord],ax
       
.l1:
       mov      al,[si]
       mov      [di],al
       inc      si
       inc      di
       dec      cl
       jnz      .l1
       
       pop      cx si di ax
       
       ret
;------------[-]
       
       
.FlagWork db 0
       
.FlagCompare db 0 ;Flag of = words
.pNextChars dw 0
       
.iBuffer db 0
.Buffer rb SIZE_OF_WORDS_BUF
.FlagNewWord db 0
       
.ptrSaveWord dw bufSaveWord
.iSaveWord dw 0
       
       
;--------------------[+]
.CheckCharsKBD: ;if x=a..z , x=A..Z (0x020 - no char)
       cmp      al,32 ; 0x020, space
       jz       .noChar
       
       cmp      al,127
       jz       .noChar
       
       
       mov      bx,.noCharKeysValues
       mov      cl, .SZ
.l2:
       cmp      ah,byte [bx]
       jz       .noChar
       inc      bx
       dec      cl
       jnz      .l2
       
;.CharOk:
       stc
       ret
       
.noChar:
       clc
       ret
       
.noCharKeysValues db 1,14,15,28,29,42,54,83
       .SZ      = 8 ;size of.noCharKeysValues, bytes
       
;--------------------[-]
       
       
bufSaveWord rb SIZE_OF_WORDS_BUF
       
       
;EOF
       