
;experiment purpose: familiar some LED dynamic scan display

;six LED display 0123456 six numbers from left to right

;hardware request:SW S5,S6 all set ON,the other SW all set OFF 
 #include<p16f877A.inc>       ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
;THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
;LOW power programme OFF,encrypt,4M crystal HS surge.
ORG     00H                  ;reset entrance address
 NOP                          ;the nop instruction of ICD require
 MOVLW   0FFH  
 MOVWF   PORTA
 MOVWF   PORTD                ;clear all display                
 BSF     STATUS,RP0           ;select BANK1                     
 CLRF    TRISA                ;set A PORT OUTPUT                
 CLRF    TRISD                ;set D PORT OUTPUT                
 MOVLW   06H                                                    
 MOVWF   ADCON1               ;set A PORT general I/O PORT      
 BCF     STATUS,RP0           ;BANK0                            
LOOP                                                            
 MOVLW   0                    ;display 0                        
 CALL    TABLE                                                  
 MOVWF   PORTD                                                  
 BCF     PORTA,0                                                
 CALL    DELAY                                                  
 BSF     PORTA,0                                                
                                                                
 MOVLW   1                    ;display 1                        
 CALL    TABLE                                                  
 MOVWF   PORTD                                                  
 BCF     PORTA,1                                                
 CALL    DELAY                                                  
 BSF     PORTA,1                                                
                                                                
 MOVLW   2                    ;display 2                        
 CALL    TABLE
 MOVWF   PORTD
 BCF     PORTA,2
 CALL    DELAY
 BSF     PORTA,2

 MOVLW   3                    ;display 3     
 CALL    TABLE                               
 MOVWF   PORTD                               
 BCF     PORTA,3                             
 CALL    DELAY                               
 BSF     PORTA,3                             
                                             
 MOVLW   4                    ;display 4     
 CALL    TABLE                               
 MOVWF   PORTD                               
 BCF     PORTA,4                             
 CALL    DELAY                               
 BSF     PORTA,4                             
                                             
 MOVLW   5                    ;display 5     
 CALL    TABLE                               
 MOVWF   PORTD                               
 BCF     PORTA,5                             
 CALL    DELAY                               
 BSF     PORTA,5                             
                                             
 GOTO    LOOP                 ;circle display

;**************check table subprogram*******************
TABLE
 ADDWF   PCL,1                ;instruction register add excursion address 
 RETLW   0C0H                 ;the code of 0( the common LED is anode)    
 RETLW   0F9H                 ;the code of 1                              
 RETLW   0A4H                 ;the code of 2                              
 RETLW   0B0H                 ;the code of 3                              
 RETLW   99H                  ;the code of 4                              
 RETLW   92H                  ;the code of 5                              

;**************delay subprogram*****************************
DELAY
 MOVLW   0FFH
 MOVWF   20H
 DECFSZ  20H,1
 GOTO    $-1
 RETURN
 END                          ;program end      
