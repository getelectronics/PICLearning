
;experiment purpose: familiar the use of stepper motor 

;1. the drive of stepper motor

;2.how to control the shift distance  of stepper motor

;system design:

;1.the experiment use 4 phasic 4 bat stepper motor,the angle is 7.5

;2.the stepper motor drive I/O is RA0-RA3

;hardware request:SW S1 6-8 bits ON,S15 ON,the other SW OFF

include<p16f877a.inc>                  ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
;THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
;LOW power programme OFF,encrypt,4M crystal HS surge.

#define  step1 9h                      ;run the first drive signal( different stepper motor, can different fetch line with stepper motor)
#define  step2 0ch                     ;run the second drive signal
#define  step3 6h                      ;run the third drive signal
#define  step4 3h                      ;run the fourth drive signal

count    equ   20h
 
 org 00h                               ;reset entrance address
 nop                                   ;the nop instruction of ICD require
 goto  main                           ;jump to main program
 org 05h
;****************************main program***************************
main
 banksel adcon1
 movlw   07h
 movwf   adcon1                        ;set A PORT all general data PORT                                     
 banksel trisa                                                                                               
 clrf   trisa                          ;set A PORT OUTPUT                                                    
 clrf   status                                                                                               
 clrf   porta                                                                                                
 movlw  .12                            ;circle times of stepper motor circumrotate one time 360/(7.5*4)      
 movwf  count                                                                                                
loop                                                                                                         
 movlw  step1                          ;the first step                                                       
 movwf  porta                                                                                                
 call   delay                                                                                                
 movlw  step2                          ;the second step                                                      
 movwf  porta                                                                                                
 call   delay                                                                                                
 movlw  step3                          ;the third step                                                       
 movwf  porta                                                                                                
 call   delay                                                                                                
 movlw  step4                          ;the fourth step                                                      
 movwf  porta                                                                                                
 call   delay                                                                                                
                                                                                                             
 decfsz count,1                        ;if finish cycle a time                                               
 goto   loop                           ;no, continue cycle                                                   
 clrf   porta                          ;yes,stop cycle                                                       
 goto   $-1                            ;stop MCU                                                             

;*******************************delay program**************************
;control output frequency
delay
 movfw  0FH
 movwf  21h                         

 movlw  0ffh
 movwf  22h

 decfsz 22h,1
 goto   $-1

 decfsz 21h,1
 goto   $-5
 return

;*********************************program end**********************************
 end
