// potenciometro controla la matriz 
// y buzzer al mismo tiempo envia por 
// el puerto serie

#include "mbed.h"
#include "neopixel.h"

// Matrix led output pin
#define MATRIX_PIN P0_9
#define NLEDS 25

AnalogIn   ain(P0_22);

neopixel::Pixel buffer[NLEDS];
PwmOut speaker(P0_8);
int max_led = 30;

void setPixel(uint32_t posicion, uint8_t red, uint8_t green, uint8_t blue) {
  buffer[posicion].red=red;
  buffer[posicion].green=green;
  buffer[posicion].blue=blue;
}

int main()
{
    // Turn off miniblip buzzer
    speaker=0.0;

    while(true) {   
        float pot = ain.read();
    
        int rgb = floor(max_led*pot); 
        neopixel::PixelArray array(MATRIX_PIN);
        for(int i=0;i<NLEDS;i++) {
            setPixel(i, rgb, max_led-rgb, max_led-rgb);
        }
                
        array.update(buffer, NLEDS); 

    }
    
}// miniblip led matrix demo
