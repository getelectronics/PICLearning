;experiment purpose: familiar SPI general line and how to read and write 9346EEPROM 
 
 ;when press RBO key ,write DATA and DATA2 in some EEPROM  address from EE¡ªADDR 
 
 ;when write finished,the LED display single 9 to indicate finished.
 
 ;when key RB1 press,read EEPROM address from  EE¡ªADDR and send to LED display
 ;hardware request: SW S3¡¢S5¡¢S6 all set ON,S1 7-8 bits set ON
 ;if use 93C46 from ATMEL,must set ¡°WORD SIZE¡± jumper is sixteen.
 
 LIST      P=16F877A, R=DEC
include "P16F877A.inc"     ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
#DEFINE  CS  PORTC,2        ;select 93C46 signal
#DEFINE  CLK PORTC,3        ;clock signal input
#DEFINE  DI  PORTC,5        ;data signal input
#DEFINE  D0  PORTC,4        ;data signal output 

EE_ADDR  EQU  05H           ;the start address of EEPROM 

EE_DATA  EQU  56H          ;the data will be write in EEPROM
EE_DATA2 EQU  78H

TEMP1    EQU  30H           ;keep the data read from EEPROM
TEMP2    EQU  31H
DL1      EQU   77H            ;delay register
DL2      EQU   78H            ;delay register
;******************************************************
  ORG 000H                  ;reset entrance address
  NOP                       ;the nop instruction of ICD require
   GOTO MAIN
  ORG 0008H
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
;********************main program***************************
MAIN
  MOVLW   0FFH
  MOVWF   PORTD
  CLRF    TEMP1
  BANKSEL SSPSTAT
  MOVLW   b'10000000'       
  MOVWF   SSPSTAT           ;SMP=1£¬CKE=0
  MOVLW   B'11010000'
  MOVWF   TRISC             ;D0 INPUT£¬DI OUTPUT£¬CLK OUTPUT
  MOVLW   0FFH
  MOVWF   TRISB
  CLRF    TRISD
  CLRF    TRISA
  MOVLW   06H
  MOVWF   ADCON1
  CLRF    STATUS
  CLRF    INTCON            ;clear all interrupt flag bit 
  CLRF    PIR1              ;clear SSP interrupt flag bit
  BCF     CS                ;not select EEPROM
  MOVLW   B'00110001'     
  MOVWF   SSPCON            ;CKP=1,SSPEN=1,SPI main mode Fosc/16

LOOP
  CLRF    STATUS
  BTFSC   PORTB,2
  GOTO    EE_READ
  CALL    WRITE_EE
  MOVLW   90H
  MOVWF   PORTD
  MOVLW   0FEH
  MOVWF   PORTA
  GOTO    $
EE_READ
  BTFSC   PORTB,3
  GOTO    MAIN
  CALL    READ_EE
  CALL    DISPLAY
  GOTO    $-1
;**********************enable write subprogram*********************************
WRITE_EE
  BSF     CS                ;select EEPROM
  MOVLW   B'00000001'       ;send start bit
;  MOVLW   
  CALL    SPI_COMM          ;send
  MOVLW   B'00110000'       ;enable write command code
  CALL    SPI_COMM          ;send
  BCF     CS                ;not select EEPROM 
  NOP
  NOP                       ;delay a little time

;*********************write data********************************** 
;entrance parameter£ºEE_ADDR,EE_DATA,EE_DATA2
;exit parameter£ºno
;*************************************************************
  BSF     CS                ;select EEPROM
  MOVLW   B'00000001'       ;send start bit
  CALL    SPI_COMM          ;send
  MOVLW   EE_ADDR           ;send address which will be writed
  IORLW   B'01000000'       ;address add write command code
  CALL    SPI_COMM
  MOVLW   EE_DATA           ;send data which will be writed 
  CALL    SPI_COMM
  MOVLW   EE_DATA2          
  CALL    SPI_COMM          ;send 8 bit data again,combine 16 bit data
  BCF     CS                ;not select EEPROM
  NOP
  NOP
  NOP                       ;delay a little time
  BSF     CS                ;select EEPROM
  NOP
  NOP
  BTFSS    D0               ;judge if EEPROM finsh write
  GOTO     $-1              ;if EEPROM is writing,wait for finish
  BCF      CS               ;not select EEPROM
  NOP
  NOP                       ;delay a little time
  RETURN

;*********************read data subprogram***********************************  
;entrance parameter£ºEE_ADDR
;exit parameter£ºTEMP1£¬TEMP2
;**************************************************************
READ_EE
  BSF      CS               ;select EEPROM
  NOP
  NOP                       ;delay a little time
  MOVLW    B'00000001'      ;send start bit
  CALL     SPI_COMM
  MOVLW    EE_ADDR          ;send address which will be readed
  IORLW    B'10000000'      ;address add write command code    
  CALL     SPI_COMM
  MOVLW    00H
  CALL     SPI_COMM         ;read high 8 bit data from EEPROM specify address
  MOVWF    TEMP1            ;keep data  
  MOVLW    00H
  CALL     SPI_COMM         ;read low 8 bit data from EEPROM specify address
  MOVWF    TEMP2
  NOP
  BCF      CS               ;not select EEPROM
  NOP
  NOP
  
  MOVLW    0FH
  ANDWF    TEMP1,0
  MOVWF    61H
  SWAPF    TEMP1,0
  ANDLW    0FH
  MOVWF    60H
  MOVLW    0FH
  ANDWF    TEMP2,0
  MOVWF    63H
  SWAPF    TEMP2,0
  ANDLW    0FH
  MOVWF    62H
  RETURN    
;*****************send command/data and read data subprogram*************
SPI_COMM
  MOVWF    SSPBUF           ;write data in SSPBUF,start send/receive
  BTFSS    PIR1,SSPIF       ;judge if send/receive finished
  GOTO     $-1              ;wait for finished
  BCF      PIR1,SSPIF       ;clear all interrupt flag bit
  MOVF     SSPBUF,W         ;empty SSPBUF,in order to the next communicate
  RETURN                    ;subprogram return

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
;**********************display subprogram****************************** 
;entrance parameter£º60H-63H
;exit parameter:no
;***********************************************************

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
   RETURN

;********************************************
       end                  ;program end
