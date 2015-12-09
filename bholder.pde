import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import java.util.ArrayList;
import java.io.IOException;
//import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.lang.reflect.Method;
 
private static final int REQUEST_ENABLE_BT = 3;
ArrayList dispositivos;
BluetoothAdapter adaptador;
BluetoothDevice dispositivo;
BluetoothSocket socket;
//InputStream ins;
BufferedReader ins;
OutputStream ons;

boolean registrado = false;
PFont f1;
PFont f2;
PFont font;
int estado;
String error;
int valor;
byte[] buffer;
PImage logo;

Scrollbar scaleBar;

int Sensor = 500;      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int IBI;         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int BPM;         // HOLDS HEART RATE VALUE FROM ARDUINO
int[] RawY;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[] ScaledY;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[] rate;      // USED TO POSITION BPM DATA WAVEFORM
float zoom;      // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
color eggshell = color(255, 253, 248);
int heart = 0;   // This variable times the heart image 'pulse' on screen
String inData;
//  THESE VARIABLES DETERMINE THE SIZE OF THE DATA WINDOWS

int PulseWindowWidth; //= round(width * 0.90);
int PulseWindowHeight; //= round(height * 0.80); 
int BPMWindowWidth; //= round(PulseWindowWidth * 0.25);
int BPMWindowHeight; //= round(PulseWindowHeight * 0.60);
boolean beat = false;    // set when a heart beat is detected, then cleared when the BPM graph is advanced

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BroadcastReceiver receptor = new BroadcastReceiver()
{
    public void onReceive(Context context, Intent intent)
    {
        println("onReceive");
        String accion = intent.getAction();
 
        if (BluetoothDevice.ACTION_FOUND.equals(accion))
        {
            BluetoothDevice dispositivo = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
            println(dispositivo.getName() + " " + dispositivo.getAddress());
            dispositivos.add(dispositivo);
        }
        else if (BluetoothAdapter.ACTION_DISCOVERY_STARTED.equals(accion))
        {
          estado = 0;
          println("Empieza búsqueda");
        }
        else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(accion))
        {
          estado = 1;
          println("Termina búsqueda");
        }
 
    }
};
 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  //size(320,480);
  frameRate(25);
  f1 = createFont("Arial",20,true);
  f2 = createFont("Arial",15,true);
  stroke(255);
  
  font = loadFont("Arial-BoldMT-24.vlw");
  textFont(font);
  textAlign(CENTER);
  rectMode(CENTER);
  ellipseMode(CENTER);  
// Scrollbar constructor inputs: x,y,width,height,minVal,maxVal

  PulseWindowWidth = round(width * 0.8);
  PulseWindowHeight = round((height - 90) *  0.9); 
  BPMWindowWidth = round(width * 0.8);
  BPMWindowHeight = round((height - 90) *  0.9);

  scaleBar = new Scrollbar (width/2, height - 20, width, 12, 0.5, 1.0);  // set parameters for the scale bar
  RawY = new int[PulseWindowWidth];          // initialize raw pulse waveform array
  ScaledY = new int[PulseWindowWidth];       // initialize scaled pulse waveform array
  rate = new int [BPMWindowWidth];           // initialize BPM waveform array
  zoom = 0.75;                               // initialize scale of heartbeat window
    
