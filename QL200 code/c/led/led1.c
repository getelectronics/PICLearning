//AIM: LIGHT THE LED.
//FROM RC0 TO RC7
//THE hardware request:SW S11 all ON,the others set OFF.
#include<pic.h>               //include MCU head file
 __CONFIG(0x1832);        
//THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
//LOW power programme OFF,encrypt,4M crystal HS surge.
 
 void  delay();              //delay

 void main()                 //
  {
  while(1)                   //DEAD LOOP 
  
    {
    int i;                   //define int variable.
    TRISC=0X00;              //C port as output.
    PORTC=0X01;              //on rc0
    for(i=8;i>0;i--)        //rotate left for 7 times.
      { 
        delay();
        delay();             //delay
        PORTC=PORTC<<1;      //display rotate left.£¨RC0-->RC7-->RC0)
      }
    }
  }

void delay()                 //delay
  {
    int i;                   //
  for(i=0x65535;i>0;i--)     
    {;}                      //
  }
