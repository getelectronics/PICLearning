                                                                      
//AIM: RA0-RA5,RC0-RC5 flow lamp, familiar PIC16F57 's i/o operation 

//hardware configuration:      
//2) off j5/j6 or j7/j8        
//3) switch S11,s12,s13 all on.    

#include<pic.h>

__CONFIG(0x0ffa);                  //watch dog off,HS osc

//-----------------------------------
//
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
    TRISA=0X00;                   //set A PORT OUTPUT            
    TRISB=0X00;                   //set B PORT OUTPUT            
    TRISC=0X00;                   //set C PORT OUTPUT 
}

//---------------------------------
//light lamp function  
void led()
{
    char i;                      //define circle variable   
    while(1)
      {
        PORTA=1;                 //on RA0
        delay();
        delay();
        delay();
        PORTA=2;                 //on RA1
        delay();
        delay();
        delay();
        PORTA=4;                 //on RA2
        delay();
        delay();
        delay();
        PORTA=8;                 //on RA3
        delay();
        delay();
        delay();      
     
        PORTA=0;                //clear A PORT all display     
        PORTB=1;                //on RB0
        for(i=8;i>0;i--)         //circle 8 times£¨RB0-RB7£©
          {
            delay();
            delay();
            delay();
            PORTB=PORTB<<1;
           }
        PORTB=0;                //clear B PORT all display 
        PORTC=1;                //on RC0
        for(i=8;i>0;i--)         //circle 8 times£¨RC0-RC7£©
          {
            delay();
            delay();
            delay();
            PORTC=PORTC<<1;
           }
         PORTC=0;                //clear C PORT all display  
       }
}

//--------------------------------------                      
//main function                                               
void main()                                                   
{                                                             
   init();                 //call  initialize function        
   led();                  //call light lamp function         
}
