//AIM: RA0-RA5,RC0-RC5 flow lamp, familiar PIC10F200 's i/o operation
//GP3 is for vpp and reset pin mclr, so don't be lighted.

//hardware configuration:    
//2) off j5/j6 or j7/j8      
//3) switch s13 all on.   
#include<pic.h>

  __CONFIG(0x0ffb);  
//watch dog off,MCLR as reset,NOT LOCK
//----------------------------------
//delay
void delay()
{
 int i;                    // define circle variable  
 for(i=5000;i>0;i--);      
}

//----------------------------------
//initialize function                                
void init()
{
    TRIS=0X00;             //set all PORT OUTPUT   
    FOSC4=0;               //off GP2's Fosc/4 output.
    OPTION=0X00;           //set all PORT general data I/O    
}

//----------------------------------
//light lamp function            
void led()
{
    char i;                //define circle variable       
    while(1)
      {
        GPIO=1;            //light GP0
        for(i=3;i>0;i--)   //circle times£¨GP0-GP2£©
          {
            delay();
            delay();
            delay();       //call three delay function   
            GPIO=GPIO<<1;  //light the next lamp         
          }
       }
}

//-----------------------------------
//main function                 
void main()
{
   init();                //call  initialize function      
   led();                 //call light lamp function       
}
