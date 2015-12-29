// miniblip Muestra Textos

#include "mbed.h"
#include "neopixel.h"
 
// Pin de la matriz de LEDS
#define DATA_PIN P0_9

#define NLEDS 25
// Modificar la longitud del texto a mostrar
#define LTXT 38

neopixel::Pixel buffer[NLEDS];
PwmOut speaker(P0_8);
neopixel::PixelArray array(DATA_PIN);

//Ventana que del texto que se muetra en cada iteración
int preCarga[25] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

//Texto a mostrar: "FELICES FIESTAS"
int txt[5][57] = {
{1,1,1,0,1,1,1,0,1,0,0,0,1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,1,1,1,0,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,0},
{1,0,0,0,1,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,1,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,0,1,0,0,1,0,1,0,1,0,0,0,0,0,0,0},
{1,1,0,0,1,1,1,0,1,0,0,0,1,0,1,0,0,0,1,1,1,0,1,1,1,0,0,1,1,0,0,1,0,1,1,1,0,1,1,1,0,0,1,0,0,1,1,1,0,1,1,1,0,0,0,0,0},
{1,0,0,0,1,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,1,0,1,0,0,0,0,0,1,0,0,1,0,0,1,0,1,0,0,0,1,0,0,0,0,0},
{1,0,0,0,1,1,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,1,0,0,0,1,0,1,1,1,0,1,1,1,0,0,1,0,0,1,0,1,0,1,1,1,0,0,0,0,0}
};

//Texto a mostrar: "FELIZ 2016"
int F2016[5][38] = {
{1,1,1,0,1,1,1,0,1,0,0,0,1,0,1,1,1,0,0,1,1,1,0,1,1,1,0,0,1,0,1,1,1,0,0,0,0,0},
{1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,1,0,1,0,1,0,1,1,0,1,0,0,0,0,0,0,0},
{1,1,0,0,1,1,1,0,1,0,0,0,1,0,0,1,0,0,0,1,1,1,0,1,0,1,0,0,1,0,1,1,1,0,0,0,0,0},
{1,0,0,0,1,0,0,0,1,0,0,0,1,0,1,0,0,0,0,1,0,0,0,1,0,1,0,0,1,0,1,0,1,0,0,0,0,0},
{1,0,0,0,1,1,1,0,1,1,1,0,1,0,1,1,1,0,0,1,1,1,0,1,1,1,0,0,1,0,1,1,1,0,0,0,0,0}
};

//Color del texto
int cred=10;
int cblue=10;
int cgreen=0;

//limpia la matriz
void limpiar(){
    
    for(int i=0;i<NLEDS;i++){
        buffer[i].red=0;
        buffer[i].green=0;
        buffer[i].blue=0;
    }
}

//Carga una ventana de 5x5 que será lo siguiente a mostrar. Desplaza cada una columna una posición y carga la siguiente
//que corresponda desde la matriz del texto a mostrar
void ventana(int ciclo){
    for (int i=NLEDS-1;i>4;i--){
       preCarga[i] = preCarga[i-5]; 
    }
    int x = 0;
    for (int j=4; j>=0; j--){
//       preCarga[j] = txt[x][ciclo];
       preCarga[j] = F2016[x][ciclo];
       x++;
    }
}

//Activa un pixel dado con los colores seleccionados
void fill_pixel(int x, int red, int green, int blue){

    buffer[x].red=red;
    buffer[x].green=green;
    buffer[x].blue=blue;
}

//Activa los leds en funcion de la ventana precargada
void dibujaVentana(){
    for(int i = 0;i<NLEDS;i++){
        if(preCarga[i] == 1)
            fill_pixel(i,cred,cgreen,cblue);
        else
            fill_pixel(i,0,0,0); 
    }
}

//Recorre todo el texto a mostrar
void recorre(){
  for (int i=0; i<LTXT; i++){
    ventana(i);
    dibujaVentana();
    array.update(buffer, NLEDS); 
    wait_ms(250);
  }
}

int main()
{

    // Turn off miniblip buzzer
    PwmOut speaker(P0_8);
    speaker=0.0;
    limpiar();
    array.update(buffer, NLEDS); 

    while(1){
      recorre();
    }
}
