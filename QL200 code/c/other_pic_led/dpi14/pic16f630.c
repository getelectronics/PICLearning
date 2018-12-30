
//AIM: RA0-RA5,RC0-RC5 flow lamp, familiar PIC16F630 's i/o operation
//RA3 is for vpp and reset pin mclr, so don't be lighted.

//hardware configuration:    
//1) clock select OSCC as I/O
//2) off j5/j6 or j7/j8      
//3) switch S11,s13 all on.   
#include<pic.h>

  __CONFIG(0x31b4);  

//watch dog off,internal RC,RA4/RA5 as I/O,MCLR as reset
//------------------------------------
//delay function
void delay()
{
 int i;                        // define circle variable                                                                                                                                                                            
 for(i=5000;i>0;i--)           //circle times control                                                                                                                                                                               
    {                                                                                                                                                                                                                               
      NOP();                   //time of a instruction periodic                                                                                                                                                                     
      NOP();                                                                                                                                                                                                                        
    }
}

//------------------------------------
//initialize function 
void init()
{
    TRISA=0X00;                //set A PORT OUTPUT             
    TRISC=0X00;                //set C PORT OUTPUT             
    CMCON=0X07;               // set A PORT general data I/O
}

//------------------------------------
//light lamp function
void led()
{
    char i;                   //define circle variable        
    while(1)                                                  
      {                                                       
        PORTA=1;              //light RA0                     
        for(i=3;i>0;i--)      // circle times£¨RA0-RA2£©      
          {                                                   
            delay();                                          
            delay();                                          
            delay();          //call three delay function     
            PORTA=PORTA<<1;   //light the next lamp           
          }                                                   
         PORTA=0X10;          //light RA4                     
        for(i=2;i>0;i--)      // circle twice£¨RA4-RA5£©      
          {                                                   
            delay();
            delay();
            delay();
            PORTA=PORTA<<1;
          }
         PORTA=0;            // clear A PORT all display                                                                             
         PORTC=1;                                                                                                                    
        for(i=6;i>0;i--)         //light RC0                                                                                         
          {                  //circle six times£¨RB0-RB5£©                                                                           
            delay();
            delay();
            delay();
            PORTC=PORTC<<1;
           }
         PORTC=0;           //clear B PORT all display     
       }
}

//--------------------------------------
//main function
void main()
{
   init();                 //call  initialize function
   led();                  //call light lamp function 
}
