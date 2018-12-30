
//THE experiment is to light the LED of RC0

//THE hardware request:SW S11 the eighth bit set ON,the others set OFF.
#include<pic.h>              //include MCU head file
#include<pic168xa.h>         //include MCU head file
 __CONFIG(0x1832);           

//THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
//LOW power programme OFF,encrypt,4M crystal HS surge.
 #include<pic.h>            //include MCU head file
 #include<pic168xa.h>       //include MCU head file

 void main()                //main program
  {
    while(1)                //dead circle,let RC0 light at all times
      {
         TRISC=0xfe;        //RC0 OUTPUT,the others INPUT
         PORTC=0x01;        //RC0 OUTPUT high,light LED
      }
  }