// set the visualizer lines to 0
 for (int i=0; i<rate.length; i++){
    rate[i] = 555;      // Place BPM graph line at bottom of BPM Window 
   }
 for (int i=0; i<RawY.length; i++){
    RawY[i] = height/2; // initialize the pulse window data line to V/2
 }

}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void draw() {
  switch(estado)
  {
    case 0:
      listaDispositivos("BUSCANDO DISPOSITIVOS", color(255, 0, 0));
      break;
    case 1:
      listaDispositivos("ELIJA DISPOSITIVO", color(255, 0, 0));
      break;
    case 2:
      conectaDispositivo();
      break;
    case 3:
      muestraDatos();
      break;
    case 4:
      muestraError();
      break;
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void onStart()
{
  super.onStart();
  println("onStart");
  adaptador = BluetoothAdapter.getDefaultAdapter();
  if (adaptador != null)
  {
    if (!adaptador.isEnabled())
    {
        Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
        startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
    }
    else
    {
      empieza();
    }
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void onStop()
{
  println("onStop");
  /*
  if(registrado)
  {
    unregisterReceiver(receptor);
  }
  */
 
  if(socket != null)
  {
    try
    {
      socket.close();
    }
    catch(IOException ex)
    {
      println(ex);
    }
  }
  super.onStop();
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void onActivityResult (int requestCode, int resultCode, Intent data)
{
  println("onActivityResult");
  if(resultCode == RESULT_OK)
  {
    println("RESULT_OK");
    empieza();
  }
  else
  {
    println("RESULT_CANCELED");
    estado = 4;
    error = "No se ha activado el bluetooth";
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void mouseReleased()
{
  scaleBar.release();
  switch(estado)
  {
    case 0:
      /*
      if(registrado)
      {
        adaptador.cancelDiscovery();
      }
      */
      break;
    case 1:
      compruebaEleccion();
      break;
    case 3:
      compruebaBoton();
      break;
  }
}

void mousePressed(){
  scaleBar.press(mouseX, mouseY);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void empieza()
{
    dispositivos = new ArrayList();
    /*
    registerReceiver(receptor, new IntentFilter(BluetoothDevice.ACTION_FOUND));
    registerReceiver(receptor, new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_STARTED));
    registerReceiver(receptor, new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED));
    registrado = true;
    adaptador.startDiscovery();
    */
    for (BluetoothDevice dispositivo : adaptador.getBondedDevices())
    {
        dispositivos.add(dispositivo);
    }
    estado = 1;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void listaDispositivos(String texto, color c)
{
  background(255);
  textFont(f1);
  fill(c);
  text(texto,width/2, 20);
  
  logo = loadImage("bholder.jpg");
  image(logo,0, height / 2,width,height / 2);
  //logo.scale(0.5);
  
  if(dispositivos != null)
  {
    for(int indice = 0; indice < dispositivos.size(); indice++)
    {
      BluetoothDevice dispositivo = (BluetoothDevice) dispositivos.get(indice);
      fill(0,0,255);
      int posicion = 50 + (indice * 55);
      if(dispositivo.getName() != null)
      {
        text(dispositivo.getName(),width/2, posicion);
      }
      fill(255,0,255);
      text(dispositivo.getAddress(),width/2, posicion + 20);
      fill(0);
      stroke(0,0,0);
      line(0, posicion + 30, width, posicion + 30);
    }
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void compruebaEleccion()
{
  int elegido = (mouseY - 50) / 55;
  if(elegido < dispositivos.size())   
  {     
    dispositivo = (BluetoothDevice) dispositivos.get(elegido);     
    println(dispositivo.getName());     
    estado = 2;   
  } 
} 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
void conectaDispositivo() 
{   
  try   
  {     
    //socket = dispositivo.createRfcommSocketToServiceRecord(UUID.fromString("00001101-0000-1000-8000-00805F9B34FB"));
         
      Method m = dispositivo.getClass().getMethod("createRfcommSocket", new Class[] { int.class });     
      socket = (BluetoothSocket) m.invoke(dispositivo, 1);     
      
    //socket.bufferUntil('\n');
    socket.connect();
    
    ins = new BufferedReader(new InputStreamReader(socket.getInputStream()));

   //ins = socket.readStringUntil('\n');
   inData = ins.readLine();                 // cut off white space (carriage return)
   inData = trim(inData);
   if (inData.charAt(0) == 'S'){          // leading 'S' for sensor data
     inData = inData.substring(1);        // cut off the leading 'S'
     Sensor = int(inData);                // convert the string to usable int
   }
   if (inData.charAt(0) == 'B'){          // leading 'B' for BPM data
     inData = inData.substring(1);        // cut off the leading 'B'
     BPM = int(inData);                   // convert the string to usable int
     beat = true;                         // set beat flag to advance heart rate graph
     //heart = 20;                          // begin heart image 'swell' timer
   }
 if (inData.charAt(0) == 'Q'){            // leading 'Q' means IBI data 
     inData = inData.substring(1);        // cut off the leading 'Q'
     IBI = int(inData);                   // convert the string to usable int
   }
    
    ons = socket.getOutputStream();     
    estado = 3;   
  }   
  catch(Exception ex)   
  {     
    estado = 4;     
    error = ex.toString();     
    println(error);   
  } 
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
void muestraDatos() 
{   
  try
  {     
    while(ins.ready())
    {
      //valor = ins.read(buffer);
      
      inData = ins.readLine();                 // cut off white space (carriage return)
      inData = trim(inData);
   if (inData.charAt(0) == 'S'){          // leading 'S' for sensor data
     inData = inData.substring(1);        // cut off the leading 'S'
     Sensor = int(inData);                // convert the string to usable int
   }
   if (inData.charAt(0) == 'B'){          // leading 'B' for BPM data
     inData = inData.substring(1);        // cut off the leading 'B'
     BPM = int(inData);                   // convert the string to usable int
     beat = true;                         // set beat flag to advance heart rate graph
     //heart = 20;                          // begin heart image 'swell' timer
   }
 if (inData.charAt(0) == 'Q'){            // leading 'Q' means IBI data 
     inData = inData.substring(1);        // cut off the leading 'Q'
     IBI = int(inData);                   // convert the string to usable int
   }

    }
  }
  catch(Exception ex)
  {
    estado = 4;
    error = ex.toString();
    println(error);
  }
///// AQUI SE MUESTRAN PORFIN LOS DATOS

  background(0);
  noStroke();
// DRAW OUT THE PULSE WINDOW AND BPM WINDOW RECTANGLES  
  fill(eggshell);  // color for the window background
  rect(width/2,height/2,PulseWindowWidth,PulseWindowHeight);
  //rect(0,0,BPMWindowWidth,BPMWindowHeight);
  
// DRAW THE PULSE WAVEFORM
  // prepare pulse data points
  int posicionarray = RawY.length -1;  
  RawY[RawY.length-1] = (1023 - Sensor) - 212;   // place the new raw datapoint at the end of the array
  zoom = scaleBar.getPos();                      // get current waveform scale value
  offset = map(zoom,0.5,1,150,0);                // calculate the offset needed at this scale
  for (int i = 0; i < RawY.length-1; i++) {      // move the pulse waveform by
    RawY[i] = RawY[i+1];                         // shifting all raw datapoints one pixel left
    float dummy = RawY[i] * zoom + offset;       // adjust the raw data to the selected scale
    ScaledY[i] = constrain(int(dummy),44,556);   // transfer the raw data array to the scaled array
  }
  stroke(250,0,250);                               // red is a good color for the pulse waveform
  noFill();
  beginShape();                                  // using beginShape() renders fast
  for (int x = 1; x < ScaledY.length-1; x++) {    
    vertex(x+((width/2)-(PulseWindowWidth/2)), (30+(height/15))+ScaledY[x]);                    //draw a line connecting the data points
  }
  endShape();
  
// DRAW THE BPM WAVE FORM
// first, shift the BPM waveform over to fit then next data point only when a beat is found
 if (beat == true){   // move the heart rate line over one pixel every time the heart beats 
   beat = false;      // clear beat flag (beat flag waset in serialEvent tab)
   for (int i=0; i<rate.length-1; i++){
     rate[i] = rate[i+1];                  // shift the bpm Y coordinates over one pixel to the left
   }
// then limit and scale the BPM value
   BPM = min(BPM,200);                     // limit the highest BPM value to 200
   float dummy = map(BPM,0,200,555,215);   // map it to the heart rate window Y
   rate[rate.length-1] = int(dummy);       // set the rightmost pixel to the new data point value
 } 
 // GRAPH THE HEART RATE WAVEFORM
 stroke(250,0,0);                          // color of heart rate graph
 strokeWeight(2);                          // thicker line is easier to read
 noFill();
 beginShape();
 for (int i=0; i < rate.length-1; i++){    // variable 'i' will take the place of pixel x position   
   vertex(i+((width/2)-(PulseWindowWidth/2)), ((height / 2) - 150) + (rate[i]));                 // display history of heart rate datapoints
 }
 endShape();
 
// DRAW THE HEART AND MAYBE MAKE IT BEAT
  //fill(250,0,0);
  //stroke(250,0,0);
   //the 'heart' variable is set in serialEvent when arduino sees a beat happen
  //heart--;                    // heart is used to time how long the heart graphic swells when your heart beats
  //heart = max(heart,0);       // don't let the heart variable go into negative numbers
  //if (heart > 0){             // if a beat happened recently, 
  //  strokeWeight(8);          // make the heart big
  //}
  //smooth();   // draw the heart with two bezier curves
  //bezier(width-100,50, width-20,-20, width,140, width-100,150);
  //bezier(width-100,50, width-190,-20, width-200,140, width-100,150);
  //strokeWeight(1);          // reset the strokeWeight for next time


// PRINT THE DATA AND VARIABLE VALUES
  fill(eggshell);                                       // get ready to print text
  //println(ins);
  //println(inData);
  text("B-Holder Sensor 1.0",width/2,30);     // tell them what you are
  text("IBI " + IBI + "mS",width/2,60);    // print the time between heartbeats in mS
  text(Sensor + " raw / Zoom " + zoom,width/2,height - 60);
  text(BPM + " BPM",width/2,height - 30);                           // print the Beats Per Minute
  //text("Pulse Window Scale " + nf(zoom,1,2), 150, 585); // show the current scale of Pulse Window
  
//  DO THE SCROLLBAR THINGS
  scaleBar.update (mouseX, mouseY);
  scaleBar.display();
  
//  



///// FIN DE MOSTRAR INFORMACION
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void compruebaBoton()
{
  if(mouseX > 120 && mouseX < 200 && mouseY > 400 && mouseY < 440)
  {
    try
    {
        ons.write(0);
    }
    catch(Exception ex)
    {
      estado = 4;
      error = ex.toString();
      println(error);
    }
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void muestraError()
{
  background(255, 0, 0);
  fill(255, 255, 0);
  textFont(f2);
  textAlign(CENTER);
  translate(width / 2, height / 2);
  rotate(3 * PI / 2);
  text(error, 0, 0);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
