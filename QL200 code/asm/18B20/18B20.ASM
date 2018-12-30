;THE experiment is to familiarity the use of DS18B20

;SIX LED display temperature,the integer is two digit,the decimal fraction is four digit.

;THE hardware request:the DS18B20  must insert in the 18B20 socket

;	   SW S10 the first bit ON,the other bit OFF

;	   SW S5¡¢S6 must set ON, the other SWS must set OFF.
;*****************THE definiens of  register*****************************
#INCLUDE<P16F877A.INC>
#DEFINE DQ PORTA,0         ;18B20 data port
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
 
    CBLOCK 20H
DQ_DELAY1
DQ_DELAY2
TEMP
TEMP1
TEMP2                         ;keep the temperature of sampling
TEMP3
COUNT
COUNT1
 ENDC
TMR0_VALUE        EQU  0AH   ;register initial value is 6,prescaler is 1£º4,the time of one interrupt is 4*£¨256-6£©=1000us
DQ_DELAY_VALUE1   EQU  0FAH
DQ_DELAY_VALUE2   EQU  4H

;**********************start of program************************
	ORG    00H              
    NOP   
	GOTO   MAIN             ;the address of entrance
	ORG    04H
    RETFIE                  ;place a interrupt return instruction in the address of interrupt entrance

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

;***************************main program*******************************
MAIN
    CLRF     PORTA
    CLRF     PORTB
    BANKSEL  TRISA
    CLRF     TRISA              ;the A PORT SET OUTPUT 
    CLRF     TRISD
    MOVLW    01H
    MOVWF    TRISB              ;set B0 PORT INPUT,the other OUTPUT
    MOVLW    06H
    MOVWF    ADCON1             ;close all A/D PORT
    MOVLW    01H
    MOVWF    OPTION_REG         ;prescaler is 1£º4,timer,inside clock
	BCF      STATUS,RP0
    
	CLRF     TEMP
    CLRF     TEMP1
    CLRF     TEMP2              ;clear all temporary register
    MOVLW    8H
    MOVWF    COUNT
    MOVLW    38H
    MOVWF    FSR
    CLRF     INDF
    INCF     FSR,1
    DECFSZ   COUNT,1
    GOTO     $-3
      
;****************************the cycle of program************************

;startup 18B20 temperature conversion program,judge if the conversion of temperature have finished(need 750us)

;if have not finished CALL display subprogram, till finish the conversion of temperature
;if finish the conversion of temperature read the temperature
;send to led display
LOOP 
    BTFSC    PORTB,0          ;judge if the temperature convert key press
    GOTO     LOOP1            ;no ,jump to display
    CALL     DELAY            ;remove shake
    BTFSC    PORTB,0          ;judge again
    GOTO     LOOP1
    CALL     RESET_18B20      ;CALL reset 18B20 subprogram
    MOVLW    0CCH 
    MOVWF    TEMP
    CALL     WRITE_18B20      ;SKIP ROM command
    MOVLW    44H
    MOVWF    TEMP
    CALL     WRITE_18B20      ;temperature convert  command   
    CLRF     STATUS 
    CALL     DELAY_750MS      ;CALL 64 DISPLAY subprogram,ensure the time of transform temperature (need 750us)
    NOP
    CALL     RESET_18B20      
    MOVLW    0CCH 
    MOVWF    TEMP
    CALL     WRITE_18B20      ;SKIP ROM command
    MOVLW    0BEH 
    MOVWF    TEMP
    CALL     WRITE_18B20      ;READ temperature command
    CALL     READ_18B20       ;READ temperature low byte
    MOVFW    TEMP
    MOVWF    TEMP1            ;keep in TEMP1
    CALL     READ_18B20       ;READ temperature high byte
    MOVFW    TEMP
    MOVWF    TEMP2            ;keep in TEMP2
	CALL     RESET_18B20      
LOOP1
    CALL     TEMP_CHANGE      ;CALL temperature conversion subprogram
    CALL     DISPLAY          ;CALL LED display
    GOTO     LOOP             ;circle work

;*********************reset DS18B20 subprogram**************************
RESET_18B20
;DATASHEET introduce,write data must conform to next prescript:
;main controller pull low  general line at least 480us,

;18B20 wait 15-60us, pull low general line as the responsion to the main controller
    BANKSEL  TRISA
    BCF      TRISA,0
    BCF      STATUS,RP0
    BCF      DQ
    MOVLW    0A0H
    MOVWF    COUNT           ;160US
    DECFSZ   COUNT,1
    GOTO     $-1             ;pull low 480us
    BSF      DQ              ;release general line  
    MOVLW    14H
    MOVWF    COUNT
    DECFSZ   COUNT,1
    GOTO     $-1             ;wait 60us
    BANKSEL  TRISA
    BSF      TRISA,2         ;DQ set INPUT
    BCF      STATUS,RP0
    BTFSC    DQ              ;IF the data line is low
    GOTO     RESET_18B20     ;otherwise continue reset
    MOVLW    4H
    MOVWF    COUNT
    DECFSZ   COUNT,1         ;delay some time judge again
    GOTO     $-1
    BTFSC    DQ
    GOTO     RESET_18B20
    MOVLW    4BH             
    MOVWF    COUNT
    DECFSZ   COUNT,1
    GOTO     $-1 
    BANKSEL  TRISA
    BCF      TRISA,0         ;DQ set OUTPUT
    BCF      STATUS,RP0
    RETURN
