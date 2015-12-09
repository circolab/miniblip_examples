// Color wav in the RGB matrix -- UNTESTED so far
// Needs Adafruit NeoPixel library and Arduino IDE, I believe
// Antonio Luque  aluque@gte.esi.us.es 2015-12-09

// As I don't have a miniblip board with me, I cannot test the program, but I promise to 
// check as soon as I get one :)

#include "Adafruit_NeoPixel.h"


// Matrix led output pin
#define MATRIX_PIN P0_9
#define NLEDS 40

Adafruit_NeoPixel strip;

int x0,y0;
static double time;
static double alpha;
static double radius;
static int sent;

void setXY(int x, int y, int r, int g, int b)
{
  strip.setPixelColor(x + (y * 8), r, g, b);
}

void circle()
{
  x0=35;
  y0=20;
  if(sent==0) radius++;
  if(sent!=0) radius--;
  if(radius>80 && sent==0) { sent=1; }
  if(radius<=0 && sent!=0) { sent=0; }
  fillmatrixcircle(radius);
  strip.show();
  delay(20);
}

void fillmatrixcircle(double radius) 
{

  int st;
  for(int i=0;i<8;++i) {
    for(int j=0;j<5;++j) { 
      st=intensitycircle(10*i,10*j,radius);
      setXY(i,j,0.5*st,0.1*st,0.6*st);
    }
  }
}

int intensitycircle(int x,int y,double radius)
{
  double dist=sqrt((x-x0)*(x-x0)+(y-y0)*(y-y0));
  return max(0,255-15*abs(dist-radius));  
}



int main()
{
    // setup

   
    strip = Adafruit_NeoPixel(60, MATRIX_PIN, NEO_GRB + NEO_KHZ800);
    strip.begin();
    strip.show(); // Initialize all pixels to 'off'
    
    wait(1);
    
    while(1) {

        // draws a circle resembling a water wave
        circle();
                
    }
}
