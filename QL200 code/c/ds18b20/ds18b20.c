//THE experiment is to familiarity the use of DS18B20

//SIX LED display temperature,the integer is two digit,the decimal fraction is four digit.

//THE hardware request:the DS18B20  must insert in the 18B20 socket

//	   S10 the first bit set ON ,the other bits OFF

//	   SW S5¡¢S6 must set ON, the other SWS must set OFF.
#include<pic.h>
__CONFIG(0x1832);        
//THE configure of MCU,watchdog OFF,electrify delay OPEN,power down check OFF,
//LOW power programme OFF,encrypt,4M crystal HS surge.
 
#define  uch unsigned char                   //                                          
# define DQ RA0                              //define 18B20 data PORT                    
# define DQ_DIR TRISA0                       //define 18B20 D PORT direct register       
# define DQ_HIGH() DQ_DIR =1                 //set data PORT INPUT                       
# define DQ_LOW() DQ = 0; DQ_DIR = 0         //set data PORT OUTPUT                      
 unsigned char  TLV=0 ;                      //temperature high byte                     
 unsigned char  THV=0;                       //temperature low byte                      
 unsigned char TZ=0;                         //temperature integer after convert         
 unsigned char TX=0;                         //temperature decimal  after convert        
 unsigned int wd;                            //temperature BCD code  after convert       
                                                                                         
unsigned char shi;                           //integer ten bit                           
unsigned char ge;                            //integer Entries bit                       
unsigned char shifen;                        //ten cent bit                              
unsigned char baifen;                        //hundred cent bit                          
unsigned char qianfen;                       //thousand cent bit                         
unsigned char wanfen;                        //myriad cent bit                           
unsigned char table[]={0xc0,0xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90}; 
//the display code of 0-9     
                              
//-----------------------------------------------------------
//delay function              
void delay(char x,char y) 
{
  char z;
  do{
      z=y;
      do{;}while(--z);
     }while(--x);
 }
//instruction time:7+£¨3*£¨Y-1£©+7£©*£¨X-1£©if add call instruction,set page , seven instruction of  transfer parameter 
                                                                                                                        
//is 14+£¨3*£¨Y-1£©+7£©*£¨X-1£©¡£                                                                                       
                                                                                                                        
//--------------------------------------------------                                                                    
//display function
void display()
{
 TRISA=0X00;                           //set A PORT all OUTPUT                          
 PORTD=table[shi];                     //display integer ten bit                        
 PORTA=0x3e;                                                                            
 delay(10,70);                                                                          
 PORTD=table[ge]&0X7F;                 //display integer Entries bit and decimal dot    
 PORTA=0x3d;                                                                            
 delay(10,70);                                                                          
 PORTD=table[shifen];                  //display decimal ten cent bit                   
 PORTA=0x3b;                                                                            
 delay(10,70);                                                                          
 PORTD=table[baifen];                  //display decimal hundred cent bit               
 PORTA=0x37;                                                                            
 delay(10,70);                                                                          
 PORTD=table[qianfen];                 //display decimal thousand  cent bit             
 PORTA=0x2f;                                                                            
 delay(10,70);                                                                          
 PORTD=table[wanfen];                  //display decimal myriad cent bit                
 PORTA=0x1f;
 delay(10,70);
}

//------------------------------------------------
//system initialize function           
void init()
{
  ADCON1=0X07;                                //set A PORT general data PORT   
  TRISA=0X00;                                 //set A PORT direct OUTPUT       
  TRISD=0X00;                                 //set D PORT direct OUTPUT       
}

//-----------------------------------------------
//reset DS18B20 function   
reset(void)
{
  char presence=1;
  while(presence)
  { 
    DQ_LOW() ;                                //MAIN MCU PULL LOW                                                                       
    delay(2,70);                              //delay 503us                                                                             
    DQ_HIGH();                                //release general line and wait for resistance pull high general line and keep 15~60us    
    delay(2,8);                               //delay 70us                                                                              
    if(DQ==1) presence=1;                     // not receive responsion signal,continue reset                                           
    else presence=0;                          //receive responsion signal                                                               
    delay(2,60);                              //delay 430us                                                                             
   }
  }

