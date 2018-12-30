
;Please open RA4 pull UP, will S10'S NO.4 in the "on", jump J14 all connect.
;*****************THE definiens of  register*****************************
#include<p16f877a.inc>  
 __CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
 #define       RS  PORTA,5           ;COMMNAD/DATA SELECT           
 #DEFINE       RW  PORTA,4           ;READ/WRITE SELECT             
 #DEFINE       E   PORTA,3           ;ENABLE SIGNAL                 
 #DEFINE       PSB PORTA,2           ;PARALLEL/SERIAL SELECT（H/L） 
 #DEFINE       RST PORTA,0           ;RESET SIGNAL                  
 
;-----------------------------------------------
LCD_X          EQU 30H               ;PAGE ADDRESS        
LCD_Y          EQU 31H               ;Y ADDRESS           
COUNT          EQU 32H               ;USED FOR LOOP COUNT 
COUNT1         EQU 33H               ;USED FOR LOOP COUNT 
COUNT2         EQU 34H               ;USED FOR LOOP COUNT 
                                     
POINT          EQU 35H               ;SEARCH TABLE OFFSET
POINT1         EQU 36H               ;SEARCH TABLE OFFSET
POINT2         EQU 37H               ;SEARCH TABLE OFFSET
                                                         
TEMP           EQU 38H               ;TEMPORAY REGISTER  
TEMP1          EQU 39H               ;TEMPORAY REGISTER  
;-----------------------------------------------
 ORG 0000H                           ;RESET ADDRESS                     
 NOP                                 ;THE NOP INSTRUCTION NEEDED BY ICD 
 GOTO   MAIN                         ;JUMP TO MAIN PROGRAM              
;**********************MAIN PROGRAM************************
MAIN
 BANKSEL   TRISA
 CLRF      TRISA                     ;DEFINE PORT A AS OUTPUT
 CLRF      TRISD                     ;DEFINE PORT D AS OUTPUT
 BANKSEL   ADCON1
 MOVLW     06H
 MOVWF     ADCON1                    ;PORT A ARE ALL DIGITAL PORT 
 CLRF      STATUS

 BCF       RST                       ;RESET LCD           
 CALL      DELAY                     ;DELAY FOR SOME TIME 
 BSF       RST                       ;CLEAR RESET SIGNAL  
 NOP
 BSF       PSB                       ;PARALLEL COMMUNICATION 

;**************************INITIALIZATION*********************
 MOVLW     30H                       ;BASIC INSTRUCTION OPERATION                      
 CALL      SEND_I                                                                      
 MOVLW     01H                       ;CLEAR DISPLAY                                    
 CALL      SEND_I                                                                      
 MOVLW     06H                       ;APPOINT THE CURSOR‘S MOVE DIRECTION WHEN RD/WR. 
 CALL      SEND_I
 MOVLW     0CH                      ;ENABLE DISPLAY, DISABLE CURSOR AND BLINK.
 CALL      SEND_I
;***********************display chinese************************
HAN_WR2
 CALL     CLEAR_P                    ;clear display
HAN_WR2A                             ;“深圳乾龙盛电子”
 MOVLW    LOW(TAB1A)                  
 MOVWF    POINT
 MOVLW    HIGH(TAB1A)
 MOVWF    POINT1                     ;get the table's entry address
 MOVLW    0eH                        ;the number of data.(7 chinese character include 14 bytes)
 MOVWF    COUNT 
 MOVLW    81H                        ;page address
 CALL     SEND_I
 CALL     QUSHU                      
HAN_WR2B                             ;“WWW.PIC16.COM”
 MOVLW    LOW(TAB1B)
 MOVWF    POINT
 MOVLW    HIGH(TAB1B)
 MOVWF    POINT1
 MOVLW    10H
 MOVWF    COUNT
 MOVLW    90H
 CALL     SEND_I
 CALL     QUSHU
HAN_WR2C                             ;“TEL0755-28187975”
 MOVLW    LOW(TAB1C)
 MOVWF    POINT
 MOVLW    HIGH(TAB1C)
 MOVWF    POINT1
 MOVLW    10H
 MOVWF    COUNT
 MOVLW    88H
 CALL     SEND_I
 CALL     QUSHU
HAN_WR2D                             ;“FAX0755-28187976”
 MOVLW    LOW(TAB1D)
 MOVWF    POINT
 MOVLW    HIGH(TAB1D)
 MOVWF    POINT1
 MOVLW    10H
 MOVWF    COUNT
 MOVLW    98H
 CALL     SEND_I
 CALL     QUSHU
 CALL     DELAY

 CALL     FLASH                      ;call blink subroutine
 CALL     CLEAR_P                    ;clear display
 GOTO     HAN_WR2                    ;return and display again

;************************pre-write****************************
WR_ZB
 MOVLW  30H
 CALL   SEND_I
 MOVFW  LCD_Y                        ;Y address
 CALL   SEND_I
 MOVFW  LCD_X                        ;page address
 CALL   SEND_I
 RETURN

