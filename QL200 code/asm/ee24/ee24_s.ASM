;AIM: 877A SIMULATE i2c communicatio to read/write 24c02
;the function is when mcu reset,the 24c02 read/write data to diplayed by seg.
;and add one to24c02, so the value of display is the times of reset or power on.
;the 24c02 come from atmel, if other's 24c02 the read/write time will have some diffrence.
;and must adjust the time of delay.
;throuth this experiment, you will be familliar about the time of I2C
;hardware configration:
;1.24CXX'sSDA--RB5, SCLK--RB4, WP--gnd, A0,A1,A2--gnd
;2.during this experiment, don't press the key with the same i/o,or else it will influce this experiment.
;3.switch--S5,S6 on£¬others off.
;************************************
    LIST      P=16F877A, R=DEC
    include "P16F877A.inc"
;***********************************
__CONFIG _DEBUG_OFF&_CP_OFF&_WRT_HALF&_CPD_OFF&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_XT_OSC;
;************************************ 
#define SDA  PORTB,5
#define SCLK PORTB,4
;*********************
COUNT     EQU   20H
ADDR     EQU   21H
DAT     EQU   23H
TEMP     EQU   24H
;**********************
  ORG 000H
  NOP              ; for icd needed.
  GOTO MAIN
  ORG 004H
  RETURN
  ORG 0008H
;******************************************************
TABLE            
        ADDWF PCL,1              ;offset added the current PC
	    RETLW 0C0H 	   		;0 
	    RETLW 0F9H 	   		;1                                
	    RETLW 0A4H 	   		;2
	    RETLW 0B0H 	   		;3
	    RETLW 99H 	   		;4
	    RETLW 92H 	   		;5
	    RETLW 82H 	   		;6
	    RETLW 0F8H 		   	;7
	    RETLW 80H 	   		;8
	    RETLW 98H 	   		;9
                   RETLW 00H 	   		;A
	    RETLW 00H 	   		;B
	    RETLW 00H 		   	;C
	    RETLW 00H 	   		;D
	    RETLW 00H 	   		;E
                   RETLW 00H 	   		;F
;*******************************************************
MAIN           
  MOVLW  0FFH
  MOVWF  PORTC            ;turn off all seg.
  MOVLW  0FFH
  MOVWF  PORTA
  MOVLW  0FFH
  MOVWF  PORTB            ;SDT,SCLK both high

  BSF STATUS,RP0          ;RA,RC,RB all output
  MOVLW 07H
  MOVWF ADCON1            ;RA as IO
  CLRW
  MOVWF TRISB             ;
  MOVWF TRISA
  MOVWF TRISC          
  MOVWF OPTION_REG        ;open RB internal pull high
  BCF STATUS,RP0

  CLRW         ;00H
  CALL RD24    ;read address 00h
  MOVWF DAT     ;send to F1
  SUBLW .9    ;if the value more than 9,F1 will be 0,(for one seg only display 0-9.
  BC  TT2     ;C=0, jump to tt2
TT1
  CLRF  DAT
TT2
  MOVFW DAT
  CALL TABLE   ;get the display code.
  MOVWF PORTC   ;send to C port.
  BCF   PORTA ,1  ;turn on the seg.
  INCF  DAT ,1     ;every power on,save the 24CXX'00H address to add one
  CLRW             ;00H
  CALL  WT24       ;write 24CXX
  GOTO  $
;****************************
RD24  
       MOVWF ADDR       ;address save temporary F4
       CALL START24   ;start I2C
       MOVLW 0A0H 
       CALL SUBS    ;write device address 1010000+0 for write operation.
       MOVFW ADDR       ;put the address
       CALL SUBS    ;write the address
       CALL START24   ;send the start signal again
       MOVLW  0A1H    ;write device address 1010000+1 for read operation.
       CALL SUBS      
       BSF STATUS ,RP0
       BSF TRISB ,5            ;set SDA as input for read.
       BCF STATUS ,RP0 
       MOVLW 08H          ;read 8 bits data.
       MOVWF COUNT
RD000 
       NOP
       NOP
       NOP
       BSF SCLK            ;read data
       NOP
       BSF STATUS,C
       BTFSS SDA
       BCF STATUS,C
       RLF TEMP ,1
       BCF SCLK
       DECFSZ COUNT ,1      ;loop for 8 times.
       GOTO RD000
       BSF STATUS ,RP0
       BCF TRISB ,5            ;recover SDA to output
       BCF STATUS ,RP0
       BSF SDA
       CALL DELAY2
       BSF SCLK
       CALL DELAY2
       BCF SCLK          ;finish ack,SDA set 1
       CALL STOP          ;send to stop signal
       MOVFW  TEMP          ;read data to TEMP
       RETURN
;******************************write 24c02 program
WT24    MOVWF ADDR         ;  save the address into F4
        CALL START24      ;start condition.
        MOVLW 0A0H
        CALL  SUBS      ;write device address 1010000+0 for write operation
        MOVFW ADDR          ;put address
        CALL  SUBS      ;write address
        MOVFW DAT          ;put data
        CALL SUBS       ;write data
        CALL STOP         ;stop signal
        RETURN 

START24
                      ;start condition.
        BSF  SDA
        BSF  SCLK
        CALL DELAY2
        BCF  SDA
        CALL DELAY2
        BCF  SCLK
        RETURN 

STOP   
        BCF  SDA       ;stop condition.
        NOP
        NOP 
        BSF  SCLK
        CALL DELAY2
        BSF  SDA
        RETURN 

SUBS                   ;write data
       MOVWF TEMP     ;save the data into F2.
       MOVLW 08H
       MOVWF COUNT    ;write 8 bits data.
SH01  
       RLF TEMP ,1
       BSF SDA
       BTFSS  STATUS ,C
       BCF SDA
       NOP
       BSF SCLK
       CALL DELAY2
       BCF SCLK
       DECFSZ COUNT ,1  ;loop for 8 times.
       GOTO SH01
       BSF  SDA
       NOP
       NOP
       BSF  SCLK
       BSF  STATUS,RP0
       BSF  TRISB ,5
       BCF  STATUS,RP0
REP
       BTFSC SDA     ;judge ack,if not then wait.
       GOTO REP
       BCF  SCLK
       BSF  STATUS,RP0
       BCF  TRISB ,5
       BCF  STATUS,RP0
       RETURN

DELAY2  
        NOP
        NOP
        NOP
        NOP
        RETURN 
;********************************************
       end                   ;end.
;*****************************************************