//-----------------------------------------------
//write 18b20 one byte function     
void write_byte(uch val)
{
 uch i;
 uch temp;
 for(i=8;i>0;i--)
 {
   temp=val&0x01;                             //shift the lowest bit                   
   DQ_LOW();                                                                           
   NOP();                                                                              
   NOP();                                                                              
   NOP();                                                                              
   NOP();                                                                              
   NOP();                                     //pull high to low,produce write time    
   if(temp==1)  DQ_HIGH();                    //if write 1,pull high                   
   delay(2,7);                                //delay 63us                             
   DQ_HIGH();                                                                          
   NOP();                                                                              
   NOP();                                                                              
   val=val>>1;                                //right shift a bit                      
  }
}

//------------------------------------------------
//18b20 read a byte function  
uch read_byte(void)
{
 uch i;
 uch value=0;                                 //read temperature         
 static bit j;
 for(i=8;i>0;i--)
 {
   value>>=1; 
   DQ_LOW();
   NOP();
   NOP();
   NOP();
   NOP();
   NOP();
   NOP();                                    //6us              
   DQ_HIGH();                                // pull high       
   NOP();                                                       
   NOP();                                                       
   NOP();                                                       
   NOP();                                                       
   NOP();                                   //4us               
   j=DQ;                                                        
   if(j) value|=0x80;                                           
   delay(2,7);                              //63us              
  }
  return(value);
}

//-------------------------------------------------
//start temperature convert function   
void get_temp()
{ 
int i;
DQ_HIGH();
reset();                              //reset,wait for  18b20 responsion                                                                                                               
write_byte(0XCC);                     //ignore ROM matching                                                                                                                            
write_byte(0X44);                     //send  temperature convert command                                                                                                              
for(i=20;i>0;i--)                                                                                                                                                                      
    {                                                                                                                                                                                  
                                                                                                                                                                                       
        display();                    //call some display function,insure the time of convert temperature                                                                              
    }                                                                                                                                                                                  
reset();                              //reset again,wait for 18b20 responsion                                                                                                          
write_byte(0XCC);                     //ignore ROM matching                                                                                                                            
write_byte(0XBE);                     //send read temperature command                                                                                                                  
TLV=read_byte();                      //read temperature low byte                                                                                                                      
THV=read_byte();                      //read temperature high byte                                                                                                                     
DQ_HIGH();                            //release general line                                                                                                                           
TZ=(TLV>>4)|(THV<<4)&0X3f;            //temperature integer                                                                                                                            
TX=TLV<<4;                            //temperature decimal                                                                                                                            
if(TZ>100) TZ/100;                    //not display hundred bit                                                                                                                        
ge=TZ%10;                     //integer Entries bit                                                                                                                            
shi=TZ/10;                    //integer ten bit                                                                                                                                
wd=0;                                                                                                                                                                                  
if (TX & 0x80) wd=wd+5000;
if (TX & 0x40) wd=wd+2500;
if (TX & 0x20) wd=wd+1250;
if (TX & 0x10) wd=wd+625;                //hereinbefore four instructions are turn  decimal into BCD code                         
shifen=wd/1000;                          //ten cent bit                                                                           
baifen=(wd%1000)/100;                    //hundred cent bit                                                                       
qianfen=(wd%100)/10;                     //thousand cent bit                                                                      
wanfen=wd%10;                            //myriad cent bit                                                                        
NOP();                                                                                                                            
}                                                                                                                                 

//--------------------------------------------------
//main function    
void main()
{
   init();                       //call system initialize function                                                                                                                                 
   while(1)                                                                                                                                                                                        
     {                                                                                                                                                                                             
       get_temp();           //call temperature convert function                                                                                                                                   
       display();                //call display function                                                                                                                                           
     }                                                                                                                                                                                             
}                                                                                                                                                                                                  
   
