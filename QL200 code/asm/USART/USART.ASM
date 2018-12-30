
;experiment purpose: familiar USART communicate

;"COMM debug assistant" assist work

;COMM debug assistant send data to 877,877 receive data transmit to COMM debug assistant

;;hardware request:SW S7 all  ON,the other  SW OFF
#INCLUDE<P16F877A.INC>             ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
;THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
;LOW power programme OFF,encrypt,4M crystal HS surge.
VAL_US   EQU   .249               ;short delay parameter
VAL_MS   EQU   .200               ;long delay parameter
COUNT    EQU    25H
COUNT_MS EQU    26H
  ORG    00H
  NOP
  GOTO   MAIN
  ORG     04H                      ;interrupt entrance address
 BTFSS   PIR1,RCIF                 ;judge if COMM receive interrupt     
 GOTO    EXIT                      ;no, jump to interrupt end program   
 MOVF    RCREG,0                   ;read data of receive register       
 MOVWF   TXREG                     ;keep in send register and send      
EXIT                                                                    
 RETFIE                                                                 
                                                                        
MAIN                                                                    
  USART                                                                 
 BANKSEL TRISC                     ;select BANK1                        
 BSF     TRISC,7                   ;disconnect RC and USART TX          
 BSF     TRISC,6                   ;disconnect RC and USART RX          
 MOVLW   0CH                       ;load band rate=19.2kbd              
 MOVWF   SPBRG                                                          
 MOVLW   24H                       ;enable USART,set band rate is high  
 MOVWF   TXSTA                                                          
 BSF     PIE1,RCIE                 ;enable receive interrupt            
 CLRF    STATUS                    ;select BANK0                        
 MOVLW   90H                                                            
 MOVWF   RCSTA                     ;enable USART continue receive       
 BSF     INTCON,GIE                ;enable general interrupt            
 BSF     INTCON,PEIE               ;enable outside interrupt            
                                                                        
USART_1                                                                 
 CALL    DELAY_MS                  ;call two delay program              
 CALL    DELAY_MS                                                       
 GOTO    USART_1                      ;                                 

;************************200ms delay program******************
DELAY_MS
 MOVLW   VAL_MS
 MOVWF   COUNT_MS
LOOP_MS
 CALL    DELAY_US
 DECFSZ  COUNT_MS,1
 GOTO    LOOP_MS
 RETURN

;************************100us delay program**************
DELAY_US
 MOVLW   VAL_US
 MOVWF   COUNT
LOOP_US
 NOP
 DECFSZ  COUNT,1
 GOTO    LOOP_US
 RETURN

DELAY_S
 MOVLW   0FFH
 MOVWF   50H
 CALL    DELAY_MS
 DECFSZ  50H,1
 GOTO    $-2
 RETURN
 END
