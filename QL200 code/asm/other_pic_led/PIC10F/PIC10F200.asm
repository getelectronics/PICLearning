;AIM: gpio flow lamp, familiar pic10f200's i/o operation
;gp3 is for vpp and reset pin mclr, so don't be lighted.
;hardware configuration:

;2) off j5/j6 or j7/j8
;3) switch s13 all on.
__config 0x0ffb         ;watch dog off,NOT LOCK,MCLR AS RESET
status    equ   3h      ;define status
gpio      equ   6h      ;frgomr GPIO
cmcon     equ   7h      ;define compare control reg
osccal    equ   5h      ;define clock calculation reg.

 org       00h
main
 clrf      gpio
 movlw     00h
 tris      gpio         ;set GPIO as output
 bcf       osccal,0
 movlw     00h
 option                 ;the upper three instruction define GPIO2 as i/o
 
 
loop
 clrf      gpio
 movlw     01h          ;on GP0
 movwf     gpio
 call      delay
 call      delay
 
 movlw     02h          ;on GP1
 movwf     gpio
 call      delay
 call      delay
 
 movlw     04h         ;on GP2
 movwf     gpio
 call      delay
 call      delay
 goto      loop

delay                  ;delay subroutine
 movlw     0ffh
 movwf     11h
 movlw     0ffh
 movwf     12h
 decfsz    12h,1
 goto      $-1
 decfsz    11h,1
 goto      $-4
 retlw     0h

 end
