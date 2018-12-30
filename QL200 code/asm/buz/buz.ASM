;experiment purpose: familiar the method of MCU produce voice

;hardware request:SW S10 the third bit set ON,the others set OFF

 LIST P=16F877A,R=DEC        ;define MCU,default is decimal 
#include<p16f877a.inc>
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
;************************THE definiens of  registers and bits***********************

SOUNDDELAY1 EQU 20H    ;voice frequency change counter,from 1.8~3.55KHZ 
FRE_COUNT   EQU 21H    ;the  register of  same frequency repeat times
FRE_REPEAT  EQU 22H     
SOUND_TEMP  EQU 23H
TEMP        EQU 24H    ;temporary register
S_LOOP      EQU 46H    ;93-47=46
S_MAX       EQU 93H    ;the lowest frequency 1.8K  93*3=280US*2S_
S_MIN       EQU 47H    ;the highest frequency  3.55K  47*3=140*2S_
S_REPEAT    EQU 4H     ;the same frequency repeat times

   ORG 0000H              ;reset entrance address
   nop                 ;the nop instruction of ICD require
MAIN    
   CLRF PORTC          ;initialize IO PORT
   BSF STATUS,RP0      ;set BANK1
   MOVLW 0000000B
   MOVWF TRISC         ;set RA all PORT OUTPUT 
   BCF STATUS,RP0      ;set BANK0
LOOP
   CALL SOUND200MS     ;call alarm 200MS subprogram
   GOTO LOOP           ;circle alarm
;-------------------------------
SOUND200MS    
   MOVLW S_LOOP
   MOVWF FRE_COUNT     ;46=93-47 the lowest frequency counter sub the highest frequency counter
   		       ;equal to the times of  frequency change
SOUND_LH_LP
   MOVLW S_REPEAT      ;keep the same frequency repeat times in FRE_REPEAT
   MOVWF FRE_REPEAT
   MOVFW FRE_COUNT
   ADDLW S_MIN        ;counter add the MIN
   MOVWF TEMP
REPEAT0_LP
   MOVFW TEMP
   BSF PORTC,2       
   CALL SOUNDDELAY0   ;delay   W*3US    
   BCF PORTC,2
   MOVFW TEMP
   CALL SOUNDDELAY0
   DECFSZ FRE_REPEAT,1 ;four times sub frequency counter once
   GOTO REPEAT0_LP
   DECFSZ FRE_COUNT,1
   GOTO SOUND_LH_LP
SOUND_HL
   MOVLW S_LOOP
   MOVWF FRE_COUNT   ;46=93-47SOUND_HL_LP
   MOVLW S_REPEAT    ;keep the same frequency repeat times in FRE_REPEAT
   MOVWF FRE_REPEAT
   MOVFW FRE_COUNT
   SUBLW S_MAX       ;the MAX sub counter
   MOVWF TEMP
REPEAT1_LP
   MOVFW TEMP
   BCF PORTC,2
   CALL SOUNDDELAY0  ;delay   W*3US
   BSF PORTC,2
   MOVFW TEMP
   CALL SOUNDDELAY0
   DECFSZ FRE_REPEAT,1;four times sub frequency counter once
   GOTO REPEAT1_LP
   DECFSZ FRE_COUNT,1
   GOTO SOUND_LH_LP
   RETLW 0
;------------------------------
SOUNDDELAY0
   MOVWF SOUNDDELAY1     ;delay W*3US+1US
SOUNDDELAYUS_1
   DECFSZ SOUNDDELAY1,1
   GOTO SOUNDDELAYUS_1
   RETLW 0
;------------------------
   END
