;AIM: gpio flow lamp, familiar pic12f508's i/o operation
;gp3 is for vpp and reset pin mclr, so don't be lighted.
;hardware configuration:
;1) clock select OSCC as I/O
;2) off j5/j6 or j7/j8
;3) switch s13 all on.
 __config 0x0ffa              ;watch dog off,internal RC,GO0/GP1 AS I/O,NOT LOCK,MCLR AS RESET
status        equ    3        ;STATUS REG
gpio          equ    6        ;I/O REG

 org          00h
main
 clrf    gpio
 movlw   00h
 tris    gpio
 movlw   00h
 option                       ;off GPIO2 clock input,as i/o

loop
 clrf     gpio
 movlw    01h                 ;on GP0
 movwf    gpio
 call      delay
 call      delay

 movlw    02h                 ;on GP1
 movwf    gpio
 call      delay
 call      delay

 movlw    04h                 ;on GP2
 movwf    gpio
 call      delay
 call      delay

 movlw    10h                 ;on GP4
 movwf    gpio
 call      delay
 call      delay

 movlw    20h                 ;on GP5
 movwf    gpio
 call      delay
 call      delay
 goto      loop

delay                         ;delay subroutine
 movlw     0ffh
 movwf     11h
 movlw     0ffh
 movwf     12h
 decfsz    12h,1
 goto      $-1
 decfsz    11h,1
 goto      $-4
 retlw     0

 end
