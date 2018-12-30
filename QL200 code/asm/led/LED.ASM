

;THE experiment is to light the LED of RC0                                                 
                                                                                           
;THE hardware request:SW S11 the eighth bit set ON,the others set OFF.                       
 #INCLUDE<P16F877A.INC>          ;
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC

 ORG    00H                      ;the address of entrance program
 NOP                             ;the nop instruction of ICD require
 BSF     STATUS,RP0              ;select BANK1
 MOVLW   0FEH                    ;set RC0 OUTPUT,the other bits INPUT
 MOVWF   TRISC                  
 BCF     STATUS,RP0              ;select BANK0
 BSF     PORTC,0                 ;RC0 OUTPUT high,light LED
LOOP
 GOTO    LOOP                    ;stop MCU
 END                             ;program end
