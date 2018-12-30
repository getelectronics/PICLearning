//experiment purpose: familiar how to scan key matrix

//program without process key shake,not think multi-keys pressed at the same time too.

//the lowest LED display corresponding key( such as press K10 display 10,press K25 display 25)

//if no key pressed display FF

//key and key scan result corresponding£º
//   key       key scan  result         key      key scan  result
//   K1            0XE7                K09          0XB7
//   K2            0XEB                K10          0XBB
//   K3            0XED                K11          0XBD
//   K4            0XEE                K12          0XBE
//   K5            0XD7                K13          0X77
//   K6            0XDB                K14          0X7B
//   K7            0XDD                K15          0X7D
//   K8            0XDE                K16          0X7E

//hardware request:SW S4 ON ,S6 ON,S5 5-6 bits ON,the others OFF

#include<pic.h>              //include MCU head file
 __CONFIG(0x1832);        
//THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
//LOW power programme OFF,encrypt,4M crystal HS surge.

 int  result;
 void  delay();              //delay function declare
 void  init();               //I/O PORT initialize function declare
 void  scan();               //key scan function declare
 void  display(int x);       //display function declare
//---------------------------------------------------
                             //main program  
void main()
{
  while(1)                   //circle work                        
    {                                                             
      init();                //call initialize subprogram         
      scan();                //call key scan subprogram           
      display(result);       //call result display subprogram     
    }
 }
 
//---------------------------------------------------
//initialize function
void init() 
 {
  ADCON1=0X07;                // set A PORT general I/O PORT                  
  TRISA=0X0f;                 //A PORT low 4 bits INPUT,high 4 bits OUTPUT    
  TRISC=0XF0;                 //C PORT high 4 bits INPUT,low 4 bits OUTPUT    
  TRISD=0X00;                 //set D PORT OUTPUT                             
  PORTA=0XFF;                                                                 
  PORTD=0XFF;                 //clear all display                             
 }

//---------------------------------------------------
//key scan program
void scan()
{
 PORTC=0XF7;                 //C3 OUTPUT low,the other 3 bits OUTPUT high                      
 asm("nop");                 //delay                                                           
 result=PORTC;               //read C PORT                                                     
 result=result&0xf0;         //clear low 4 bits                                                
 if(result!=0xf0)            //judge if high 4 bits all 1(all 1 is no key press)               
   {                                                                                           
     result=result|0x07;     //no,add low 4 bits 0x07 as key scan result                       
   }                                                                                           
 else                        //yes,change low 4 bits OUTPUT, judge if a key press again        
   {                                                                                           
   PORTC=0XFb;               //C2 OUTPUT low,the other 3 bits OUTPUT high                      
   asm("nop");               //delay                                                           
   result=PORTC;             //read C PORT                                                     
   result=result&0xf0;       //clear low 4 bits                                                
   if(result!=0xf0)          //judge if high 4 bits all 1(all 1 is no key press)               
     {                                                                                         
     result=result|0x0b;     //no,add low 4 bits 0x0b as key scan result                       
     }                                                                                         
   else                      //yes,change low 4 bits OUTPUT, judge if a key press again        
       {                                                                                       
       PORTC=0XFd;           //C1 OUTPUT low,the other 3 bits OUTPUT high                      
       asm("nop");           //delay                                                           
       result=PORTC;         //read C PORT                                                     
       result=result&0xf0;   //clear low 4 bits                                                
       if(result!=0xf0)      //judge if high 4 bits all 1(all 1 is no key press)               
        {                                                                                      
        result=result|0x0d;  //no,add low 4 bits 0x0d as key scan result                       
        }                                                                                      
       else                  //yes,change low 4 bits OUTPUT, judge if a key press again        
          {                                                                                    
          PORTC=0XFe;        //C0 OUTPUT low,the other 3 bits OUTPUT high                      
          asm("nop");        //delay                                                           
          result=PORTC;      //read C PORT                                                     
          result=result&0xf0;//clear low 4 bits                                                
          if(result!=0xf0)   //judge if high 4 bits all 1(all 1 is no key press)               
            {                                                                                  
             result=result|0x0e;//no,add low 4 bits 0x0e as key scan result                    
            }                                                                                  
          else               //yes,all key scan end,no key press,set no key press flag         
            {                                                                                  
             result=0xff;    //key scan result 0xff as no key press flag                       
            }   
          }      
      }
   }
 }

//----------------------------------------------------------
//display program
void   display(int x)
  {
   switch(result)                 
      {
       case 0xe7:
                 PORTD=0xf9;PORTA=0X2F;delay();PORTD=0xc0;PORTA=0X1F;delay();break;   //K10
       case 0xeb:
                 PORTD=0xf9;PORTA=0X2F;delay();PORTD=0xf9;PORTA=0X1F;delay();break;   //K11
       case 0xed:
                 PORTD=0xf9;PORTA=0X2F;delay();PORTD=0xa4;PORTA=0X1F;delay();break;   //K12
       case 0xee:
                 PORTD=0xf9;PORTA=0X2F;delay();PORTD=0xb0;PORTA=0X1F;delay();break;   //K13
       case 0xd7:
                 PORTD=0xf9;PORTA=0X2F;delay();PORTD=0x99;PORTA=0X1F;delay();break;   //K14
       case 0xdb:
                 PORTD=0xf9;PORTA=0X2F;delay();PORTD=0x92;PORTA=0X1F;delay();break;   //K15
       case 0xdd:
                 PORTD=0xf9;PORTA=0X2F;delay();PORTD=0X82;PORTA=0X1F;delay();break;   //K16
       case 0xde:
                 PORTD=0xf9;PORTA=0X2F;delay();PORTD=0XF8;PORTA=0X1F;delay();break;   //K17
       case 0xb7:
                 PORTD=0xf9;PORTA=0X2F;delay();PORTD=0X80;PORTA=0X1F;delay();break;   //K18
       case 0xbb:
                 PORTD=0xf9;PORTA=0X2F;delay();PORTD=0X90;PORTA=0X1F;delay();break;   //K19
       case 0xbd:
                 PORTD=0xa4;PORTA=0X2F;delay();PORTD=0xc0;PORTA=0X1F;delay();break;   //K20
       case 0xbe:
                 PORTD=0xa4;PORTA=0X2F;delay();PORTD=0xf9;PORTA=0X1F;delay();break;   //K21
       case 0x77:
                 PORTD=0xa4;PORTA=0X2F;delay();PORTD=0xa4;PORTA=0X1F;delay();break;   //K22
       case 0x7b:
                 PORTD=0xa4;PORTA=0X2F;delay();PORTD=0xb0;PORTA=0X1F;delay();break;   //K23
       case 0x7d:
                 PORTD=0xa4;PORTA=0X2F;delay();PORTD=0x99;PORTA=0X1F;delay();break;   //K24
       case 0x7e:
                 PORTD=0xa4;PORTA=0X2F;delay();PORTD=0x92;PORTA=0X1F;delay();break;   //K25
       case 0xff:
                 PORTD=0x8e;PORTA=0X2F;delay(); PORTD=0x8e; PORTA=0X1F; delay();      //no key press
      }
   }

//------------------------------------------------------------------
//delay program
void  delay()              //delay program 
    {
     int i;                 //define integer variable
     for(i=0x100;i--;);     //delay
    }

     