;*********************write DS18B20 subprogram****************************
WRITE_18B20
;DATASHEET introduce,write data must conform to next prescript:

;write data 0,main controller pull low general line at least 60us
  
;write data 1,main controller pull low general line ,but must release in 15us
    MOVLW    8H
    MOVWF    COUNT           ;eight bit data
    BANKSEL  TRISA
    BCF      TRISA,0
    BCF      STATUS,RP0
    BCF      STATUS,C
WRITE_18B20_1
    BSF      DQ              ;first keep DQ high
    MOVLW    5H
    MOVWF    COUNT1
    BCF      DQ              ;pull low DQ15us
    DECFSZ   COUNT1,1
    GOTO     $-1            
    RRF      TEMP,1          
    BTFSS    STATUS,C        ;judge the write data is 0 or 1
    GOTO     WRITE_0          
    BSF      DQ              ;if is 1,pull high data line at once
    GOTO     WRITE_END
WRITE_0
    BCF      DQ              ;continue keep data line low
WRITE_END
    MOVLW    0FH
    MOVWF    COUNT1          ;keep 45us
    DECFSZ   COUNT1,1
    GOTO     $-1
    BSF      DQ              ;release general line 
    DECFSZ   COUNT,1         ;if finish 8 bit data
    GOTO     WRITE_18B20_1
    RETURN
;**********************read DS18B20 subprogram****************************
READ_18B20
;DATASHEET introduce,write data must conform to next prescript:

;read data 0,main controller first pull low general line,18B20 pull low 60us again

;read data 1,after main controller pull low general line,keep general line state

; main controller after data line pull low  inside 15us read the state of data line              
     MOVLW    8H               ;read 8 bit data once
     MOVWF    COUNT
READ_18B20_1
     BANKSEL  TRISA
     BCF      TRISA,0          ;data line set OUTPUT
     BCF      STATUS,RP0
     BCF      DQ               ;first pull low data line
     MOVLW    1H
     MOVWF    COUNT1          
     DECFSZ   COUNT1,1         ;pull low general line 3us 
     GOTO     $-1
     BSF      DQ               ;release general line
     BANKSEL  TRISA
     BSF      TRISA,0          ;data line set INPUT
     BCF      STATUS,RP0
     MOVLW    2H
     MOVWF    COUNT1
     DECFSZ   COUNT1,1         ;delay 6us
     GOTO     $-1
     BSF      STATUS,C
     BTFSS    DQ               ;judge the state of data line
     BCF      STATUS,C
     RRF      TEMP,1           ;shift to TEMP
     MOVLW    12H
     MOVWF    COUNT1
     DECFSZ   COUNT1,1
     GOTO     $-1              ;read one bit data must require 60us
     DECFSZ   COUNT,1          ;if finish reading 8 bit
     GOTO     READ_18B20_1
     RETURN
;*******************temperature format conversion subprogram************************** 
;because the temperature read from 18B20 is binary,must change into ASCII display on LED 

;18B20 temperature format is:S S S S S 2 of 6 power,2 of 5 power,2 of 4 power,2 of 3 power,
;2 of 2 power,2 of negative 4 power,

;the result integer keep in the start of 38H register,decimal fraction keep in the start of 3BH register

;38H(hundred bit)39H(ten bit)3AH(Entries bit)3BH(decimal dot)3CH(ten cent bit)3DH(hundred cent bit)
;3EH(thousand cent bit),3FH(myriad cent bit)
TEMP_CHANGE 
;integer data

;because after change temperature the data is keep in two registers ,so must combine in one register

;because the max value is 127.9375,so judge the value if big that 100 to decide the result of hundred bit

;use circle sub 0AH receive the ten bit,the leave minuend is Entries bit
    MOVLW    7H 
    ANDWF    TEMP2,0         ;only keep 3 bit
    MOVWF    3AH             ;keep in 3AH
    SWAPF    3AH,1
    MOVFW    TEMP1
    MOVWF    TEMP3           ;keep in TEMP2
    MOVLW    0F0H            
    ANDWF    TEMP3,1         ;clear low four bits
    SWAPF    TEMP3,0         ;swap high half byte and low half byte
    IORWF    3AH,1           ;combine is result of 7 bit integer data
    
    MOVLW    64H             ;calculate hundred bit of integer data 
    SUBWF    3AH,W           ; -100
    BTFSS    STATUS,C
    GOTO     NEXT0           ;temperature less than 100
    MOVWF    3AH             ;decrease result cover the old data
    MOVLW    1H            
    MOVWF    38H             ;integer MSB is 1(impossible big than 1)
    GOTO     $+2
