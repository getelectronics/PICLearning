//AIM: gpio flow lamp, familiar pic12f508's i/o operation
//gp3 is for vpp and reset pin mclr, so don't be lighted.

//hardware configuration:    
//1) clock select OSCC as I/O
//2) off j5/j6 or j7/j8      
//3) switch s13 all on.      

  __CONFIG(0x0ffa);  
//watch dog off,internal RC,GO0/GP1 AS I/O,NOT LOCK,MCLR AS RESET              

//---------------------------------
//
void delay()
{
 int i;
 for(i=5000;i>0;i--);
}

//--------------------------------
//initilize.
void init()
{
    TRIS=0X00;                   //all i/o as output.
    OPTION=0X00;                 //all i/o as ordinary i/o.
}

//-------------------------------
//led on
void led()
{
    char i;
    while(1)
      {
        GPIO=1;                 //on GP0
        for(i=3;i>0;i--)        //loop for 3 times.£¨GP0-GP2£©
          {
            delay();
            delay();
            delay();           //call delay
            GPIO=GPIO<<1;      //rotate left 1 bit to on next led.
          }
         GPIO=0x10;            //on GP4
        for(i=2;i>0;i--)       //loop 2 times.£¨GP4-GP5£©
          {
            delay();
            delay();
            delay();
            GPIO=GPIO<<1;
           }
       }
}

//--------------------------------
//main
void main()
{
   init();                    //call init
   led();                     //call led on.
}
