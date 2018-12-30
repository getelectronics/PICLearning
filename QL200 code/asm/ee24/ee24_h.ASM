;experiment purpose: familiar MSSP communication protocol

;when key RB0 press,write six continuous data in six continuous registers

;when write finished,the LED display single 0 to indicate finished.

;when key RB1 press,read EEPROM  in six continuous registers

;the result of reading send to LED display

;hardware request: SW S2¡¢S5¡¢S6 all set ON, S1 bit6-7 set ON,
#include<p16f877a.inc>        ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
 ERRORLEVEL -302
SDA       EQU   4              ;data I/O
SCL       EQU   3              ;clock I/O
DATA_W    EQU   75H            ;send data register
DATA_R    EQU   76H            ;receive data register
DL1       EQU   77H            ;delay register
DL2       EQU   78H            ;delay register

ADDRESS   EQU   0AH             ;the start address of 2401EEPROM
VALUE     EQU    0H             ;the start address of data which will write in 2401EEPROM

COUNT     EQU   30H
TEMP1     EQU   31H           ;the register of keep the result read from 2401EEPROM
TEMP2     EQU   32H

	ORG    0                   ;reset entrance address
    NOP
    GOTO   MAIN

TABLE       
               ADDWF   PCL,1                    ;PC add excursion address
               RETLW       0C0H          ;0
               RETLW       0F9H          ;the code of 1
               RETLW       0A4H          ;the code of 2
               RETLW       0B0H          ;the code of 3
               RETLW       99H           ;the code of 4
               RETLW       92H           ;the code of 5
	           RETLW       082H 	     ;6
	           RETLW       0F8H 	     ;7
	           RETLW       080H 	     ;8
	           RETLW       090H 	     ;9
               RETLW       88H           ;A
               RETLW       083H          ;b
               RETLW       0C6H          ;c 
               RETLW       0A1H          ;d
               RETLW       086H          ;E
               RETLW       08EH          ;F
               RETLW       0FFH
MAIN
 	NOP                        ;the nop instruction of ICD require
    CLRF   PCLATH              ;ensure program in page 0
    CALL   INIT_I2C            ;call IIC initialize program
    CLRF   DATA_R              ;clear receive data register
    MOVLW  VALUE
    MOVWF  DATA_W              ;keep the waiting for write data in register
EE2401_WRITE
    BTFSC  PORTB,0
    GOTO   $+7
    CALL   WRITE               ;call write EEPROM subprogram
    MOVLW  0A4H
    MOVWF  PORTD
    MOVLW  0FEH
    MOVWF  PORTA                ;display 0
    GOTO   $
EE2401_READ
   ; CALL   DELAY10MS           ;delay some time to ensure finished  write EEPROM
    BTFSC  PORTB,1
    GOTO   MAIN
    CALL   READ                ;call read EEPROM subprogram
    CALL   DISPLAY             ;call display subprogram
    GOTO   $-1                 

;***********************write EEPROM subprogram****************************
;entrance parameter£ºDATA_W
;exit parameter£ºno
WRITE
    CALL   I2C_IDLE            ;judge if EEPROM IDLE
    BANKSEL SSPCON2            
    BSF    SSPCON2,SEN         ;start signal
    BANKSEL PIR1
    BTFSS  PIR1,SSPIF          ;wait for finish start
    GOTO   $-1

    MOVLW  0A0H                ;send  control byte
    BANKSEL SSPBUF
    MOVWF  SSPBUF
    CALL   WRTACKTEST          ;wait for responsion

    BANKSEL SSPSTAT
    BTFSC   SSPSTAT,BF         ;check register full
    GOTO    $-1
    MOVLW   ADDRESS            ;the EEPROM address where will write data
    BANKSEL SSPBUF
    MOVWF   SSPBUF
    CALL    WRTACKTEST         ;wait for responsion
    
    CLRF    STATUS
    MOVLW   6H
    MOVWF   COUNT
    BANKSEL SSPSTAT
    BTFSC   SSPSTAT,BF         ;check register full
    GOTO    $-1
