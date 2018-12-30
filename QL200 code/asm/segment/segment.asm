
;experiment purpose: familiar LED static display

;LED display single number "0"

;hardware request:SW S6 set ON, S5 the sixth set ON,the others SW set OFF
 #INCLUDE<P16F877A.INC>            ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
;THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
;LOW power programme OFF,encrypt,4M crystal HS surge.
 ORG    00H                       ;reset entrance address
 NOP                              ;the nop instruction of ICD require
 MOVLW  0FFH                      
 MOVWF  PORTA
 MOVWF  PORTD                    ;clear all display                      
 BSF    STATUS,RP0               ;select BANK1                           
 MOVLW  1FH                      ;set RA5 OUTPUT,the other bits INPUT    
 MOVWF  TRISA                                                            
 CLRF   TRISD                    ;set RD PORT all OUTPUT                 
 MOVLW  06H                                                              
 MOVWF  ADCON1                   ;set A PORT general I/O                 
 BCF    STATUS,RP0               ;BANK0                                  
 MOVLW  0C0H                     ;the code of 0( the common LED is anode)
 MOVWF  PORTD                    ;send to LED display                    
 BCF    PORTA,5                  ;enable LED display                     
                                                                         
LOOP                                                                     
 GOTO   LOOP                     ;stop instruction                       
 END                             ;program end                            
