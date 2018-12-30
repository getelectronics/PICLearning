;AIM: gpio flow lamp, familiar pic16f785's i/o operation
;gp3 is for vpp and reset pin mclr, so don't be lighted.
;hardware configuration:
;1) clock select OSCC as I/O
;2) off j5/j6 or j7/j8
;3) switch s11,s12,s13 all on.
#include<p16f785.inc>          ;include the head file to define the reg.                       
 __config 0x33f4               ;watch dog off,internal RC,ra4/ra5 AS I/O,NOT LOCK,MCLR AS RESET
 org    00h
 nop
 
 banksel  trisc
 clrf     trisc                ;c port output
 clrf     trisa                ;a port output
 clrf     trisb                ;a port output
 clrf     status

loop
 clrf     porta 
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

 movlw    10h                  ;on A4
 movwf    porta
 call      delay
 call      delay

 movlw    20h                  ;on A5
 movwf    porta
 call      delay
 call      delay


 clrf     porta               ;clear A port
 clrf     portb
 movlw    10h                 ;on B4
 movwf    portb
 call      delay
 call      delay

 movlw    20h                 ;on B5
 movwf    portb
 call      delay
 call      delay

 movlw    40h                 ;on B6
 movwf    portb
 call      delay
 call      delay

 movlw    80h                 ;on B7
 movwf    portb
 call      delay
 call      delay


 clrf     portb
 clrf     portc               
 movlw    01h
 movwf    portc              ;on C0
 call      delay
 call      delay

 movlw    02h                ;on C1
 movwf    portc
 call      delay
 call      delay

 movlw    04h                ;on C2
 movwf    portc
 call      delay
 call      delay

 movlw    08h                ;on C3
 movwf    portc
 call      delay
 call      delay

 movlw    10h                ;on C4
 movwf    portc
 call      delay
 call      delay

 movlw    20h                ;on C5
 movwf    portc
 call      delay
 call      delay

 movlw    40h                ;on C6
 movwf    portc
 call      delay
 call      delay

 movlw    80h                ;on C7
 movwf    portc
 call      delay
 call      delay

 goto      loop

delay                        ;
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
