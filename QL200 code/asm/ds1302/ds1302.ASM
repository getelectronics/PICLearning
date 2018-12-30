
;experiment purpose: familiar how to use clock chip DS1302

;first set time and date:second(08),minute(58),hour(05),day(13),month(01),year(55)

;six LED display time and date,default display time,differentiate hour and min,min and second with decimal dot

;when press RB1 not relax,display switch to date.

;hardware request: SW S9,S5,S6 all ON,S1 the seventh bit ON,the other bits OFF,the other SWS OFF.
#INCLUDE<p16f877a.inc>              ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
;**********************define I/O****************************
#DEFINE I_O PORTB,4                 ;1302I_O
#DEFINE SCLK PORTB,0                ;1302 clock
#DEFINE RST PORTB,5                 ;1302 enable bit
;********************* define register***************************
TIME_TX_ADD   	EQU  20H            ;continue send 8 byte datas start address
TIME_RX_ADD     EQU  20H            ;continue receive 7 byte datas start address
 ERRORLEVEL -302
 CBLOCK 20H
SEC                                 ;second
MIN                                 ;minute
HOU                                 ;hour
DATE                                ;date
MON                                 ;month
DAY                                 ;day 
YERR                                ;year
TIME_TX                             ;1302 send register
TIME_RX                             ;1302 receive register
COUNT1                              ;circle times counter
COUNT2 ;
 ENDC
;******************* macro define*********************************
BANK1 MACRO                         ; BANK1
 BSF STATUS,RP0         
 ENDM
BANK0 MACRO                         ; BANK0
 BCF STATUS,RP0
 ENDM 

 ORG 000H                           ;reset entrance address
 NOP                                ;the nop instruction of ICD require
 GOTO MAIN                          ;jump to entrance of main program

;********************check table subprogram*****************************
TABLE 
     ADDWF       PCL,1   
     RETLW       0C0H          ;the code of 0( the common LED is anode)                        
     RETLW       0F9H          ;the code of 1
     RETLW       0A4H          ;the code of 2
     RETLW       0B0H          ;the code of 3
     RETLW       99H           ;the code of 4
     RETLW       92H           ;the code of 5
	 RETLW       082H 	       ;6
	 RETLW       0F8H 	       ;7
	 RETLW       080H 	       ;8
	 RETLW       090H 	       ;9

;**********************main program*****************************
MAIN
 CALL PORT_INI                      ;define PORT
 CALL DS1302_INI                    ;1302 initialize program
 CALL SET_TIME                      ;write 7 byte time data once
 CALL GET_TIME                      ;read 7 byte time data once
 CALL DISPLAY                       ;call display program
 GOTO $-2                           ;circle read time

;**********************DS1302 initialize program******************
; DS1302_INI

;function:initialize 1302,write enable register
;********************************************************

;entrance parameter:no
;exit parameter:TIME_TX
DS1302_INI
 BCF SCLK
 BCF RST                            ;first forbid
 MOVLW B'10001110'                  ;write enable 
 MOVWF TIME_TX
 BSF RST                            ;enable 1302
 CALL TIME_WRITE_1                  ;call write a data program
 MOVLW 0H                           ;enable write
 MOVWF TIME_TX
 CALL TIME_WRITE_1                  ;send a byte data
 BCF RST
 RETURN

;***********************write time program*************************
; SET_TIME
; usage: input seven byte to set time, and enable write register
; when using the sudden mode, it needed to write 8 bytes and not seven.
; INPUT: the eight byte have written into the TIME_TX_ADD's 8 bytes.
;********************************************************
;input parameter£º20H--27H's 8 RAMs.
SET_TIME
 MOVLW B'10111110'                 ;multi bytes write mode.
 MOVWF TIME_TX
 BSF RST
 CALL TIME_WRITE_1                 
 MOVLW TIME_TX_ADD                 ;the start address of send data
 MOVWF FSR
 MOVLW D'8'                        ;send 8 bytes at the same time.
 MOVWF COUNT2
TW1
 MOVF INDF,W
 MOVWF TIME_TX
 CALL TIME_WRITE_1
 INCF FSR,F
 DECFSZ COUNT2,F
 GOTO TW1
 BCF RST
 RETURN

;**********************read time program*************************
; GET_TIME
; usage: recept 7 bytes time data, sudden mode read
; INPUT:NONE
; OUTPUT:save the 7 bytes into TIME_RX_ADD's 7 registers
;*********************************************************
;input parameter: none
;output parameter:20H--26H's 7 RAMs
GET_TIME
 MOVLW B'10111111'                ;multi bytes read mode
 MOVWF TIME_TX
 BSF RST
 CALL TIME_WRITE_1
 MOVLW TIME_RX_ADD                ;save bytes 
 MOVWF FSR
 MOVLW D'7'                       ;read 7 bytes continuously
 MOVWF COUNT2
TR2
 CALL TIME_READ_1
 MOVF TIME_RX,W
 MOVWF INDF
 INCF FSR,F
 DECFSZ COUNT2,F
 GOTO TR2
 BCF RST
 RETURN

