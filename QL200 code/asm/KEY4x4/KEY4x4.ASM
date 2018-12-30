
;experiment purpose: familiar how to scan key matrix

;program without process key shake,not think multi-keys pressed at the same time too.

;the lowest LED display corresponding key( such as press K10 display 10,press K25 display 25)

;if no key pressed display FF

;hardware request:SW S4 ON ,S6 ON,S5 5-6 bits ON,the others OFF
#INCLUDE<P16F877a.INC>             ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
;THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
;LOW power programme OFF,encrypt,4M crystal HS surge.
; ERRORLEVEL -302                  ;wipe off the ERROR information of select BANK 
;************************define user registers***************************
BUFFER   EQU  20H                 ;keep the result of read PORT                                            
KEY      EQU  21H                 ;press key code of the start key in the same row                         
VALUE    EQU  22H                 ;key code                                                                
DISPLAYL EQU  23H                 ;the high byte of key code                                               
DISPLAYH EQU  24H                 ;the low byte of key code                                                
                                                                                                           
;*******************program entrance address***********************
 ORG 00H                          ;reset address                              
 NOP                              ;the nop instruction of ICD require         
  GOTO  MAIN                      ;jump to main program address               

;********************DATA TABLE***************************
TABLE       
 ADDWF   PCL,1                    ;PC add excursion address
            RETLW 0C0H            ;the code of 0                                      
            RETLW 0F9H            ;the code of 1           
            RETLW 0A4H            ;the code of 2           
            RETLW 0B0H            ;the code of 3           
            RETLW 99H             ;the code of 4           
            RETLW 92H             ;the code of 5           
            RETLW 82H             ;the code of 7           
            RETLW 0F8H            ;the code of 8           
            RETLW 80H             ;the code of 9           
            RETLW 98H             ;the code of f           
	    RETLW 8EH             ;

;*******************main program****************************
MAIN
 MOVLW   0FFH
 MOVWF   PORTD                    ;close all display                         
 MOVWF   PORTC                    ;                                          
 BANKSEL TRISC                    ;select I/O direct register                
 CLRF    TRISD                    ;set D port OUTPUT                         
 MOVLW   0FH                                                                 
 MOVWF   TRISA                    ;A PORT low 4 bits INPUT,high 4 bits OUTPUT
 MOVLW   0FH                                                                 
 MOVWF   TRISC                    ;C PORT low 4 bits INPUT,high 4 bits OUTPUT
 BANKSEL ADCON1                                                              
 MOVLW   06H                                                                 
 MOVWF   ADCON1                   ;A PORT is general I/O PORT                
 CLRF    STATUS                   ;BANK0                                     
 MOVLW   0FFH                                                                
 MOVWF   PORTA                    ;close all display                         
                                                                             
LOOP                                                                         
 CALL    SCAN                     ;call key scan subprogram                  
 CALL    CHANGE                   ;call get key code subprogram              
 CALL    DISPLAY                  ;call display subprogram                   
 GOTO    LOOP                     ;circle work                               

;*******************key scan subprogram*************************
SCAN
 CLRF    KEY
 CLRF    VALUE
 MOVLW   B'11101111'                               
 MOVWF   PORTC                     ;RC4 OUTPUT low,the others high                     
 NOP                                                                                   
 MOVFW   PORTC                     ;read PORT C to W                                   
 ANDLW   0FH                       ;throw off high 4 bits                              
 XORLW   0FH                       ;judge if a key pressed(if have,PORT C state not 0F)
 BTFSC   STATUS,Z                                                                      
 GOTO    NEXT                      ;no key pressed                                     
 MOVFW   PORTC                     ;have,temporary keep C PORT state                   
 MOVWF   BUFFER                                                                        
 MOVLW   0H                        ;pressed key is at the first line                   
 MOVWF   KEY                                                                           
 GOTO    SCAN_END                  ;jump to scan end                                   
                                                                                       
NEXT                                                                                   
 MOVLW   B'11011111'                                                                   
 MOVWF   PORTC                     ;RC5 OUTPUT low,the others high                     
 NOP                                                                                   
 MOVFW   PORTC                     ;read PORT C to W                                   
 ANDLW   0FH                       ;throw off high 4 bits                              
 XORLW   0FH                       ;judge if a key pressed                             
 BTFSC   STATUS,Z                                                                      
 GOTO    NEXT1                     ;no                                                 
 MOVFW   PORTC                     ;have,temporary keep C PORT state                   
 MOVWF   BUFFER                                                                        
 MOVLW   4H                        ;pressed key is at the second line                  
 MOVWF   KEY                                                                           
 GOTO    SCAN_END                  ;jump to scan end                                   
                                                                                       
NEXT1                                                                                  
 MOVLW   B'10111111'                                                                   
 MOVWF   PORTC                     ;RC6 OUTPUT low,the others high                     
 NOP                                                                                   
 MOVFW   PORTC                     ;read PORT C to W                                   
 ANDLW   0FH                       ;throw off high 4 bits                              
 XORLW   0FH                       ;judge if a key pressed                             
 BTFSC   STATUS,Z                                                                      
 GOTO    NEXT2                     ;no                                                 
 MOVFW   PORTC                     ;have,temporary keep C PORT state                   
 MOVWF   BUFFER                                                                        
 MOVLW   8H                        ;pressed key is at the third line                   
 MOVWF   KEY                                                                           
 GOTO    SCAN_END                  ;jump to scan end                                   
                                                                                       
