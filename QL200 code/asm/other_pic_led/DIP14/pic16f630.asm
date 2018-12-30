;AIM: gpio flow lamp, familiar pic16f630's i/o operation
;gp3 is for vpp and reset pin mclr, so don't be lighted.
;hardware configuration:
;1) clock select OSCC as I/O
;2) off j5/j6 or j7/j8
;3) switch s11,s13 all on.
 #include<p16f630.inc>            ;include the head file to define the reg.
 __config 0x31b4                  ;watch dog off,internal RC,ra4/ra5 AS I/O,NOT LOCK,MCLR AS RESET
 org       00h
 nop
 banksel   trisc
 movlw     00h
 movwf     trisa                  ;A port output
 movwf     trisc                  ;B port output
 banksel   portc
 movlw     07h
 movwf     cmcon                  ;define A port as I/O

loop
 clrf     porta 
 movlw    01h
 movwf    porta                   ;on RA0
 call      delay
 call      delay

 movlw    02h                     ;on RA1
 movwf    porta
 call      delay
 call      delay

 movlw    04h                    ;on RA2
 movwf    porta
 call      delay
 call      delay

 movlw    10h                    ;on RA4
 movwf    porta
 call      delay
 call      delay

 movlw    20h                    ;on RA5
 movwf    porta
 call      delay
 call      delay


 clrf      porta                 ;off A port all lamp
 clrf      portc
 movlw    01h                    ;on RC0
 movwf    portc
 call      delay
 call      delay

 movlw    02h                    ;on RC1
 movwf    portc
 call      delay
 call      delay

 movlw    04h                    ;on RC2
 movwf    portc
 call      delay
 call      delay

 movlw    08h                    ;on RC3
 movwf    portc
 call      delay
 call      delay

 movlw    10h                    ;on RC4
 movwf    portc
 call      delay
 call      delay
 
 movlw    20h                    ;on RC5
 movwf    portc
 call      delay
 call      delay
 clrf     portc
 goto     loop

delay                            ;delay subroutine
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
 
