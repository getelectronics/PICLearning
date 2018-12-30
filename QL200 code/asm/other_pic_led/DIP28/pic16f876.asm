;AIM: gpio flow lamp, familiar pic16f876's i/o operation
;hardware configuration:
;1) off j5/j6 or j7/j8
;2) switch s11,s13 all on.
#include<p16f876a.inc>          ;include the head file to define the reg.                       
__config 0x1f3a                 ;watch dog off,HS OSC

 org      000h
 goto     main
main
 clrf      porta
 clrf      portb
 clrf      portc                ;CLEAR A/B/C port display
 banksel   trisa
 movlw     00h
 movwf      porta
 movwf      portb
 movwf      portc              ;define A/B/C port as output
 movlw     0x07
 movwf     adcon1              ;set A port as i/o
 clrf       status

 movlw     01h
 movwf     porta               ;on A0
 call      delay
 call      delay
 call      delay
 call      delay

 movlw     02h                 ;on A1
 movwf     porta
 call      delay
 call      delay
 call      delay
 call      delay
 movlw     04h                 ;on A2
 movwf     porta
 call      delay
 call      delay
 call      delay
 call      delay
 movlw     08h                 ;on A3
 movwf     porta
 call      delay
 call      delay
 call      delay
 call      delay
 movlw     10h                ;on A4
 movwf     porta
 call      delay
 call      delay
 call      delay
 call      delay
 movlw     20h               ;on A5
 movwf     porta
 call      delay
 call      delay
 call      delay
 call      delay

 clrf      porta
 clrf      portb             ;clear B port
 movlw     8h
 movwf     20h               ;loop count
 bsf       status,0          ;carry flag set 1.
loop
 rlf       portb,1           ;B port rotate left with carry.
 call      delay             
 call      delay
 call      delay
 call      delay             ;delay some times.
 bcf       status,0          ;clear carry bit.
 decfsz    20h,1             ;check the loop if finished.
 goto      loop              ;no,continue loop
 
 clrf      portb
 clrf      portc            
 bsf       portc,0           ;on
 call      delay                  
 call      delay
 call      delay
 call      delay
 movlw     7h                ;loop count(RC1-RC7)
 movwf     10h               ;the method is same with b port.
 bcf       status,0
loop1
 rlf       portc,1
 call      delay
 call      delay
 call      delay
 call      delay
 bcf       status,0
 decfsz    10h,1
 goto      loop1
 clrf      portc
 goto      main
 

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
