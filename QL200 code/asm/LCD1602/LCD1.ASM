
;THE experiment is to familiarity the use of LCD

;lcd loop to display the website of our company and tel.
;the configration of hardware: lcd connect with chip's port a and d.

;SW S10 the fourth bit set ON,the other SW OFF, jump J14 all connect.
;adjust the ponemeter for the light.
;*****************THE definiens of  register*****************************
#include<p16f877a.inc>
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
;************************************

Z       EQU 2    	;define Z status's address
RP0     EQU 5    	;define RP0's address
#DEFINE RS  PORTA,1
#DEFINE RW  PORTA,2
#DEFINE E   PORTA,3
;*********************
;RS EQU 1         	;
;RW EQU 2         	;
;E  EQU 3         	;
COUNT EQU 24H    	;define count reg address
TMP1  EQU 25H    	;define temp count reg.
;**********************
  ORG 000H
  NOP              	;icd needed a nop instruction
  GOTO MAIN
  ORG 0008H
;******************************************************
TABLE                     ;get the first line code WWW.PIC16.COM
           ADDWF PCL,1    ;address offset add the current pc.
           RETLW 20H      ;space
           RETLW 57H      ;W
           RETLW 57H      ;W
           RETLW 57H      ;W
           RETLW 2EH      ;.
           RETLW 50H      ;P
           RETLW 49H      ;I
           RETLW 43H      ;C
           RETLW 31H      ;1
           RETLW 36H      ;6
           RETLW 2EH      ;.
           RETLW 43H      ;C
           RETLW 4FH      ;O
           RETLW 4DH      ;M
           RETLW 00H
;-------------------- ----------------------------------
TABLE1                    ;get the 2nd line code TEL0755-83643980 
        ADDWF PCL,1       ;address offset add the current pc.                                            	
	    RETLW 54H 	   	  ;T 
	    RETLW 45H 	   	  ;E                             
	    RETLW 4CH 	   	  ;L
	    RETLW 30H 	   	  ;0
	    RETLW 37H 	   	  ;7
	    RETLW 35H 	      	  ;5
	    RETLW 35H 		  ;5
	    RETLW '-'	   	  ;space
	    RETLW '8' 	   	  ;8
        RETLW '3'         	  ;3
        RETLW '6'         	  ;6
        RETLW '4'         	  ;4
        RETLW '3'         	  ;3
        RETLW '9'         	  ;9
        RETLW '8'         	  ;8
        RETLW '0'         	  ;0
        RETLW 00H
;*******************************************************
MAIN
  movlw b'1010'
  BSF STATUS,RP0          ;change to bank 1
  MOVLW 0EH
  MOVWF ADCON1            ;
  MOVLW 00H 
  MOVWF TRISA             ;
  MOVWF TRISD             ;
  BCF STATUS,RP0          ;return to bank 0

;the following 16 instructions to set lcd display mode.
  CALL DELAY              ;delay for lcd is slower than mcu.
  MOVLW 01H
  MOVWF PORTD             ;clr screen
  CALL ENABLE             ;write commond.
  MOVLW 38H
  MOVWF PORTD             ;8 bits 2 lines 5*7 mode.
  CALL ENABLE
  MOVLW 0EH               ;display on,cursor on,blink on.
  MOVWF PORTD
  CALL ENABLE
  MOVLW 06H               ;character not move,cursor rotate right.
  MOVWF PORTD             
  CALL ENABLE
  MOVLW 80H
  MOVWF PORTD             ;the 1st line address.
  CALL ENABLE
  CALL WRITE1             ;¡°WWW.PIC16.COM"
  MOVLW 0C0H
  MOVWF PORTD            ;the 2nd line address. 
  CALL ENABLE
  CALL WRITE2            ;¡°TEL0755-83643980" 
  GOTO  MAIN
  
;****************** send the 1st data program***************
WRITE1
  CLRF COUNT             ;clear offset
WRITE_A
  MOVFW COUNT
  CALL TABLE             ;search to display www.pic16.com
  MOVWF TMP1             ;
  
  INCF COUNT,1           ;offset added
  MOVFW TMP1             
  XORLW 00H              ;check if finished.(the last byte is 00h.)
  BTFSC STATUS,Z
  GOTO  $+4              ;all display finished.
  MOVFW TMP1
  CALL WRITE3            ;no, send to LCD
  GOTO WRITE_A           ;
  RETURN                 ;

;****************** send the 2nd data program*********
WRITE2                 
  CLRF COUNT       ;clear offset            
WRITE2_A                                    
  MOVFW COUNT                               
  CALL TABLE1      ;search to display 0755-83643980  
  MOVWF TMP1                                      
  CALL WRITE3        
  INCF COUNT,1         ;offset added                     
  MOVFW TMP1                                      
  XORLW 00H             ;check if finished.(the last byte is 00h.)                                                                            
  BTFSS STATUS,Z                                  
  GOTO WRITE2_A         ;no, continue to display
  RETURN                ;yes, return.  
                                                  
;******************send data to lcd.************
WRITE3                                            
  MOVWF PORTD           
  BSF RS
  BCF RW
  BCF E
  CALL DELAY
  BSF E
  RETURN

;****************send command to lcd.**************
ENABLE
  BCF RS         ;
  BCF RW
  BCF E
  CALL DELAY
  BSF E
  RETTURN

;*********************delay subroutine******************
DELAY                 ;subroutine name and also is the entry.
 MOVLW   0FFH         ;
 MOVWF   20H          ;send external loop count 0ffh to 20h
LP0
 MOVLW   0FFH         ;
 MOVWF   21H          ;send internal loop count 0ffh to 21h
LP1
 DECFSZ  21H,1        ;decrease 21h,if 0,then jump
 GOTO     LP1         ;continue loop at LP1
 DECFSZ   20H,1       ;decrease 20h,if 0,then jump
 GOTO     LP0         ;continue loop at LP0
 RETURN               ;
 END                  
