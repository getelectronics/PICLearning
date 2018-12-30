//experiment purpose: familiar how to use D/A convert MCU
//send the convert data to D/A chip TLC5615,start D/A convert
//observe CON36 voltage with multimeter or oscillograph
//hardware request:SW S8 all ON ,the other SWS all OFF

#include<pic.h>              //include MCU head file
 __CONFIG(0x1832);        
//__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC

#define value1 0xf5;         //convert data high 4 bits(high half byte is inefficacy data)
#define value2 0xfc;         //convert data low 6 bits(low half byte is inefficacy data)

//------------------------------------------------
//MAIN ROUTINE
void main()
 {
   int temp;                 //define a temp reg
   PORTC=0XF4;               //pull low clock signal
   TRISC=0X10;               //set RC4£¨SDI£© input ,others output
   SSPSTAT=0X40;             //CKE=1 falling edge send data(according to TCL5615)
   SSPCON=0X20;              //SSPEN=1£¬CKE=0£¬SPI main control mode Fosc/4
   PORTC=0X00;               //pull lowclock signal and cs enable.
   SSPBUF=value1;            //send high nibble.
   while(!SSPIF);            //wait for send finished.
   SSPIF=0X0;                //clear interrupt flag.
   temp=SSPBUF;              //clear receive reg.
   SSPBUF=value2;            //send the low 6 bits.
   while(!SSPIF);            //wait for send finished.
   SSPIF=0x0;                //clear interrupt flag.
   PORTC=0X04;               //cs disable.
   while(1);
 }
