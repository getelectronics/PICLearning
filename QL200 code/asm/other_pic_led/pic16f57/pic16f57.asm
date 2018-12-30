;AIM: gpio flow lamp, familiar pic16f57's i/o operation
;hardware configuration:
;1) off j5/j6 or j7/j8
;2) switch s11,s12,s13 all on.
__config 0x0ffa          ;wdt off£¬HS osc
porta    equ  5h         ;define a port
portb    equ  6h         ;define b port
portc    equ  7h         ;define c port
status   equ  3h         ;define status reg
 
 org      7ffh           ;reset the origin address.
 goto     main
 
 org      00h
main
 clrf      porta
 clrf      portb
 clrf      portc         ;clear A/B/C display
 movlw     00h
 tris      porta
 tris      portb
 tris      portc         ;set A/B/C as output
 

 movlw     01h
 movwf     porta         ;on A0
 call      delay
 call      delay

 movlw     02h           ;on A1
 movwf     porta
 call      delay
 call      delay

 movlw     04h          ;on A2
 movwf     porta
 call      delay
 call      delay

 movlw     08h          ;on A3
 movwf     porta
 call      delay
 call      delay
 
 clrf      porta
 movlw     8h       
 movwf     20h          ;loop count
 bsf       status,0     ;set carry as 1.
loop
 rlf       portb,1      ;B port rotate left with carry
 call      delay
 call      delay
 bcf       status,0     ;clear carry bit.
 decfsz    20h,1        ;judge the 8 loop count.
 goto      loop         ;no, continue loop
 
 clrf      portb
 clrf      portc        ;C port is same with b port.
 movlw     8h
 movwf     10h
 bsf       status,0
loop1
 rlf       portc,1
 call      delay
 call      delay
 bcf       status,0
 decfsz    10h,1
 goto      loop1
 clrf      portc
 goto      main

delay                   ;delay subroutine.
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
