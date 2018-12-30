
;experiment purpose: familiar A/D conversion

;software thought:select RAO as simulate input routeway

;	   continue convert four times and get average  as the convert result

;	   finally result get the only low 8 bits.

;	   the result send to LED low 3 bits display

;hardware request:SW S14 the second bit ON ,the first bit OFF
;		     S6 all set ON,S5 4-6 bit set ON,1-3 bit set OFF
;	   	     in order to not affect the result,the other SW must set OFF

#INCLUDE<P16F877a.INC>      ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
;*********************THE definien of  registers*********************
TEMP       EQU    20H      ;temporary register
BAI        EQU    21H      ;the hundred bit of convert result
SHI        EQU    22H      ;the ten bit of convert result
GE         EQU    23H      ;the Entries bit of convert result
;****************************************************
  ORG       00H             ;reset entrance address
  NOP                       ;the nop instruction of ICD require
  GOTO      MAIN            ;jump to entrance of main program
  ORG       04H             ;the entrance address of interrupt
  RETFIE                    ;place a interrupt return instruction in the address of interrupt entrance
     			    ;prevent disturb produce interrupt

;***********************check table subprogram*********************
;entrance parameter:W
;exit parameter:W
TABLE
  ADDWF       PCL,1         ;instruction register add excursion address   
  RETLW       0C0H          ;the code of 0( the common LED is anode)                             
  RETLW       0F9H          ;the code of 1
  RETLW       0A4H          ;the code of 2
  RETLW       0B0H          ;the code of 3
  RETLW       99H           ;the code of 4
  RETLW       92H           ;the code of 5
  RETLW       082H 	        ;6
  RETLW       0F8H 	        ;7
  RETLW       080H 	        ;8
  RETLW       090H 	        ;9

;***********************main program***********************
MAIN
  MOVLW     30H
  MOVWF     FSR             ;convert result keep start address    
LOOP
  BSF       STATUS,RP0      ;select bank 1
  MOVLW     7H              ;A PORT high 3 bits are OUTPUT,low 3 bits are INPUT
  MOVWF     TRISA
  CLRF      TRISD           ;D PORT SET OUTPUT
  MOVLW     8EH
  MOVWF     ADCON1          ;result flush left,only select RA0 as ADC PORT,the rest are data PORT
  BCF       STATUS,RP0      ;BANK 0
  MOVLW     41H
  MOVWF     ADCON0          ;select CLOCK is fosc/8,allow  ADC work
  CALL      DELAY           ;call delay program,ensure enough time to sampling
  BSF       ADCON0,GO       ;startup ADC divert
WAIT
  BTFSS     PIR1,ADIF       ;if the convert have finished
  GOTO      WAIT            ;wait for the convert finished
  BSF       STATUS,RP0
  MOVFW     ADRESL          ;read the result of convert
  BCF       STATUS,RP0
  MOVWF     INDF            ;keep in temporary register
  INCF      FSR,1
  BTFSS     FSR,2           ;continue divert four times,get average value
  GOTO      LOOP
  CALL      CHANGE          ;call result convert subprogram
  CALL      DISPLAY         ;call display subprogram
  GOTO      MAIN            ;circle work

;************************convert subprogram*********************
;entrance parameter£º30H---33H
;exit parameter£ºBAI£¬SHI£¬GE
CHANGE
  CLRF      BAI
  CLRF      SHI
  CLRF      GE              ;clear result register
  MOVFW     31H             ;next 8 instruction are get average of four convert result
  ADDWF     30H,1
  MOVFW     32H
  ADDWF     30H,1
  MOVFW     33H
  ADDWF     30H,1
  RRF       30H,1
  RRF       30H,0           
  MOVWF     TEMP
  MOVLW     64H	            ;sub 100,result keep in W
  SUBWF     TEMP,0
  BTFSS     STATUS,C        ;judge if the result biger than 100
  GOTO      SHI_VAL         ;no,get the ten bit result
  MOVWF     TEMP            ;yes,result keep in TEMP
  INCF      BAI,1           ;hundred bit add 1
  GOTO      $-6             ;continue to get hundred bit result
SHI_VAL
  MOVLW     0AH             ;sub 10,result keep in W
  SUBWF     TEMP,0          
  BTFSS     STATUS,C        ;judge if the result biger than 10
  GOTO      GE_VAL          ;no,get the Entries bit result
  MOVWF     TEMP            ;yes,result keep in TEMP
  INCF      SHI,1           ;ten bit add 1
  GOTO      $-6             ;turn  to continue get ten bit
GE_VAL
  MOVFW     TEMP
  MOVWF     GE              ;the value of Entries bit
  RETURN

;**************************display subprogram********************
;entrance parameter£ºBAI£¬SHI£¬GE
;exit parameter£ºno
DISPLAY
  MOVFW    BAI              ;display hundred bit
  CALL     TABLE
  MOVWF    PORTD
  BCF      PORTA,3
  CALL     DELAY
  CALL     DELAY
  BSF      PORTA,3
  MOVFW    SHI              ;display ten bit
  CALL     TABLE
  MOVWF    PORTD
  BCF      PORTA,4
  CALL     DELAY
  CALL     DELAY
  BSF      PORTA,4
  MOVFW    GE               ;display Entries bit
  CALL     TABLE
  MOVWF    PORTD
  BCF      PORTA,5
  CALL     DELAY
  CALL     DELAY
  BSF      PORTA,5
  RETURN
 
;***************************delay subprogram***********************
;entrance parameter£ºno
;exit parameter£ºno
DELAY
  MOVLW    5FH
  MOVWF    TEMP
  DECFSZ   TEMP,1
  GOTO     $-1
  RETURN

;*********************************************************
  END                        ;program end
