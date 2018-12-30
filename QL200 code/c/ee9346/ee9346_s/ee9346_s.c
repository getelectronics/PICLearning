#include<pic.h>
 #include<pic168xa.h>

 #define   cs        RB2
 #define   clk       RB3
 #define   d_i       RB4
 #define   d_o       RB5
 #define   ee_addr   0x5
 #define   nop()    asm("nop")

static volatile unsigned char temp @ 0x20;
static volatile bit temp7     @ (unsigned)&temp*8+7;
static volatile bit temp0     @ (unsigned)&temp*8+0;

const char ee_data_write[]={0x5a,0xa5};
unsigned char ee_date[4];
const char table[]={0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90,0x88,0x83,0xC6,0xA1,0x86,0x8E};

 unsigned int  t;

 void      init();
 void      ee_write();
 void      ee_read();
 void      display();
 void      delay();
 void      ee_write_enable();
 void      ee_write1(char x);
 void      ee_read_1();

void  main()
  {
     init();
     while(1)
       {
           if(!RB0)
              {
                ee_write();
              }
           if(!RB1)
              {
                ee_read();
                while(1)
                  {
                    display();
                  }
              }
       }  
   }

void init()
   {
     ADCON1=0X07;
     TRISA=0X30;
     TRISB=0X23;
     TRISD=0X00;
     PORTD=0XFF;
     RBPU=0;
     cs=0;
   }

void ee_write()
   {
     int i;
     ee_write_enable();
     cs=1;
     ee_write1(0x1);
     ee_write1(ee_addr|0x40);
     for(i=0;i<2;i++)
        {
          ee_write1(ee_data_write[i]);
        }
     cs=0;
     nop();
     nop();
     cs=1;
     nop();
     nop();
     while(!d_o);
     cs=0;
     nop();
     nop();
     PORTD=0X90;
     PORTA=0X3E;
   }

void ee_read()
   {
     int i;
     cs=1;
     nop();
     nop();
     ee_write1(0x01);
     ee_write1(ee_addr|0x80);
     for(i=0;i<2;i++)
        {
           ee_read_1();
           ee_date[i]=temp;
        }
     nop();
     cs=0;
     nop();
   }
     
void ee_write_enable()
   {
     cs=1;
     ee_write1(0x01);
     ee_write1(0x30);
     cs=0;
     nop();
     nop();
   }

void ee_write1(char x)
   {
     int i;
     temp=x;
     for(i=0;i<8;i++)
       {
         if(temp7)
           { d_i=1;}
         else 
           {d_i=0;}
         clk=1;
         delay();
         clk=0;
         temp=temp<<1;
         t=temp;
       } 
     nop();
   }

void ee_read_1()
   {
     int j;
     for(j=0;j<7;j++)
       {
         clk=1;
         delay();
         clk=0;
         delay();
         temp=temp<<1; 
         if(d_o) 
            {temp0=1;}
         else   
            {temp0=0;} 
         
         t=temp;
       }
   //  return(temp);
   }


void display()
   { 
     int i;
     i=ee_date[0]&0xf0;
     i=i>>4;
     PORTD=table[i];
     PORTA=0x3e;
     delay();
     i=ee_date[0]&0x0f;
     PORTD=table[i];
     PORTA=0x3d;
     delay();
     
     i=ee_date[1]&0xf0;
     i=i>>4;
     PORTD=table[i];
     PORTA=0x3b;
     delay();
     i=ee_date[1]&0x0f;
     PORTD=table[i];
     PORTA=0x37;
     delay();
   }

void  delay()
   {
     int i;
     for(i=100;i>0;i--);
   }


