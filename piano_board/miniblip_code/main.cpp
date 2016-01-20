// miniblip play sound - capacitative + keyboard out

#include "mbed.h"
#include "USBKeyboard.h" 
#include "neopixel.h"

// Matrix led output pin
#define MATRIX_PIN P0_9
#define NLEDS 25

#define THRESHOLD   2
#define TOUCH_N     4

Ticker tick;
USBKeyboard keyboard;

neopixel::Pixel buffer[NLEDS];

void setPixel(uint32_t posicion, uint8_t red, uint8_t green, uint8_t blue) {
  buffer[posicion].red=red;
  buffer[posicion].green=green;
  buffer[posicion].blue=blue;
}

void pinta(uint8_t red, uint8_t green, uint8_t blue){
    for(int i=0;i<25;i++) {
        setPixel(i, red, green, blue);
    }
}
                
                
uint8_t       key_map[] = {LEFT_ARROW,UP_ARROW,DOWN_ARROW, RIGHT_ARROW,  ' '};
uint8_t       key_map2[] = {'1','2','3' ,'4'};
PinName       touch_pin[] = {P0_11, P0_12, P0_13, P0_14, P0_15};
DigitalInOut *p_touch_io[TOUCH_N];
int mode = 0;

uint16_t touch_data[TOUCH_N] = {0, };

void detect(void)
{
    for (int i = 0; i < TOUCH_N; i++) {
        uint8_t count = 0;
        DigitalInOut *touch_io = p_touch_io[i];
        
        touch_io->input();
        touch_data[i] <<= 1;
        while (touch_io->read()) {
            count++;
            if (count > THRESHOLD) {
                touch_data[i] |= 0x01;
                break;
            }
        }
        touch_io->output();
        touch_io->write(1);
        
        if (0x01 == touch_data[i]) {            // Threshold, get a touch
            keyboard.putc(key_map[i]);
            mode = i+1;
             
        } 
        else if (0x80 == touch_data[i]) {     // Last 7 measurement is under the threshold, touch is released
        }
    }
}

int main()
{
    // setup
    DigitalIn(MATRIX_PIN, PullDown);
    neopixel::PixelArray array(MATRIX_PIN);

    // Turn off miniblip buzzer
    PwmOut speaker(P0_8);
    speaker=0.0;
    
    pinta(0,0,0);
    
    wait(1);
    
    for (int i = 0; i < TOUCH_N; i++) {
        p_touch_io[i] = new DigitalInOut(touch_pin[i]);
        p_touch_io[i]->mode(PullDown);
        p_touch_io[i]->output();
        p_touch_io[i]->write(1);
    }
    
    tick.attach(detect, 1.0 / 64.0);
    
    while(1) {
        // do something
        
        switch (mode){
            case 1:
                pinta(20,0,0);
                break;
            case 2:
                pinta(0,20,0);
                break;
            case 3:
                pinta(0,0,20);
                break;
            case 4:
                pinta(20,20,0);
                break;
            }
        array.update(buffer, NLEDS); 
                
    }
}
