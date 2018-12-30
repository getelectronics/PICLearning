
//experiment purpose: familiar A/D conversion

//software thought:select RAO as simulate input routeway

//	   continue convert four times and get average  as the convert result

//	   finally result get the only low 8 bits.

//	   the result send to LED low 3 bits display

//hardware request:SW S14 the second bit ON ,the first bit OFF

//	   SW S6 all set ON,S5 4-6 bits SET ON ,1-3 bits set OFF

//	   in order to not affect the result,the other SW must set OFF
#include<pic.h>              //include MCU head file
 __CONFIG(0x1832);        
//THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
//LOW power programme OFF,encrypt,4M crystal HS surge.
 const char TABLE[]={0xc0,0xf9,0xa4,0xb0,0x99,0x92,0X82,0XF8,0X80,0X90}; 
 //define the table of constant 0-9
 void  DELAY();              //delay function declare
 void  init();               //I/O PORT initialize function declare
 void  display(int x);       //display function declare
//------------------------------------------------
  //main program
 void  main()               
 {
   int result=0x00;         //define convert result register               
   while(1)                 //dead circle                                  
   {                                                                       
   int i;                   //define the times of circle control           
   result=0x00;             //clear the convert result                     
   for(i=5;i>0;i--)         //get the average of five convert results      
     {                                                                     
      init();               //call initialize function                     
      ADGO=0X1;             //start convert                                
      while(ADGO);          //wait for finish convert                      
      result=result+ADRESL; //accumulative total convert results           
      }                                                                    
      result=result/5;      //get the average of five convert results      
     display(result);       //call display function                        
   }
  }
//-----------------------------------------------
 //initialize function

 void  init()               
  {
   PORTA=0XFF;               
   PORTD=0XFF;               //close all display                                           
   TRISA=0X1;                //set RA0 INPUT,the others OUTPUT                             
   TRISD=0X00;               //set D PORT all OUTPUT                                       
   ADCON1=0X8E;              //set RA0 simulate INPUT,the others general I/O               
   ADCON0=0X41;              //system clock Fosc/8,select RA0 routeway,allow ADC work      
   DELAY();                  //ensure sampling delay                                       
   }
//-----------------------------------------------
//display function            
 void display(int x)          
   {
     int  bai,shi,ge,temp;   //define four temporary variable                 
     temp=x;                 //temporary keep AD convert result               
     bai=temp/0x64;          //get display hundred bit                        
     shi=(temp%0x64)/0xa;    //get display ten bit                            
     ge=(temp%0x64)%0xa;     //get display Entries bit                        
     PORTD=TABLE[bai];       //get the display hundred bit code from table    
     PORTA=0x37;             //RA3 OUTPUT low,light hundred bit display       
     DELAY();                //delay some time,ensure display brightness      
     PORTD=TABLE[shi];       //get the display ten bit code from table        
     PORTA=0x2F;             //RA4 OUTPUT low,light ten bit display           
     DELAY();                //delay some time,ensure display brightness      
     PORTD=TABLE[ge];        //get the display Entries bit code from table    
     PORTA=0x1F;             //RA5 OUTPUT low,light Entries bit display       
     DELAY();                //delay some time,ensure display brightness      
   }

//----------------------------------------------
//delay program 
void  DELAY()              //delay program            
    {                                                 
     int i;                 //define integer variable 
     for(i=0x100;i--;);     //delay                   
    }
