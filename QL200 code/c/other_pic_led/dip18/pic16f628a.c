
//AIM: gpio flow lamp, familiar PIC16F628A 's i/o operation
//RA5 is for vpp and reset pin mclr, so don't be lighted.

//hardware configuration:    
//1) clock select OSCB as I/O
//2) off j5/j6 or j7/j8      
//3) switch S11,s13 all on.   
//4) RA4 mush add pull high resistance   
#include<pic.h>

  __CONFIG(0x3f38);                 //watch dog off,internal RC,RA6/RA7 as I/O

//-----------------------------------
// delay function
void delay()
{
 int i;                            // define circle variable
 for(i=5000;i>0;i--)               //circle times control
    {
      NOP();                       //time of a instruction periodic
      NOP();
    }
}

//----------------------------------
//initialize function 
void init()
{
    TRISA=0X00;                   // set A PORT OUTPUT
    TRISB=0X00;                   //set B PORT OUTPUT
}

//---------------------------------
// light lamp function
void led()
{
    char i;                      //define circle variable
    while(1)
      {
        PORTA=1;                 //light RA0
        delay();
        delay();
        delay();
        PORTA=2;                 //light RA1
        delay();
        delay();
        delay();
        PORTA=4;                 //light RA2
        delay();
        delay();
        delay();
        PORTA=8;                 //light RA3
        delay();
        delay();
        delay();   
          
         PORTA=0X40;             //light RA6
        for(i=2;i>0;i--)         //circle twice£¨RA6-RA7£©
          {
            delay();
            delay();
            delay();             //call three delay function,make sure the speed of watering lamp flash
            PORTA=PORTA<<1;      //light the next LED
          }
         PORTA=0;                //clear all A PORT display
         PORTB=1;                //light RB0
        for(i=8;i>0;i--)         //circle 8 times£¨RB0-RB7£©
          {
            delay();
            delay();
            delay();
            PORTB=PORTB<<1;
           }
         PORTB=0;                // clear B PORT all display
       }
}

//---------------------------------------
// main function
void main()
{
   init();                       //call initialize function
   led();                        // call light lamp function
}
