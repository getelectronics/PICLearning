;AIM: gpio flow lamp, familiar pic16f628's i/o operation
;gp3 is for vpp and reset pin mclr, so don't be lighted.
;hardware configuration:
;1) clock select OSCB as I/O
;2) off j5/j6 or j7/j8
;3) switch s11,s13 all on.
;4£©RA4 need pull up resister
#include<p16f628.inc>          ;include the head file to define the reg.                       
 __config 0x3f38               ;watch dog off,internal RC,ra6/ra7 AS I/O,NOT LOCK,MCLR AS RESET
  org    00h
 nop
 
 banksel  trisa
 clrf     trisa                ;A port output
 clrf     trisb                ;B port output
 clrf     status

loop
 clrf     porta                ;off A port all display
 movlw    01h
 movwf    porta                ;on A0
 call      delay
 call      delay

 movlw    02h                  ;on A1
 movwf    porta
 call      delay
 call      delay

 movlw    04h                  ;on A2
 movwf    porta
 call      delay
 call      delay

 movlw    08h                  ;on A3
 movwf    porta
 call      delay
 call      delay

 movlw    10h                 ;on A4
 movwf    porta
 call      delay
 call      delay

 movlw    20h                ;on A5
 movwf    porta
 call      delay
 call      delay

 movlw    40h                ;on A6
 movwf    porta
 call      delay
 call      delay

 movlw    80h                ;on A7
 movwf    porta
 call      delay
 call      delay



 clrf     porta
 clrf     portb
 movlw    01h               ;on B0
 movwf    portb
 call      delay
 call      delay

 movlw    02h               ;on B1
 movwf    portb
 call      delay
 call      delay

 movlw    04h               ;on B2
 movwf    portb
 call      delay
 call      delay

 movlw    08h              ;on B3
 movwf    portb
 call      delay
 call      delay

 movlw    10h              ;on B4
 movwf    portb
 call      delay
 call      delay

 movlw    20h              ;on B5
 movwf    portb
 call      delay
 call      delay

 movlw    40h             ;on B6
 movwf    portb
 call      delay
 call      delay

 movlw    80h             ;on B7
 movwf    portb
 call      delay
 call      delay

 clrf     portb
 goto      loop

delay                     ;delay subroutine
 movlw     0ffh
 movwf     21h
 movlw     0ffh
 movwf     22h
 decfsz    22h,1
 goto      $-1
 decfsz    21h,1
 goto      $-4
 return

 end
