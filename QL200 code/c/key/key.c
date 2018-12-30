//experiment purpose: familiar how to judge key pressed

//when no key pressed LED display ¡°FF¡±,have a key pressed LED display the number of the pressing key

//hardware request: SW S1 ON ,S6 ON ,S5 5-6 bits ON,the others bits OFF,the other SW OFF

#include<pic.h>              //include MCU head file
 __CONFIG(0x1832);        
//THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
//LOW power programme OFF,encrypt,4M crystal HS surge.

 int  result;
 void  delay();              //delay function declare
 void  init();               //I/O PORT initialize function declare
 void  scan();               //key scan function declare
 void  display(int x);       //display function declare

//------------------------------------------------
//main program
void main()
 { 
    while(1)                 //dead circle
      {
        init();              //call initialize function
        scan();              //call key scan function
        display(result);     //call display result function
      }
 }

//------------------------------------------------
//initialize program
void  init()
 {
  ADCON1=0X07;             //set A PORT general I/O PORT                  
  TRISA =0X0F;             //A PORT high 2 bits OUTPUT,low 4 bits INPUT   
  TRISB=0X0F;              //B PORT low 5 bits INPUT                      
  TRISD=0X00;              //D PORT OUTPUT                                
  PORTA=0XFF;                                                             
  PORTD=0XFF;              //close all display                            
 }

//------------------------------------------------
//°´¼üÉ¨Ãè³ÌÐò
void  scan()
 {
   result=0x8;             //initialize key scan result   
   if(RA0==0)                // judge if a0 press    
      result=0x0;           //yes£¬the scan result is 0
   if(RA1==0)               // judge if a1 press    
      result=0x1;           //yes£¬the scan result is 1
   if(RA2==0)                // judge if a2 press    
      result=0x2;
   if(RA3==0)               // judge if a3 press    
      result=0x3;
   if(RB0==0)              //judge if B0 press     
      result=0x4;                                  
   if(RB1==0)              //judge if B1 press     
      result=0x5;                                  
   if(RB2==0)              //judge if B2 press     
      result=0x6;                                  
   if(RB3==0)              //judge if B3 press     
      result=0x7;                                  
  }                       

//-------------------------------------------------
//display result program
void  display(int x)
 {
   switch(x)                //different x,different deal 
     {
      case 0x0:
         PORTD=0X88;PORTA=0X2F;delay();PORTD=0XC0;PORTA=0X1F;delay();break;  //A0
      case 0x1:
         PORTD=0X88;PORTA=0X2F;delay();PORTD=0XF9;PORTA=0X1F;delay();break;  //A1
      case 0x2:
         PORTD=0X88;PORTA=0X2F;delay();PORTD=0XA4;PORTA=0X1F;delay();break;  //A2
      case 0x3:
         PORTD=0X88;PORTA=0X2F;delay();PORTD=0XB0;PORTA=0X1F;delay();break;  //A3
      case 0x4:
         PORTD=0X83;PORTA=0X2F;delay();PORTD=0XC0;PORTA=0X1F;delay();break;  //B0
      case 0x5:
         PORTD=0X83;PORTA=0X2F;delay();PORTD=0XF9;PORTA=0X1F;delay();break;  //B1
      case 0x6:
         PORTD=0X83;PORTA=0X2F;delay();PORTD=0XA4;PORTA=0X1F;delay();break;  //B2
      case 0x7:
         PORTD=0X83;PORTA=0X2F;delay();PORTD=0XB0;PORTA=0X1F;delay();break;  //B3
      case 0x8:
         PORTD=0X8E;PORTA=0X2F;delay();PORTD=0X8E;PORTA=0X1F;delay();break;  //no key press       
      }
 }

//------------------------------------------------------------------
//delay program    
void  delay()              //delay program            
    {                                                 
     int i;                 //define integer integer  
     for(i=0x100;i--;);     //delay                   
    }
