;experiment purpose: familiar how to judge key pressed

;when no key pressed LED display ¡°FF¡±,have a key pressed LED display the number of the pressing key

;hardware request: SW S1 ON ,S6 ON ,S5 5-6 bits ON,the others bits OFF,the other SW OFF
#include<p16f877A.inc>    ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
;*******************define user registers*********************
DISPLAYVAL1   EQU    20H  ;display high register
DISPLAYVAL2   EQU    21H  ;display low register
 
;******************program entrance address************************
 ORG       00H
 NOP                       ;the nop instruction of ICD require
 GOTO      MAIN            ;jump to main program

;*****************check table program*****************************
TABLE
 ADDWF     PCL,1           ;PC add excursion address
 RETLW     0C0H            ;the code of 0
 RETLW     0F9H            ;the code of 1
 RETLW     0A4H            ;the code of 2
 RETLW     0B0H            ;the code of 3     
 RETLW     83H             ;the code of 4
 RETLW     88H             ;the code of A
 RETLW     8EH             ;the code of F

;****************main program*******************************
MAIN
 MOVLW     0FFH
 MOVWF     PORTD           ;close all display
 BANKSEL   TRISA           ;select I/O direct register
 MOVLW     0FH             
 MOVWF     TRISA           ;A PORT high 2 bits OUTPUT,low 4 bits INPUT
 MOVWF     TRISB           ;B PORT high 4 bits OUTPUT,low 4 bits INPUT
 CLRF      TRISD           ;D PORT OUTPUT
 BANKSEL   ADCON1
 MOVLW     06H
 MOVWF     ADCON1          ;A PORT is general I/O PORT
 CLRF      STATUS          ;BANK 0

LOOP
 MOVLW     6
 MOVWF     DISPLAYVAL1
 MOVWF     DISPLAYVAL2     ;the excursion address of F
 BTFSC     PORTB,0         ;if B0 pressed
 GOTO      PB_1            ;no,judge B1 pressed
 CALL      DELAY           ;delay ,clear disturb signal
 BTFSC     PORTB,0         ;judge B0 pressed again
 GOTO      PB_1            ;no
 MOVLW     4               ;yes,the excursion address of b
 MOVWF     DISPLAYVAL1
 MOVLW     0               ;the excursion address of 0
 MOVWF     DISPLAYVAL2
 GOTO      LOOP_END        ;jump to display
PB_1
 BTFSC     PORTB,1         ;judge if B1 pressed
 GOTO      PB_2            ;no,judge if B2 pressed
 CALL      DELAY           ;delay ,clear disturb signal
 BTFSC     PORTB,1         ;judge if B1 pressed again
 GOTO      PB_2            ;no
 MOVLW     4
 MOVWF     DISPLAYVAL1     ;yes,the excursion address of b
 MOVLW     1
 MOVWF     DISPLAYVAL2     ;yes,the excursion address of 1
 GOTO      LOOP_END        ;jump to display
PB_2
 BTFSC     PORTB,2         ;judge if B2 pressed
 GOTO      PB_3            ;no,judge if B3 pressed
 CALL      DELAY           ;delay ,clear disturb signal
 BTFSC     PORTB,2         ;judge if B2 pressed again
 GOTO      PB_3            ;no
 MOVLW     4
 MOVWF     DISPLAYVAL1     ;yes,the excursion address of b
 MOVLW     2 
 MOVWF     DISPLAYVAL2     ;the excursion address of 2
 GOTO      LOOP_END        ;jump to display
PB_3
 BTFSC     PORTB,3         ;judge if B3 pressed
 GOTO      PA_0            ;no judge if A0 pressed
 CALL      DELAY           ;delay ,clear disturb signal
 BTFSC     PORTB,3         ;judge if B3 pressed again
 GOTO      PA_0            ;no
 MOVLW     4
 MOVWF     DISPLAYVAL1     ;yes,the excursion address of b
 MOVLW     3
 MOVWF     DISPLAYVAL2     ;the excursion address of 3
 GOTO      LOOP_END        ;jump to display
PA_0
 BTFSC     PORTA,0         ;judge if A0 pressed
 GOTO      PA_1            ;no,judge if A1 pressed
 CALL      DELAY           ;delay ,clear disturb signal
 BTFSC     PORTA,0         ;judge if A0 pressed again
 GOTO      PA_1            ;no
 MOVLW     5               ;yes,the excursion address of A
 MOVWF     DISPLAYVAL1
 MOVLW     0
 MOVWF     DISPLAYVAL2     ;the excursion address of 0
 GOTO      LOOP_END        ;jump to display
PA_1
 BTFSC     PORTA,1         ;judge if A1 pressed
 GOTO      PA_2            ;no,judge if A2 pressed
 CALL      DELAY           ;delay ,clear disturb signal
 BTFSC     PORTA,1         ;judge if A1 pressed again
 GOTO      PA_2            ;no
 MOVLW     5               
 MOVWF     DISPLAYVAL1     ;yes,the excursion address of A
 MOVLW     1
 MOVWF     DISPLAYVAL2     ;the excursion address of 1
 GOTO      LOOP_END        ;jump to display
PA_2
 BTFSC     PORTA,2         ;judge if A2 pressed
 GOTO      PA_3            ;no,judge if A3 pressed
 CALL      DELAY           ;delay ,clear disturb signal
 BTFSC     PORTA,2         ;judge if A2 pressed again
 GOTO      PA_3            ;no
 MOVLW     5
 MOVWF     DISPLAYVAL1     ;yes,the excursion address of A
 MOVLW     2
 MOVWF     DISPLAYVAL2     ;the excursion address of 1
 GOTO      LOOP_END        ;jump to display
PA_3
 BTFSC     PORTA,3         ;judge if A3 pressed
 GOTO      LOOP_END        ;no, jump to display
 CALL      DELAY           ;delay ,clear disturb signal
 BTFSC     PORTA,3         ;judge if A3 pressed again
 GOTO      LOOP_END        ;no, jump to display
 MOVLW     5
 MOVWF     DISPLAYVAL1     ;yes,the excursion address of A
 MOVLW     3
 MOVWF     DISPLAYVAL2     ;the excursion address of 3
 GOTO      LOOP_END
LOOP_END
 MOVF      DISPLAYVAL1,0   ;display low byte
 CALL      TABLE           ;get the code
 MOVWF     PORTD           ;send to LED
 BCF       PORTA,4         ;enable LED display
 CALL      DELAY           ;delay some time,ensure enough brightness
 BSF       PORTA,4         ;close display
 MOVF      DISPLAYVAL2,0   ;display high byte
 CALL      TABLE           ;get the code
 MOVWF     PORTD           ;send to LED
 BCF       PORTA,5         ;enable LED display
 CALL      DELAY           ;delay some time,ensure enough brightness
 BSF       PORTA,5         ;close display
 GOTO      LOOP            ;circle judge if a key pressed and display

;*******************delay subprogram*************************
DELAY
 MOVLW     0FFH
 MOVWF     30H
 DECFSZ    30H,1
 GOTO      $-1
 RETURN

;******************program end**************************
 END
