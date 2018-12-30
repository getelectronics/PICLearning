                                                                                                                
//experiment purpose: familiar the method of MCU produce voice                                                  
                                                                                                                
//hardware request:SW S10 the third bit set ON,the others set OFF                                               
#include<pic.h>                                                                                                 
 __CONFIG(0x1832);                                                                                              
//THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,                                  
//LOW power programme OFF,encrypt,4M crystal HS surge.                                                          
#define  buz  RC2                              //define voice control I/O                                       
                                                                                                                
//------------------------------------------------------                                                        
//delay function                                                                                                
void sounddelay0(unsigned char delay_count)                                                                     
{                                                                                                               
  unsigned char i;                            //define circle variable                                          
  for(i=delay_count;i>0;i--);                 //frequency choose delay time                                     
}                                                                                                               
                                                                                                                
//------------------------------------------------------                                                        
//voice function                                                                                                
void sound200ms()                                                                                               
{                                                                                                               
  unsigned char fre_repeat,s_max,s_min,i,j;                                                                     
                                                                                                                
//the same frequency repeat times,the highest frequency,the lowest frequency,circle variable i,j                
  fre_repeat=4;                              // the same frequency circle four times                            
  s_max=0x93;                                //voice highest frequency                                          
  s_min=0x47;                                //voice lowest frequency                                           
  for(i=s_max-s_min;i>0;i--)                 //OUTPUT voice inside highest frequency and lowest frequency       
     {                                                                                                          
         for(j=fre_repeat;j>0;j--)           //every voice circle four times                                    
            {                                                                                                   
                buz=1;                       //OUTPUT voice                                                     
                sounddelay0(s_min+i);        //delay some time                                                  
                buz=0;                       //close voice                                                      
                sounddelay0(s_min+i);        //delay some time                                                  
             }                                                                                                  
      }                                                                                                         
}                                                                                                               
                                                                                                                
//-------------------------------------------------------                                                       
//main function                                                                                                 
void main()                                                                                                     
{                                                                                                               
   TRISC=0;                                  //set C PORT OUTPUT                                                
   sound200ms();                             //call voice function                                              
}                                                                                                               
                                                                                                                
                                                                                                                
                                                                                                                