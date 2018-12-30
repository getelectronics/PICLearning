
;experiment purpose: familiar how to use D/A convert MCU

;send the convert data to D/A chip TLC5615,start D/A convert

;observe CON36 voltage with multimeter or oscillograph

;hardware request:SW S8 all ON ,the other SWS all OFF

 INCLUDE<P16F877A.INC>      ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
VALUE1  EQU   0F1H          ;convert data high 4 bits(high half byte is inefficacy data)
VALUE2  EQU   0FCH          ;convert data low 6 bits(low half byte is inefficacy data)
 ORG     00H                ;reset entrance address
 NOP                        ;the nop instruction of ICD require
MAIN
 CLRF    PORTC              ; clear all OUTPUT
 BCF     PORTC,3            ;pull low clock signal,in order to change chip select enable signal
 BSF     PORTC,2            ;not enable  chip select 
 BANKSEL TRISC 
 CLRF    TRISC              ;C PORT all OUTPUT
 BSF     TRISC,4            ;RC4 INPUT£¨SDI£©
 BANKSEL SSPSTAT
 MOVLW   B'01000000'        ;CKE=1 fall edge send£¨TCL5615 ordain £© 
 MOVWF   SSPSTAT
 CLRF    STATUS
 MOVLW   B'00100000'        ;SSPEN=1,CKP=0 SPI main empty mode Fosc/4
 MOVWF   SSPCON
 BCF     PORTC,3            ;pull low clock signal,in order to change chip select enable signal
 BCF     PORTC,2            ;enable chip select
 MOVLW   VALUE1             ;get convert data high 4 bits
 MOVWF   SSPBUF             ;send
 BTFSS   PIR1,SSPIF         ;judge if finish send
 GOTO    $-1                ;wait for finish send
 BCF     PIR1,SSPIF         ;clear interrupt flag
 MOVFW   SSPBUF             ;clear receive register
 MOVLW   VALUE2             ;get convert data low 6 bits
 MOVWF   SSPBUF             ;send
 BTFSS   PIR1,SSPIF         ;judge if finish send
 GOTO    $-1                ;wait for finish send
 BCF     PIR1,SSPIF         ;clear interrupt flag
 BCF     PORTC,3            ;pull low clock signal
 BSF     PORTC,2            ;not enable  chip select 
 NOP
 GOTO    $

;************************************************************
 END                        ;program end
 
