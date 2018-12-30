
;experiment purpose: familiar the use of stepper motor 

;1. the drive of stepper motor

;2.how to control the directional  of stepper motor( change power sequence)
;system design:
;1.the experiment use 4 phasic 4 bat stepper motor,the angle is 7.5

;2.the stepper motor drive I/O is RA0-RA3

;3.when press RB0,stop stepper motor,press RB1,stepper motor rotate positive,
;press RB2,stepper motor rotate reverse.
;hardware request:SW S1 6-8 ON,S15 ON,the other SW OFF

include<p16f877a.inc>                  ;include MCU head file
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
;THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
;LOW power programme OFF,encrypt,4M crystal HS surge.

#define  step1 3h                      ;run the first drive signal( different stepper motor, can different fetch line with stepper motor)
#define  step2 6h                     ;run the second drive signal
#define  step3 0ch                      ;run the third drive signal
#define  step4 9h                      ;run the fourth drive signal
#define  stop  portb,0                 ;stop key
#define  right portb,1                 ;positive rotate  key
#define  left  portb,2                 ;reverse rotate  key

 cblock 30h
mode                                   ;stop/positive rotate/reverse rotate control register
 endc

 org 00h                               ;reset entrance address
 nop                                   ;reset entrance address
  goto  main                           ;jump to main program
 org 05h
;****************************main program***************************
main
 banksel adcon1
 movlw   07h
 movwf   adcon1                         ;set A PORT all general data PORT           
 banksel trisa                                                                      
 clrf   trisa                           ;set A PORT OUTPUT                          
 movlw  0ffh                                                                        
 movwf  trisb                           ;set B PORT INPUT                           
 CLRF   OPTION_REG                      ;start B PORT inside pull high function     
 clrf   status                                                                      
 clrf   mode                            ;first stop stepper motor                   
                                                                                    
 movlw  step1                           ;initialize stepper motor state             
 movwf  porta                                                                       
 call   delay 
 
;****************************check stepper motor work state**************
check
 btfsc  stop                           ;if stop work                          
 goto   check1                         ;no,judge the other state              
 movlw  0                                                                     
 movwf  mode                           ;yes ,clear control work state register
 goto   check_end                      ;jump to drive stepper motor work      

check1
 btfsc  right                          ;if positive rotate                   
 goto   check2                         ;no,if reverse rotate                 
 movlw  1                                                                    
 movwf  mode                           ;yes,write work state register 1      
 goto   check_end                      ;jump to drive stepper motor work     
                                                                             
check2                                                                       
 btfsc  left                           ;if reverse rotate                    
 goto   check_end                      ;no,jump to drive stepper motor work  
 movlw  2                                                                    
 movwf  mode                           ;yes,write work state register 1      
 goto   check_end

;***************************drive stepper motor work******************
check_end
 movfw  mode
 btfsc  status,z                       ;judge if stop work         
 goto   check                          ;yes,check control signal   
;read current drive signal,and positive rotate/reverse rotate control,decide the next step output control signal
 movlw  step1                          
 xorwf  porta,0
 btfss  status,z                       ;if currently control signal is step1                                                 
 goto   driver2                        ;no,judge the other signal                                                            
 movlw  1                              ;yes,judge the next step positive rotate or reverse rotate                            
 subwf  mode,0                                                                                                               
 btfss  status,z                       ;if positive rotate                                                                   
 goto   driver1                        ;no,reverse rotate                                                                    
 movlw  step2                          ;if currently control signal is step2                                                 
 movwf  porta                          ;drive signal send to A PORT                                                          
 call   delay                          ;call delay program                                                                   
 goto   check                          ;return to main program to continue judge                                             
driver1                                ;if the next step is reverse rotate                                                   
 movlw  step4                          ;the next step drive signal is step4                                                  
 movwf  porta                          ;drive signal send to A PORT                                                          
 call   delay                          ;call delay program                                                                   
 goto   check                          ;return to main program to continue judge                                             
                                                                                                                             
driver2                                                                                                                      
 movlw  step2                                                                                                                
 xorwf  porta,0                                                                                                              
 btfss  status,z                       ;if currently control signal is step2                                                 
 goto   driver4                        ;no,judge the other signal                                                            
 movlw  1                              ;yes,judge the next step positive rotate or reverse rotate                            
 subwf  mode,0                                                                                                               
 btfss  status,z                       ;if positive rotate                                                                   
 goto   driver3                        ;no,reverse rotate                                                                    
 movlw  step3                          ;the next step drive signal is step3                                                  
 movwf  porta                          ;drive signal send to A PORT                                                          
 call   delay                          ;call delay program                                                                   
 goto   check                          ;return to main program to continue judge                                             
driver3                                                                                                                      
 movlw  step1                          ;the next step drive signal is step1                                                  
 movwf  porta                          ;drive signal send to A PORT                                                          
 call   delay                          ;call delay program                                                                   
 goto   check                          ;return to main program to continue judge                                             
                                                                                                                             
driver4                                                                                                                      
 movlw  step3                          ;the next step drive signal is step3                                                  
 xorwf  porta,0                                                                                                              
 btfss  status,z                      ;if currently control signal is step3                                                  
 goto   driver6                       ;no,judge the other signal                                                             
 movlw   1                            ;yes,judge the next step positive rotate or reverse rotate                             
 subwf  mode,0                                                                                                               
 btfss  status,z                      ;if positive rotate                                                                    
 goto   driver5                       ;no,reverse rotate                                                                     
 movlw  step4                         ;the next step drive signal is step4                                                   
 movwf  porta                         ;drive signal send to A PORT                                                           
 call   delay                         ;call delay program                                                                    
 goto   check                         ;return to main program to continue judge                                              
driver5                                                                                                                      
 movlw  step2                         ; the next step drive signal is step2                                                  
 movwf  porta                         ; drive signal send to A PORT                                                          
 call   delay                         ;call delay program                                                                    
 goto   check                         ;return to main program to continue judge                                              
                                                                                                                             
driver6                                                                                                                      
 movlw  step4                         ;the next step drive signal is step4                                                   
 xorwf  porta,0                                                                                                              
 btfss  status,z                      ;if currently control signal is step4                                                  
 goto   check                         ;no,return to main program to continue judge                                           
 movlw  1                             ;yes,judge the next step positive rotate or reverse rotate                             
 subwf  mode,0                                                                                                               
 btfss  status,z                      ;if positive rotate                                                                    
 goto   driver7                       ;no,reverse rotate                                                                     
 movlw  step1                         ;the next step drive signal is step1                                                   
 movwf  porta                         ;drive signal send to A PORT                                                           
 call   delay                         ;call delay program                                                                    
 goto   check                        ;return to main program to continue judge                                               
driver7                                                                                                                      
 movlw  step3                         ;the next step drive signal is step3                                                   
 movwf  porta                         ;drive signal send to A PORT                                                           
 call   delay                         ;call delay program                                                                    
 goto   check                         ;return to main program to continue judge                                              

;*******************************************delay program********************************
;control OUTPUT frequency
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

;******************************program end*******************************
 end