;**********************write a byte program*****************
; TIME_WRITE_1
; usage: send one byte only.
; used for control word etc.
;************************************************
;input parameter£ºTIME_TX
;output parameter£ºnone
TIME_WRITE_1
 MOVLW D'8'                      ;8 bits
 MOVWF COUNT1
TLOP
 BCF I_O                         ;the initial is low
 BCF SCLK
 BTFSC TIME_TX,0
 BSF I_O
 RRF TIME_TX,F
 BSF SCLK                        ;rise-edge to send data
 DECFSZ COUNT1,F
 GOTO TLOP
 BCF SCLK                        ;recover
 RETURN

;******************read one byte program*********************
; TIME_READ_1
; usage: read 1302 only one byte.
; schedule: receiving data when the falling edge comes, low byte first.
; according the I/o's high and low to select the shift right with or without carry.
;***********************************************
; INPUT:NONE
; OUTPUT:TIME_RX

TIME_READ_1
 BANK1
 BSF TRISB,4 ;                    I_O set to input
 BANK0
 MOVLW D'8'
 MOVWF COUNT1                     ;read 8 bits.
TR1
 BCF SCLK                         ;read when falling edge
 BCF STATUS,C
 BTFSC I_O
 BSF STATUS,C
 RRF TIME_RX,F
 BSF SCLK                         ;recover high
 DECFSZ COUNT1,F
 GOTO TR1
 BANK1
 BCF TRISB,4                       ;I_O recover to output
 BANK0
 BCF SCLK 
 RETURN
 NOP

;******************port/register setting********************
PORT_INI
 BANK1
 MOVLW B'00000000'
 MOVWF TRISA                       ;A port output
 MOVWF TRISD                       ;D port output
 MOVLW 06H
 MOVWF ADCON1                      ;A port set to I/O
 MOVLW B'00000010' 
 MOVWF TRISB                       ;RB1 input, others output
 CLRF  OPTION_REG                  ;open the B ports pull high.
 BANK0
 MOVLW 0FFH
 MOVWF PORTA
 MOVWF PORTD                       ;turn off the all display
 MOVLW 08H
 MOVWF 20H                         ;second, enable xtal
 MOVLW 58H                         ;minute
 MOVWF 21H
 MOVLW 05H                         ;hour
 MOVWF 22H 
 MOVLW 13H                         ;day
 MOVWF 23H
 MOVLW 10H                         ;month
 MOVWF 24H
 MOVLW 06H                         ;week
 MOVWF 25H
 MOVLW 55H                         ;year
 MOVWF 26H
 RETURN

;*************************display program************************
DISPLAY
 BTFSS   PORTB,1                   ;check the key pressed.
 GOTO    DISPLAY_DATE              ;if yes,display date. else display time
 MOVFW   20H
 MOVWF   30H
 MOVFW   21H
 MOVWF   31H
 MOVFW   22H
 MOVWF   32H                       ;copy 20H--22H into 30H--32H (sec,min,hour)
 GOTO    DISPLAY1                  ;display
DISPLAY_DATE                       ;date
 MOVFW   23H
 MOVWF   30H
 MOVFW   24H
 MOVWF   31H
 MOVFW   26H
 MOVWF   32H                       ;copy 23H,24H,26H into 30H--32H (day, month,year)
DISPLAY1
 SWAPF   32H,0                     ;display hour/year's high bit
 ANDLW   0FH
 CALL    TABLE
 MOVWF   PORTD
 BCF     PORTA,0
 CALL    DELAY
 BSF     PORTA,0
 
 MOVFW   32H                       ;display hour/year's low bit
 ANDLW   0FH
 CALL    TABLE
 MOVWF   PORTD
 BCF     PORTD,7                   ;light the seg's point as the signature of two segs.
 BCF     PORTA,1
 CALL    DELAY
 BSF     PORTA,1

 SWAPF   31H,0                     ;display min/month's high bit
 ANDLW   0FH
 CALL    TABLE
 MOVWF   PORTD
 BCF     PORTA,2
 CALL    DELAY
 BSF     PORTA,2
 
 MOVFW   31H                       ;display min/month's low bit
 ANDLW   0FH
 CALL    TABLE
 MOVWF   PORTD
 BCF     PORTD,7
 BCF     PORTA,3
 CALL    DELAY
 BSF     PORTA,3

 SWAPF   30H,0                     ;display sec/day's high bit
 ANDLW   0FH
 CALL    TABLE
 MOVWF   PORTD
 BCF     PORTA,4
 CALL    DELAY
 BSF     PORTA,4
 
 MOVFW   30H                       ;display sec/day's low bit
 ANDLW   0FH
 CALL    TABLE
 MOVWF   PORTD
 BCF     PORTA,5
 CALL    DELAY
 BSF     PORTA,5
 
;*************************delay program*****************************
DELAY
 MOVLW   3FH
 MOVWF   40H
 DECFSZ  40H,1
 GOTO    $-1
 RETURN

;**************************************************************
 END                                ;end