NEXT0
    CLRF     38H             ;temperature less than 100,the MSB is 0
    CLRF     39H             ;calculate integer ten bit 
    MOVLW    0AH             ; -10
    SUBWF    3AH,1
    BTFSS    STATUS,C
    GOTO     NEXT1
    INCF     39H,1           ;enough sub,ten bit add 1
    GOTO     $-5
NEXT1
    MOVLW    0AH
    ADDWF    3AH,1            ;reset the old data,the data is Entries bit
    
    MOVLW    '.'
    MOVWF    3BH               ;decimal dot
    
;decimal data
;get four bit precision

;the method of calculate is from the lowest bit judge the bit is 1,if is 1 add: 
;0.0625¡¢0.125¡¢0.25¡¢0.5£¬ and only hundred cent bit add ,the result can big than 0AH
	CLRF     3CH
    CLRF     3DH
    CLRF     3EH
    CLRF     3FH
    BTFSS    TEMP1,0           
    GOTO     NEXT2
    MOVLW    5H
    MOVWF    3FH
    MOVLW    2H
    MOVWF    3EH
    MOVLW    6H
    MOVWF    3DH               ;myriad cent bit  
NEXT2
    BTFSS    TEMP1,1
    GOTO     NEXT3
    MOVLW    5H
    ADDWF    3EH,1
    MOVLW    2H
    ADDWF    3DH,1
    MOVLW    1H
    MOVWF    3CH              ;thousand cent bit

NEXT3
    BTFSS    TEMP1,2
    GOTO     NEXT5
    MOVLW    5H
    ADDWF    3DH,1
    MOVLW    0AH
    SUBWF    3DH,1
    BTFSS    STATUS,C
    GOTO     NEXT4
    INCF     3CH,1
    GOTO     $+3
NEXT4
    MOVLW    0AH
    ADDWF    3DH,1
    MOVLW    2H
    ADDWF    3CH,1            ;hundred cent bit

NEXT5
    BTFSS    TEMP1,3
    GOTO     NEXT6
    MOVLW    5H
    ADDWF    3CH,1           ;ten cent bit
NEXT6   
    RETURN

;*******************************display subprogram*******************************
;entrance parameter:39H(ten bit)3AH(Entries+decimal dot)3CH(ten cent bit)
;3DH(hundred cent bit)3EH£¨thousand cent bit£© 3FH£¨myriad cent bit£©
;exit parameter:no 
DISPLAY    
    BANKSEL     TRISA
    CLRF        TRISA            ;A PORT ALL SET OUTPUT
    CLRF        STATUS       
    MOVFW       39H             ;display temperature ten bit
    CALL        TABLE
    MOVWF       PORTD
    BCF         PORTA,0
    CALL        DELAY
    BSF         PORTA,0

    MOVFW       3AH             ;display temperature Entries bit
    CALL        TABLE
    MOVWF       PORTD
    BCF         PORTD,7         ;decimal dot 
    BCF         PORTA,1
    CALL        DELAY
    BSF         PORTA,1
 
    MOVFW       3CH             ;display temperature ten cent bit
    CALL        TABLE
    MOVWF       PORTD
    BCF         PORTA,2
    CALL        DELAY
    BSF         PORTA,2

    MOVFW       3DH             ;display temperature hundred cent bit
    CALL        TABLE
    MOVWF       PORTD
    BCF         PORTA,3
    CALL        DELAY
    BSF         PORTA,3

   MOVFW       3EH              ;display temperature thousand cent bit
   CALL        TABLE
   MOVWF       PORTD
   BCF         PORTA,4
   CALL        DELAY
   BSF         PORTA,4

   MOVFW       3FH              ;display temperature myriad cent bit
   CALL        TABLE
   MOVWF       PORTD
   BCF         PORTA,5
   CALL        DELAY
   BSF         PORTA,5

   RETURN
       
;***************************delay subprogram************************************    
DELAY
               GOTO        $+1
               GOTO        $+1
               GOTO        $+1
               GOTO        $+1
               GOTO        $+1
               GOTO        $+1
               RETURN

;**************************delay 750ms******************************
DELAY_750MS
    MOVLW    DQ_DELAY_VALUE2
    MOVWF    DQ_DELAY2
DELAY_750MS_2
    MOVLW    DQ_DELAY_VALUE1
    MOVWF    DQ_DELAY1
DELAY_750MS_1
    MOVLW    TMR0_VALUE
    MOVWF    TMR0               ;start timer
    BTFSS    INTCON,T0IF
    GOTO     $-1
    BCF     INTCON,T0IF
    DECFSZ   DQ_DELAY1,1
    GOTO     DELAY_750MS_1
    DECFSZ   DQ_DELAY2,1
    GOTO     DELAY_750MS_2
    RETURN
;**************************program end******************************
    END
    