;*************************blink subroutine*************************
FLASH
 MOVLW  8H                           ;close display
 CALL   SEND_I
 CALL   DELAY1
 MOVLW  0CH                          ;open display
 CALL   SEND_I
 CALL   DELAY1
 CALL   DELAY1
 MOVLW  08H                          ;close display 
 CALL   SEND_I                                      
 CALL   DELAY1                                      
 MOVLW  0CH                          ;open display  
 CALL   SEND_I
 CALL   DELAY1
 CALL   DELAY1
 MOVLW  08H                          ;close display 
 CALL   SEND_I                                      
 CALL   DELAY1                                      
 MOVLW  0CH                          ;open display  
 CALL   SEND_I
 CALL   DELAY1
 CALL   DELAY1
 RETURN
;***********************clear display*******************************
CLEAR_P
 MOVLW  1H                           ;clear display
 CALL   SEND_I
 RETURN
;***********************get data display program**********************
QUSHU
 CLRF   TEMP                         ;clear offset address
QUSHU1
 MOVFW  TEMP
 ADDWF  POINT,0                      ;calculate the offset address.
 MOVWF  POINT2 
 CALL   TAB1                         ;search table
 CALL   SEND_D                       ;send to lcd for display
 INCF   TEMP,1                       ;offset added by 1 and search the next data.
 CALL   DELAY
 DECFSZ COUNT,1
 GOTO   QUSHU1
 RETURN              
 ;************************send data to LCD ***********************
;write data subroutine. 
;RS=1,RW=0,E=high pulse ,D0-D7=data 
;**********************************************************
SEND_D
 MOVWF  TEMP1                        ;temporary save data 
 CALL   CHK_BUSY                     ;check the busy of line 
 BSF    RS
 BCF    RW
 MOVFW  TEMP1
 MOVWF  PORTD                        ;send data 
 BSF    E
 NOP
 NOP
 BCF    E
 RETURN

;************************send command to lcd ***********************
;write instruction sub routine 
;RS=0,RW=0,E=high pulse ,D0-D7=code of instruction 
;**********************************************************
SEND_I
 MOVWF  TEMP1                       ;temporary save data
 CALL   CHK_BUSY                    ;check the busy of line
 BCF    RS
 BCF    RW
 MOVFW  TEMP1
 MOVWF  PORTD                       ;send command 
 BSF    E
 NOP
 NOP
 BCF    E
 RETURN
;************************;check the busy of line********************
;test busy subroutine
;RS=0,RW=1,E=H,D0-D7=status byte
;**********************************************************
CHK_BUSY
 BANKSEL  TRISD
 MOVLW    0FFH
 MOVWF    TRISD                     ;set port D as input 
 CLRF     STATUS
 MOVLW    0FFH
 MOVWF    PORTD
 BCF      RS
 BSF      RW
CHECK_BUSY_1
 NOP
 NOP
 NOP
 BSF      E
 NOP
 NOP
 NOP
 BTFSS    PORTD,7                  ;D7 high indicate busy,low idle.
 GOTO     $+6     
 NOP
 NOP
 NOP
 BCF      E 
 GOTO     CHECK_BUSY_1
 BCF      E
 BANKSEL  TRISD
 CLRF    TRISD                     ;set port d as output 
 CLRF     STATUS
 RETURN
;***************************delay subroutine ***********************
DELAY
 MOVLW   0afH
 MOVWF   20H
 MOVLW   0ffh
 MOVWF   21H
 DECFSZ  21H,1
 GOTO    $-1
 DECFSZ  20H,1
 GOTO    $-5
 RETURN
;***************************delay subroutine 1 ************************
;display blink used
DELAY1
 MOVLW   05H
 MOVWF   22H
 CALL    DELAY
 DECFSZ  22H,1
 GOTO    $-2
 RETURN
;***************************data table *************************
TAB1
 MOVFW   POINT1       
 MOVWF   PCLATH                   
 MOVFW   POINT2
 MOVWF   PCL                
TAB1A
 dt  0C9,0EE         ;深
 dt  0DB,0DA         ;圳
 dt  0C7,0AC         ;乾
 dt  0C1,0FA         ;龙
 dt  0CA,0A2         ;盛
 dt  0B5,0E7         ;电
 dt  0D7,0D3         ;子
 
TAB1B                ;WWW.PIC16.COM
 dt ' ', ' ', 'W', 'W', 'W', '.', 'P', 'I', 'C', '1','6', '.', 'C', 'O', 'M', ' ' 
TAB1C                ;TEL0755-28187975
 dt 'T', 'E', 'L' ,'0' ,'7', '5' ,'5','-', '2', '8','1', '8' ,'7','9' ,'7','5'
TAB1D                ;FAX0755-28187976
 dt 'F', 'A', 'X', '0', '7', '5', '5', '-','2', '8','1', '8', '7', '9', '7', '6'

;***************************source code ended************************
 end
