;THE experiment is produce a simple  watering lamp.

;light 8 lamps of C port in turn(first is RC0,close RC0 and light RC1......)

;THE hardware request:SW S11 all ON.
#include<p16f877A.inc>        ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
;**********************THE definien of user registers********************
count     equ   20h           ;shift times register        
del_va1   equ   0ffh          ;the outside delay parameter 
del_va2   equ   0afh          ;the inside delay parameter  


 org      00h                 ;the address of entrance program 
;**********************main program start***********************
main
 nop                          ;the nop instruction of ICD require                                                                     
 clrf     PORTC               ;clear all C PORT display                                                                               
 banksel  TRISC               ;select I/O direct register                                                                             
 clrf     TRISC               ;set C PORT all OUTPUT                                                                                  
 clrf     STATUS              ;select BANK0                                                                                           
 movlw    .8                                                                                                                          
 movwf    count               ;load cycle times 8( C PORT have 8 bits)                                                                
                                                                                                                                      

 bsf      STATUS,C            ;set carry flag 1,because circle shift is carry circle shift                                                                                                                                                                                
loop                                                                                                                                                                                                                                                                      
 rlf      PORTC,1             ;C PORT left shift 1 bit                                                                                                                                                                                                                    
 call     delay                                                                                                                                                                                                                                                           
 call     delay                                                                                                                                                                                                                                                           
 CALL     delay               ;call three delay programs(ensure brightness and watering lamp flash speed)                                                                                                                                                                 
 bcf      STATUS,C            ;clear carry flag(only a LED light)                                                                                                                                                                                                         
 DECFSZ   count,1             ;judge if a circle end                                                                                                                                                                                                                      
 goto     loop                ;no,continue circle shift                                                                                                                                                                                                                   
 GOTO     main                ;yes,program circle again                                                 

;***********************delay subprogram*************************
delay
 movlw    del_va1             ;the outside delay parameter   
 movwf    30h
 movlw    del_va2             ;the inside delay parameter                     
 movwf    31h
 decfsz   31h,1
 goto     $-1
 decfsz   30h,1
 goto     $-4
 return

;********************program end****************************
 end
