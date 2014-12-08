;const.asm
 
 
PROGRESS_SPEC_CHAR = 0b0h
 
       CHAR_ON_LINE = 80 ;chars on line
 
       SIZE_VIDEO_BUF = 4096; size for save screen (for vesa mode)
 
;размер буфера для копирования строк
       SIZE_TXT_BUF = 1000*CHAR_ON_LINE
 
 
;minimal work memory size
       MEMORY_MIN = SIZE_VIDEO_BUF+SIZE_TXT_BUF+10000h
 
       LINES_ON_SCR = 25 ;lines on video page
       SEG_VIDEO_MEMORY = 0b800h
 
 
;текущий номер таблицы для фильтра по умолчанию
; IndexCharsetDefault = 5
 
       SIZE_READ_BUF = 512*8
 
       COLOR_HELP_TXT = 7;10000110b
       COLOR_INF_TXT = 7
       COLOR_ASCII_TXT = 3
       COLOR_ASCII_TXT_OFFSET = 2
       COLOR_ASCII_TXT_OFFSET2 = 9
 
;       COLOR_B  = 8;цвет всех рамок для сообщений в программе
 
 
;цвет меток перехода
       COLOR_LABEL_TXT = 6
 
;скорость повтора
       SPEEDREPEAT = 3 ;параметр количество одинаковых нажатий для keyrepeat
       REPEAT_X = 3
 
 
;for fast video drawing
SPACES_7_DWORD = 0x07200720
 
 
;EOF
