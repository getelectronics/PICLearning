
;THE experiment is to familiarity the use of LCD

;lcd loop to display the website of our company and tel.
;the configration of hardware: lcd connect with chip's port a and d.

;SW S10 the fourth bit ON,the other SW OFF, Jump J14 all connect,
;adjust potentiomete,adjust LCD brightness
#include<pic.h>
 __CONFIG(0x1832);        
//__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC

#define rs RA1
#define rw RA2
#define e  RA3
const char web[ ]={' ','W','W','W','.','P','I','C','1','6','.','C','O','M',' ',' '};
//display company's websiet address
const char tel[ ]={'T','E','L','0','7','5','5','-','2','8','1','8','7','9','7','5'};
//display company's tel number.

void init();                   //I/O init
void lcd_init();               //LCD init
void write_web();              //display company's website
void write_tel();              //display company's tel number.
void write(char x);            //display one byte
void lcd_enable();             //LCD display setting.
void delay();                  //delay

//---------------------------------------
//main
void main()
 { 
    while(1)
      {
        init();                //I/O init
        lcd_init();            //LCD init
        write_web();           //display company's website  
        PORTD=0XC0;            //set the 2nd line display address
        lcd_enable();          //LCD display setting.       
        write_tel();           //display company's tel number.   
      }
 }
 
//---------------------------------------
//I/O init
void init()
 {
    ADCON1=0X07;               //a port as ordinary i/o.
    TRISA=0X00;                //a port as output.
    TRISD=0X00;                //d port as output.
 }

//---------------------------------------
//LCD init
void lcd_init()
 {
    PORTD=0X1;                 //clr screen 
    lcd_enable();
    PORTD=0X38;                //8 bits 2 lines 5*7 mode.  
    lcd_enable();
    PORTD=0X0e;                //display on,cursor on,blink on.
    lcd_enable();
    PORTD=0X06;                //character not move,cursor rotate right.
    lcd_enable();
    PORTD=0X80;                //¡°WWW.PIC16.COM"
    lcd_enable();
 }
 
//--------------------------------------
//¡°WWW.PIC16.COM"
void write_web()
 {
    int i;
    for(i=0;i<0x10;i++)        //total 16 bytes.
       {
         write(web[i]);        //search table.
       }
 }

//--------------------------------------
//¡°TEL0755-83643980"   
 void write_tel()
 {
    int i;
    for(i=0;i<0x10;i++)       //total 16 bytes to display.
       {
         write(tel[i]);       //search table to display
       }
 }
  
//--------------------------------------
//write a byte to lcd.
void write(char x)
 {
  PORTD=x;                   //data send to PORTD
  rs=1;                      //is data not command.
  rw=0;                      //is write not read.
  e=0;                       //pull low enable signal.
  delay();                   //for a while.
  e=1;                       //pull high to build the rising edge.
 }

//--------------------------------------
//lcd display setting 
void lcd_enable()
 {
   rs=0;                     //is command not data
   rw=0;                     //is write not read. 
   e=0;                      //pull low enable signal.           
   delay();                  //for a while.                      
   e=1;                      //pull high to build the rising edge
 }

//--------------------------------------
//delay
void delay()
 {
   int i;
   for(i=0;i<5000;i++);
 }