NEXT2                                                                                  
 MOVLW   B'01111111'                                                                   
 MOVWF   PORTC                     ;RC7 OUTPUT low,the others high                     
 NOP                                                                                   
 MOVFW   PORTC                     ;read PORT C to W                                   
 ANDLW   0FH                       ;throw off high 4 bits                              
 XORLW   0FH                       ;judge if a key pressed                             
 BTFSC   STATUS,Z                                                                      
 GOTO    NEXT3                     ;no                                                 
 MOVFW   PORTC                     ;have,temporary keep C PORT state                   
 MOVWF   BUFFER                                                                        
 MOVLW   0CH                       ;pressed key is at the fourth line                  
 MOVWF   KEY                                                                           
 GOTO    SCAN_END                  ;jump to scan end                                   
                                                                                       
NEXT3                                                                                  
 MOVLW   0FFH                      ;all scan ,no key pressed                           
 MOVWF   KEY                       ;use FF as no key pressed sign                      
                                                                                       
SCAN_END                                                                               
 RETURN                            ;program return                                     
                                                                                       
CHANGE                                                                                 
 CLRF    VALUE                     ;clear key code register                            
 BTFSS   BUFFER,3                  ;judge if read RC3 is 0                             
 GOTO    CHANG1                    ;yes,jump to CHANG1                                 
 BTFSS   BUFFER,2                  ;no,judge if read RC2 is 0                          
 GOTO    CHANG2                    ;yes,jump to CHANG2                                 
 BTFSS   BUFFER,1                  ;no,judge if read RC1 is 0                          
 GOTO    CHANG3                    ;yes,jump to CHANG3                                 
 BTFSS   BUFFER,0                  ;no,judge if read RC0 is 0                          
 GOTO    CHANG4                    ;yes,jump to CHANG4                                 
 GOTO    CHANG_END                 ;no,jump to program end                             
CHANG1                                                                                 
 MOVLW   0H                                                                            
 MOVWF   VALUE                     ;pressed key is at the first row                    
 GOTO    CHANG_END                                                                     
CHANG2                                                                                 
 MOVLW   1H                                                                            
 MOVWF   VALUE                     ;pressed key is at the second row                   
 GOTO    CHANG_END                                                                     
CHANG3                                                                                 
 MOVLW   2H                        ;pressed key is at the third row                    
 MOVWF   VALUE                                                                         
 GOTO    CHANG_END                                                                     
CHANG4                                                                                 
 MOVLW   3H                        ;pressed key is at the fourth row                   
 MOVWF   VALUE                                                                         
CHANG_END                                                                              
 MOVFW   KEY                       ;the line code add the row code is the key code     
 ADDWF   VALUE,1                                                                       
 CLRF    KEY                                                                           
 CLRF    BUFFER                                                                        
 RETURN                            ;program return                                     
                                                                                       
;********************display subprogram*************************
DISPLAY
 CLRF    DISPLAYH                  ;clear key code high byte                           
 INCF    DISPLAYH,1                ;clear key code low byte                            
 CLRF    DISPLAYL                 
 MOVLW   0FFH
 XORWF   VALUE,0                 ;judge the key code is ff                
 BTFSC   STATUS,Z                                                         
 GOTO    DISPLAY_F               ; yes,no key pressed,display FF as sign  
 MOVFW   VALUE                                                            
 MOVWF   DISPLAYL                ;key code temporary keep in DISPLAYL     
 MOVLW   0AH                                                              
 SUBWF   VALUE,0                 ;judge if  key code bigger than 10       
 BTFSS   STATUS,C                                                         
 GOTO    DISPLAY_END             ;no                                      
 MOVLW   0AH                     ;yes, key code sub 10                    
 SUBWF   VALUE,0                                                          
 MOVWF   DISPLAYL                ;keep in key code low byte               
 INCF    DISPLAYH              ;key code high byte add 1                  
 GOTO    DISPLAY_END
DISPLAY_F
 MOVLW   0AH                      ;the excursion address of f                           
 MOVWF   DISPLAYL                 ;key code high byte and low byte all are F            
 MOVWF   DISPLAYH                                                                       
DISPLAY_END                                                                             
 MOVFW   DISPLAYH                 ;display key code high byte                           
 CALL    TABLE                    ;get key code high byte                               
 MOVWF   PORTD                    ;send to D PORT                                       
 BCF     PORTA,4                  ;enable LED display                                   
 CALL    DELAY                    ;delay some time,ensure enough brightness             
 BSF     PORTA,4                  ;close display                                        
 MOVFW   DISPLAYL                 ;display key code low byte                            
 CALL    TABLE                    ;get key code low byte                                
 MOVWF   PORTD                    ;send to D PORT                                       
 BCF     PORTA,5                  ;enable LED display                                   
 CALL    DELAY                    ;delay some time                                      
 BSF     PORTA,5                  ;close display                                        
 RETURN                           ;program return                                       
                                                                                        
;*******************delay subprogram******************************
DELAY                                                             
 MOVLW   0FH                                                      
 MOVWF   30H                                                      
 MOVLW   0FFH                                                     
 MOVWF   31H                                                      
 DECFSZ  31H,1                                                    
 GOTO    $-1                                                      
 DECFSZ  30H,1                                                    
 GOTO    $-5                                                      
 RETURN                                                           
;*******************program end******************************     
 END                                                              