WRITE_1
    INCF    DATA_W,1
    MOVFW   DATA_W             ;the data which will write in EEPROM
    BANKSEL SSPBUF
    MOVWF   SSPBUF
    CALL    WRTACKTEST         ;wait for responsion
    BANKSEL PIR1
    BCF     PIR1,SSPIF         ;clear interrupt flag bit
    DECFSZ  COUNT,1
    GOTO    WRITE_1

    BANKSEL SSPCON2
    BSF     SSPCON2,PEN        ;stop signal
    BANKSEL PIR1
    BCF     PIR1,SSPIF         ;wait for finish stop
    RETURN                     ;program return
 
;***********************read EEPROM subprogram****************************
;entrance parameter£ºno
;exit parameter:six registers from DATA_R
READ
   MOVLW    60H
   MOVWF    FSR
   MOVLW    6
   MOVWF    COUNT
  
   CALL     I2C_IDLE           ;judge if EEPROM IDLE
   BANKSEL  PIR1
   BCF      PIR1,SSPIF         ;clear interrupt flag bit
   BANKSEL  SSPCON2
   BSF      SSPCON2,SEN        ;start signal
   BANKSEL  PIR1
   BTFSS    PIR1,SSPIF         ;wait for finish start
   GOTO     $-1

   MOVLW    0A0H               ;send  control byte
   BANKSEL  SSPBUF
   MOVWF    SSPBUF
   CALL     WRTACKTEST         ;wait for responsion
   
   MOVLW    ADDRESS            ;the EEPROM address where will read data
   BANKSEL  SSPBUF
   MOVWF    SSPBUF
   CALL     WRTACKTEST         ;wait for responsion
   CALL     DELAY10MS          ;call delay subprogram

   CALL     I2C_IDLE           ;judge if EEPROM IDLE
   BANKSEL  PIR1
   BCF      PIR1,SSPIF         ;clear interrupt flag bit
   BANKSEL  SSPCON2
   BSF      SSPCON2,RSEN       ;start signal
   BANKSEL  PIR1
   BTFSS    PIR1,SSPIF         ;wait for finish start
   GOTO     $-1

   MOVLW    0A1H               ;send  control byte
   BANKSEL  SSPBUF
   MOVWF    SSPBUF
   CALL     WRTACKTEST         ;wait for responsion
   BANKSEL  PIR1
   BCF      PIR1,SSPIF         ;clear interrupt flag bit
READ_1   
   BANKSEL  SSPCON2
   BSF      SSPCON2,RCEN       ;start RXD
   
   BANKSEL  PIR1 
   BCF      PIR1,SSPIF         ;clear interrupt flag bit
   BTFSS    PIR1,SSPIF         ;wait for finish receive
   GOTO     $-1
  
   BANKSEL  SSPBUF
   MOVFW    SSPBUF
 ;  MOVWF    DATA_R             ;keep data in specify receive register
   CLRF     STATUS
   MOVWF    INDF
   BANKSEL  PIR1
   BCF      PIR1,SSPIF         ;clear interrupt flag bit
   INCF     FSR,1
   DECF     COUNT,1
   BTFSC    STATUS,Z
   GOTO     READ_2
   BANKSEL  SSPCON2            
   BCF      SSPCON2,ACKDT      ;clear responsion signal
   BSF      SSPCON2,ACKEN      ;start responsion signal
   BANKSEL  PIR1
   BTFSS    PIR1,SSPIF         ;wait for finish responsion
   GOTO     $-1
   GOTO     READ_1
