;AIM: 877a simulate SPI communication with 93c46b
;fuction:
;1.do one lamp rotate left,and put the 8 code into a table.
;2.get the data from table and save into 93c46 with the word mode. the address is 00h--03h
;3.get the data from 93c46's 00H-03H and save to 877a's RAM(30H)-(37H), and send to RC port
;when power off and on again, the data is still exist.
;4.the 93C46 comes from ATMEL or MICROCHIP,if not, the timing will have some difference
;must adjust the delay time.
;through this experiment, you will be familliar about the timing of 93c46
;hardware configuration
;1.93C46'CS--RB1;CLK--RB2;DI--RB4;DO--RB5
;2.switch--S11 ON, others off.
;************************************
    LIST      P=16F877A, R=DEC
    include "P16F877A.inc"
;***********************************
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC;
;************************************ define table offset
READ   EQU   0  ;read 93C46
WRITE  EQU   1  ;write 93C46 
EWEN   EQU   2  ;93C46 write enable
EWDS   EQU   3  ;93C46 write disable
;*************************************define pin address
CS     EQU   1
CLK    EQU   2
DI     EQU   4
DO     EQU   5
;*********************
ADR46  EQU   20H
F1     EQU   23H
F2     EQU   24H
F3     EQU   25H
F4     EQU   26H
F5     EQU   27H
F6     EQU   28H
F7     EQU   29H
;**********************
  ORG 000H
  NOP              ;for icd needed this nop instruction
  GOTO MAIN
  ORG 0008H
;******************************************************
TABLE
  ADDWF PCL ,1   ;search table£¬PORTC roate left
  RETLW  01H
  RETLW  02H
  RETLW  04H
  RETLW  08H
  RETLW  10H
  RETLW  20H
  RETLW  40H
  RETLW  80H
;*******************************************************
TO9346
  MOVWF F1        ;send w to f1 for temporary save.
  BSF  PORTB ,CS          ;write start bit 1.
  BSF  PORTB ,DI
  BSF  PORTB ,CLK
  CALL DELAY
  BCF  PORTB ,CLK
  CALL DELAY
  MOVFW F1
  ADDWF PCL ,1
  GOTO  SREAD    ;read
  GOTO  SWRITE   ;write
  GOTO  SEWEN    ;write enable
  GOTO  SEWDS    ;write disable
;*****************************************************
MAIN
  MOVLW  00H
  MOVWF  PORTC            ;LED all turn off
  MOVLW  20H
  MOVWF  PORTB            ;except D0, others are sent to 0

  BSF STATUS,RP0          ;define RA,RC all output
  MOVLW 20H
  MOVWF TRISB             ;RB5 as input, others are output.
  CLRW
  MOVWF TRISC             ;RC all output.
  MOVWF OPTION_REG        ;turn on RB interal pull high.
  BCF STATUS,RP0
;*************************************
LOOP
  CLRF    21H             ;get code pointer
  CLRF    ADR46          ;93C46's address 00h
  MOVLW   04H
  MOVWF   22H             ;4 groups are 8 bytes.
START
  MOVLW   EWEN            ;write enable
  CALL    TO9346
  MOVFW   21H             ;get the code pointer.
  CALL    TABLE           ;get data from TABLE 
  MOVWF   F5              ;save into register.
  INCF    21H ,1          ;get the next.
  MOVFW   21H
  CALL    TABLE           ;get data from TABLE
  MOVWF   F4
  MOVLW   WRITE           
  CALL    TO9346          ;write data
  MOVLW   EWDS
  CALL    TO9346          ;write disable
  INCF    21H  ,1         ;get the next
  INCF    ADR46 ,1        ;get the next address
  CALL    DELAY1
  DECFSZ  22H ,1          ;until finished the 4 address.
  GOTO    START
  MOVLW   30H             ;save into 877A's RAM first address.
  MOVWF   FSR
  CLRF    ADR46           ;93C46's address 00h
  MOVLW   04H
  MOVWF   22H             ;read 93C46's 4 address, 8 code.
;*****************
A1
  MOVLW   READ
  CALL    TO9346          ;read the data 
  MOVFW   F5
  MOVWF   INDF            ;save into 877A's RAM
  INCF    FSR ,1
  MOVFW   F4
  MOVWF   INDF
  INCF    ADR46 ,1         ;read next address
  INCF    FSR ,1
  DECFSZ  22H ,1          ;until finished the 4 address
  GOTO    A1
A2
  MOVLW   08H
  MOVWF   22H
  MOVLW   30H             ;RAM 30h-37H all 8 bytes.
  MOVWF   FSR
OUTPUT
  MOVFW   INDF
  MOVWF   PORTC           ;send to PORTC
  CALL    DELAY1   
  INCF    FSR ,1
  DECFSZ  22H ,1
  GOTO    OUTPUT
  GOTO    A2
;***************************
SREAD
  MOVLW  80H
  ADDWF  ADR46 ,0        ;6 bit address add the 2 bit operate code,10XXXXXX  read instruction
  CALL   SDT46           ;write operation address.
  CALL   RDT46           ;read high bit data.
  MOVWF  F5              ;save into F5
  CALL   RDT46           ;read low byte address              
  MOVWF  F4              ;save into F4
  GOTO   EX9346
;**************************
SWRITE
  MOVLW  40H
  ADDWF  ADR46 ,0       ;6 bit address add 2 bit operate code01XXXXXX  write instruction
  CALL   SDT46          ;write the operate code and address
  MOVFW  F5             ;put the data 
  CALL   SDT46          ;write data
  MOVFW  F4             ;put the data 
  CALL   SDT46          ;write data
  GOTO   EX9346 
;******************************
SEWEN
  MOVLW  30H          ;write the operate code 0011XXXX  write enable instruction.
  CALL   SDT46
  GOTO   EX9346
;******************************
SEWDS
  CLRW            ;write 0000XXXX write-disable instruction
  CALL   SDT46
;******************************
EX9346
  BCF   PORTB ,CS    ;clear cs
  RETURN
;******************************
SDT46:
  MOVWF  F2          ;send the data to F2
  MOVLW  08H         ;
  MOVWF  F3
SD1:
  RLF    F2 ,1
  BSF    PORTB ,DI
  BTFSS  STATUS ,C
  BCF    PORTB ,DI
  BSF    PORTB ,CLK
  CALL   DELAY
  BCF    PORTB ,CLK
  CALL   DELAY
  DECFSZ  F3 ,1
  GOTO    SD1
  RETURN
;******************************
RDT46
  MOVLW  08H         ;read 8 bit data
  MOVWF  F3
RD1
  BSF  PORTB ,CLK
  CALL DELAY
  BCF  PORTB ,CLK
  CALL DELAY
  BSF  STATUS ,C
  BTFSS  PORTB ,DO
  BCF  STATUS ,C
  RLF  F2 ,1
  DECFSZ  F3 ,1
  GOTO  RD1
  MOVFW F2      ;send to W
  RETURN
;********************************
DELAY
  MOVLW  1FH     ;CLK delay
  MOVWF  F7
  DECFSZ F7 ,1
  GOTO $-1
  RETURN
;*******************************
DELAY1              ;delay
  MOVLW  .20
  MOVWF  F4
D1
  MOVLW  .40
  MOVWF  F5
D2
  MOVLW  .248
  MOVWF  F6
  DECFSZ F6 ,1
  GOTO  $-1
  DECFSZ F5 ,1
  GOTO   D2
  DECFSZ F4 ,1
  GOTO   D1
  RETURN
;********************************************
       end                   ;end
