//THE experiment is to familiarity the use of 12864LCD
//12864LCD with the lib of chinese      
//program to display company's logo and tel.
//the configration of hardware   
//Tip:Please open RA4 pull UP, will S10'S NO.4 in the "on"   ,Jump J14 all connect, 

 #include<pic.h>
 __CONFIG(0x1832);        
//__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC
 

#define  rs  RA5                    //COMMNAD/DATA SELECT            
#define  rw  RA4                    //READ/WRITE SELECT              
#define  e   RA3                    //ENABLE SIGNAL                  
#define  psb RA2                    //PARALLEL/SERIAL SELECT（H/L）  
#define  rst RA0                    //RESET SIGNAL                   
#define  nop()  asm("nop")          //nop func

//深圳乾龙盛电子
const unsigned char TAB1A[ ]={0xC9,0xEE,0xDB,0xDA,0xC7,0xAC,0xC1,0xFA,0xCA,0xA2,0xB5,0xE7,0xD7,0xD3};
//WWW.PIC16.COM
const unsigned char TAB1B[ ]={' ', ' ', 'W', 'W', 'W', '.', 'P', 'I', 'C', '1','6', '.', 'C', 'O', 'M', ' '};      
//TEL0755-28187975
const unsigned char TAB1C[ ]={'T', 'E', 'L' ,'0' ,'7', '5' ,'5','-', '2', '8','1', '8' ,'7','9' ,'7','5'};    
//FAX0755-28187976     
const unsigned char TAB1D[ ]={'F', 'A', 'X', '0', '7', '5', '5', '-','2', '8','1', '8', '7', '9', '7', '6'};       
 unsigned int lcd_x;                //X address    
 unsigned int lcd_y;                //Y address    
  bit busy;                         //busy flag    

void init();                        //system init.   
void lcd_init();                    //LCD init       
void clear_p();                     //clear screen   
void han_wr2a();                    //company name.
void han_wr2b();                    //company website.
void han_wr2c();                    //company tel.
void han_wr2d();                    //company fax.
void wr_zb();                       //display setting mode.
void flash();                       //lcd blink func.
void qushu(int counts,const unsigned char *ps);       //search table.
void send_d(unsigned char x);       //send data
void send_i(unsigned char x);       //send command.
void chk_busy();                    //check busy sub.
void delay();                       //delay func, decide the speed of display.
void delay1();                      //delay func, decide the speed of blink.

//-------------------------------------------
//main
void main()
{
   while(1)
     {
       init();                      //system init.
       lcd_init();                  //    
       clear_p();                   //    
       han_wr2a();                  //company name.        
       han_wr2b();                  //company website.     
       han_wr2c();                  //company tel.     
       han_wr2d();                  //company fax.     
       delay();                     //
       flash();                     //
       clear_p();                   //
     }
}

//-------------------------------------------
//I/O口 setting func.
void init()
{
  TRISA=0X00;                       //A port as output         
  TRISD=0X00;                       //d port as output         
  ADCON1=0X06;                      //A port as ordinary i/o   
}

//-------------------------------------------
//-------------------------------------------
void lcd_init()
{
  rst=0;                         //reset LCD
  delay();                        
  rst=1;                         //LCD normal work.
  nop();        
  psb=1;                         //8 bit as parrallel.
  send_i(0x30);                  //basic operation instruction
  send_i(0x01);                  //off display  
  send_i(0x06);                  //set the cursor's moving direction.
  send_i(0x0c);                  //on display,off cursor,off blink
}

//-------------------------------------------
//company name.
void han_wr2a()
{
  send_i(0x81);                     //set display position
  qushu(0xe,TAB1A);                 //get data from table
}

//-------------------------------------------
//company website.
void han_wr2b()
{
  send_i(0x90);                    //set display position  
  qushu(0x10,TAB1B);               //get data from table   
}  
  
//-------------------------------------------
//company tel.
void han_wr2c()
{
  send_i(0x88);                   //set display position  
  qushu(0X10,TAB1C);              //get data from table   
}

//-------------------------------------------
//company fax.
void han_wr2d()
{
  send_i(0x98);                  //set display position  
  qushu(0X10,TAB1D);             //get data from table   
}

//display setting.
void wr_zb()
{
  send_i(lcd_y);
  send_i(lcd_x);
}

//-------------------------------------------
//blink
void flash()
{
  send_i(0x08);                  //off display.
  delay1();                      //delay
  send_i(0x0c);                  //on display
  delay1();
  delay1();                      //delay
  send_i(0x08);                  //off
  delay1();
  send_i(0x0c);                  //on
  delay1();
  delay1();
  send_i(0x08);                  //off
  delay1();
  send_i(0x0c);                  //on
  delay1();
  delay1();
}

//-------------------------------------------
//clear screen
void clear_p()
{
  send_i(0x1);                   //clear all
  send_i(0x34);                  //extend.
  send_i(0x30);                  //basic
}

//------------------------------------------
//search.
void qushu(int counts,const unsigned char *ps)
{
  int i;                         //define loop count.
  for(i=counts;i>0;i--)          //
     {  
        send_d(*ps);             //
        delay();                 //
        ps++;                    //get next.
     }
}

//-------------------------------------------
//display the next.
void send_d(unsigned char x)
{
   chk_busy();                  //check busy.
   rs=1;                        //data not commnad.  
   rw=0;                        //write not read.    
   PORTD=x;                     //data to bus.       
   e=1;                         //enable.            
   nop();
   nop();
   nop();                       
   e=0;                         //disable.
}

//--------------------------------------------
//send command.
void send_i(unsigned char x)
{
   chk_busy();                   //check lcd if busy. 
   rs=0;                         //data not commnad.  
   rw=0;                         //write not read.    
   PORTD=x;                      //data to bus.       
   e=1;                          //enable.            
   nop();
   nop();
   nop();
   e=0;                         //disable.
}

//-------------------------------------------
//check lcd busy.
void chk_busy()
{  
   busy=1;                      //set busy signal                   
   TRISD=0XFF;                  //change the bus to input.          
   rs=0;                        //command not data.                 
   rw=1;                        //read not write.                   
   while(busy)                  
      {
         nop();
         nop();
         nop();
         e=1;                   //enable.
         nop();
         nop();
         nop();
         if(!RD7) busy=0;       //
         nop();
         nop();
         nop();
         e=0;                   //DISABLE.
      }
   e=0;                         //DISABLE.
   TRISD=0X00;                  //bus as output.
 }

//-------------------------------------------
//delay
void delay()
{
    int i;
    for(i=0;i<5000;i++)
       {;}
}

//-------------------------------------------
//delay1
void delay1()
{
    int i;
    for(i=0;i<10;i++)
      {
        delay();               //call delay.
      }
} 