READ_2
   BANKSEL  SSPCON2            
   BSF      SSPCON2,ACKDT      ;set responsion signal
   BSF      SSPCON2,ACKEN      ;start responsion signal
   BANKSEL  PIR1
   BTFSS    PIR1,SSPIF         ;wait for finish responsion
   GOTO     $-1
  
   BANKSEL  SSPCON2
   BSF      SSPCON2,PEN        ;stop signal
   BANKSEL  PIR1
   BTFSS    PIR1,SSPIF         ;wait for finish stop
   GOTO     $-1
   BCF      PIR1,SSPIF         ;clear interrupt flag bit
   RETURN                      ;program return

;********************general line initialize subprogram***************************
INIT_I2C
   CLRF     STATUS
   MOVLW    0FFH
   MOVWF    PORTD
   BANKSEL  ADCON1
   MOVLW    07H
   MOVWF    ADCON1
   BANKSEL  TRISC
   MOVLW    0FFH
   MOVWF    TRISB
   CLRF     TRISA
   CLRF     TRISD
   BSF      TRISC,SDA          
   BSF      TRISC,SCL          ;set SDA and SCL INPUT,which will be autocontroled by EEPROM
   BANKSEL  SSPADD
   MOVLW    9
   MOVWF    SSPADD             ;set baud rate 100kbd
   BCF      SSPSTAT,6          ;select input electricity follow EEPROM criterion
   BSF      SSPSTAT,7          ;close control conversion
   BANKSEL  SSPCON
   MOVLW    38H
   MOVWF    SSPCON             ;set control register
   RETURN                      ;program return
;*********************check responsion signal subprogram************************
WRTACKTEST
   BANKSEL  PIR1
   BCF      PIR1,SSPIF         ;clear interrupt flag bit
   BTFSS    PIR1,SSPIF         ;judge if interrupt flag bit is 1
   GOTO     $-1                ;wait for interrupt flag bit is 1
   RETURN                      ;program return   

;*********************judge if EEPROM IDLE subprogram*************************
I2C_IDLE
   BANKSEL  SSPSTAT
   BTFSC    SSPSTAT,R_W        ;check if EEPROM is sending 
   GOTO     $-1                ;wait for finish send
   BANKSEL  SSPCON2
   MOVFW    SSPCON2            ;read SSPCON2   
   ANDLW    1FH                ;throw off the highest 3 bit 
   BTFSS    STATUS,Z           ;if 5 state bit all are 0
   GOTO     $-3                ;no,the general line is busy,circle check
   RETURN                      ;program return

;**********************delay subprogram******************************
DELAY10MS
   MOVLW   0CH
   MOVWF   DL1
DELAY2
   MOVLW   0FFH
   MOVWF   DL2
DELAY1
   DECFSZ  DL2,1
   GOTO    DELAY1
   DECFSZ  DL1,1
   GOTO    DELAY2
   RETURN
;***********************display subprogram****************************
;entrance parameter£ºsix registers from DATA_R
;exit parameter£ºno
DISPLAY
   MOVFW   60H
   CALL    TABLE
   MOVWF   PORTD
   BCF     PORTA,0
   CALL    DELAY10MS
   BSF     PORTA,0

   MOVFW   61H
   CALL    TABLE
   MOVWF   PORTD
   BCF     PORTA,1
   CALL    DELAY10MS
   BSF     PORTA,1

   MOVFW   62H
   CALL    TABLE
   MOVWF   PORTD
   BCF     PORTA,2
   CALL    DELAY10MS
   BSF     PORTA,2

   MOVFW   63H
   CALL    TABLE
   MOVWF   PORTD
   BCF     PORTA,3
   CALL    DELAY10MS
   BSF     PORTA,3

   MOVFW   64H
   CALL    TABLE
   MOVWF   PORTD
   BCF     PORTA,4
   CALL    DELAY10MS
   BSF     PORTA,4

   MOVFW   65H
   CALL    TABLE
   MOVWF   PORTD
   BCF     PORTA,5
   CALL    DELAY10MS
   BSF     PORTA,5
   RETURN


;************************************************************
   END                          ;program end
   
