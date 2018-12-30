 //experiment purpose: familiar SPI general line and how to read and write 9346EEPROM 
 
 //when press RBO key ,write DATA and DATA2 in some EEPROM  address from EE¡ªADDR 
 
 //when write finished,the LED display single 9 to indicate finished.
 
 //when key RB1 press,read EEPROM address from  EE¡ªADDR and send to LED display
 
 //hardware request: SW S5¡¢S6¡¢S3 all set ON,S1 7-8 bits set ON
 
 //if use 93C46 from ATMEL,must set ¡°WORD SIZE¡± jumper is sixteen.
 #include<pic.h>
 __CONFIG(0x1832);        
//THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
//LOW power programme OFF,encrypt,4M crystal HS surge.
 
 #define   c_s      RC2
 #define   clk      RC3
 #define   d_i      RC5
 #define   d0       RC4
 #define   ee_addr  0x5
 #define   nop() asm("nop")
 const char ee_data_write[]={0x56,0x78};
 unsigned char ee_date[4];
 const char table[]={0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90,0x88,0x83,0xC6,0xA1,0x86,0x8E};

 unsigned int  temp;

 void      init();
 void      ee_write();
 void      ee_read();
 void      display();
 void      delay();
 void      ee_write_enable();
 void      spi_comm(unsigned char x);

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
     TRISB=0X03;
     TRISC=0X10;
     TRISD=0X00;
     PORTD=0XFF;
     SSPSTAT=0X80;
     SSPCON=0X31;
     INTCON=0X00;
     PIR1=0X00;
     c_s=0;
   }

void ee_write()
   {
     int i,j;
     ee_write_enable();
     c_s=1;
     spi_comm(0x1);
     spi_comm(ee_addr|0x40);
     for(i=0;i<2;i++)
        {
          j=ee_data_write[i];
          spi_comm(j);
        }
     c_s=0;
     nop();
     nop();
     c_s=1;
     nop();
     nop();
     while(!d0);
     c_s=0;
     nop();
     nop();
     PORTD=0X90;
     PORTA=0X3E;
   }

void ee_read()
   {
     int i;
     c_s=1;
     nop();
     nop();
     spi_comm(0x01);
     spi_comm(ee_addr|0x80);
     for(i=0;i<2;i++)
        {
         spi_comm(0);
         ee_date[i]=temp;
        }
     nop();
     c_s=0;
     nop();
   }
     
void ee_write_enable()
   {
     c_s=1;
     spi_comm(0x01);
     spi_comm(0x30);
     c_s=0;
     nop();
     nop();
   }

void spi_comm(unsigned char x)
   {
     SSPBUF=x;
     while(!SSPIF);
     SSPIF=0;
     temp=SSPBUF;
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
