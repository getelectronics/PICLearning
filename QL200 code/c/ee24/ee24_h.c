//hardware request: SW S2¡¢S5¡¢S6 all set ON, S1 bit7-8 set ON,
//other swich set OFF

#include<pic.h>
  __CONFIG(0x1832);  
 #define address  0xa
 #define nop() asm("asm") 
 const char ee_data_write[]={0x6,0x5,0x4,0x3,0x2,0x1};
 unsigned char ee_date[6];
 const char table[]={0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90,0x88,0x83,0xC6,0xA1,0x86,0x8E};

void write();
void read();
void wrtacktest();
void i2c_idle();
void delay();
void display();
void init();

void main()
 {
   init();
   while(1)
     {
      if(!RB0)
         {
           write();
         }
      if(!RB1)
         {
           read();
           while(1)
             {
             display();
             }
         }
      }
  }

void init()
  {
   STATUS=0X0;
   PORTD=0XFF;
   ADCON1=0X07;
   TRISC=0XFF;
   TRISA=0X00;
   TRISB=0X03;
   TRISD=0X00;
   SSPADD=0X9;
   SSPSTAT=0X80;
   SSPCON=0X38;
  }
  
void write()
  {
    int i;
    i2c_idle();
    SEN=1;
    while(!SSPIF);
    SSPIF=0;
    SSPBUF=0XA0;
    wrtacktest();
    while(STAT_BF);
    SSPBUF=address;
    wrtacktest();
    while(STAT_BF);
 
    for(i=0;i<6;i++)
      {
         SSPBUF=ee_data_write[i];
         wrtacktest();
      }
    PEN=1;
    nop();
    SSPIF=0;
    delay();
    delay();
    PORTD=0XA4;
    PORTA=0X3E;
 }

void read()
 {
    static volatile unsigned int i;
    i2c_idle();
    SSPIF=0;
    SEN=1;
    while(!SSPIF);
    SSPIF=0;
    SSPBUF=0XA0;
    wrtacktest();
    SSPBUF=address;
    wrtacktest();
    
    i2c_idle();
    SSPIF=0;
    RSEN=1;
    while(!SSPIF);
    SSPIF=0;
    SSPBUF=0XA1;
    wrtacktest();
   
    for(i=0;i<6;i++)
       {
          RCEN=1;
          while(!SSPIF);
          ee_date[i]=SSPBUF;
          while(!SSPIF);
          SSPIF=0;
          if(i>=5) 
              {
                ACKDT=1;
              }
          else     
              {
                ACKDT=0;
              }
          ACKEN=1;
          while(!SSPIF);
          SSPIF=0;
       }
   
    PEN=1;
    while(!SSPIF);
    SSPIF=0;
 }
     
void wrtacktest()
 {
   while(!SSPIF);
   SSPIF=0;
 }

void i2c_idle()
 {
   while(STAT_RW);
   ZERO=0;
   while(ZERO)
     {
       SSPCON2&0x1f;
     }
 }
    
void display()
   { 
     int i;
     i=ee_date[0]&0x0f;
     PORTD=table[i];
     PORTA=0x3e;
     delay();
     i=ee_date[1]&0x0f;
     PORTD=table[i];
     PORTA=0x3d;
     delay();
     
     i=ee_date[2]&0x0f;
     PORTD=table[i];
     PORTA=0x3b;
     delay();
     i=ee_date[3]&0x0f;
     PORTD=table[i];
     PORTA=0x37;
     delay();

     i=ee_date[4]&0x0f;
     PORTD=table[i];
     PORTA=0x2f;
     delay();
     i=ee_date[5]&0x0f;
     PORTD=table[i];
     PORTA=0x1f;
     delay();
   }

void delay()
 {
    int i;
    for(i=0;i<100;i++)
       {;}
 }
 
