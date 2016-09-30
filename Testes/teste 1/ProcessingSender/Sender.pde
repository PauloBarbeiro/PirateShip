/*
arduino_input

Demonstrates the reading of digital and analog pins of an Arduino board
running the StandardFirmata firmware.

To use:
* Using the Arduino software, upload the StandardFirmata example (located
  in Examples > Firmata > StandardFirmata) to your Arduino board.
* Run this sketch and look at the list of serial ports printed in the
  message area below. Note the index of the port corresponding to your
  Arduino board (the numbering starts at 0).  (Unless your Arduino board
  happens to be at index 0 in the list, the sketch probably won't work.
  Stop it and proceed with the instructions.)
* Modify the "arduino = new Arduino(...)" line below, changing the number
  in Arduino.list()[0] to the number corresponding to the serial port of
  your Arduino board.  Alternatively, you can replace Arduino.list()[0]
  with the name of the serial port, in double quotes, e.g. "COM5" on Windows
  or "/dev/tty.usbmodem621" on Mac.
* Run this sketch. The squares show the values of the digital inputs (HIGH
  pins are filled, LOW pins are not). The circles show the values of the
  analog inputs (the bigger the circle, the higher the reading on the
  corresponding analog input pin). The pins are laid out as if the Arduino
  were held with the logo upright (i.e. pin 13 is at the upper left). Note
  that the readings from unconnected pins will fluctuate randomly. 
  
For more information, see: http://playground.arduino.cc/Interfacing/Processing
*/

import processing.serial.*;

import cc.arduino.*;

// import UDP library
import hypermedia.net.*;

Arduino arduino;
UDP udp;  // define the UDP object

color off = color(4, 79, 111);
color on = color(84, 145, 158);

int potencia = 0;

void setup() {
  size(470, 280);

  // Prints out the available serial ports.
  println(Arduino.list());
  println("The one");
  println(Arduino.list()[Arduino.list().length-1]);
  // Modify this line, by changing the "0" to the index of the serial
  // port corresponding to your Arduino board (as it appears in the list
  // printed by the line above).
  //arduino = new Arduino(this, Arduino.list()[0], 57600);
  //arduino = new Arduino(this, Arduino.list()[Arduino.list().length-1], 57600);
  arduino = new Arduino(this, "/dev/ttyUSB0", 57600);
  
  // Alternatively, use the name of the serial port corresponding to your
  // Arduino (in double-quotes), as in the following line.
  //arduino = new Arduino(this, "/dev/tty.usbmodem621", 57600);
  
  // Set the Arduino digital pins as inputs.
  for (int i = 0; i <= 13; i++)
    arduino.pinMode(i, Arduino.INPUT);
  
  // create a new datagram connection on port 6000
  // and wait for incomming message
  udp = new UDP( this, 6000 );
  udp.log( true );     // <-- printout the connection activity
  //udp.listen( true );
}

void draw() {
  background(off);
  stroke(on);
  
  // Draw a filled box for each digital pin that's HIGH (5 volts).
  for (int i = 0; i <= 13; i++) {
    if (arduino.digitalRead(i) == Arduino.HIGH)
      fill(on);
    else
      fill(off);
      
    rect(420 - i * 30, 30, 20, 20);
  }

  // Draw a circle whose size corresponds to the value of an analog input.
  noFill();
  for (int i = 0; i <= 5; i++) {
    ellipse(280 + i * 30, 240, arduino.analogRead(i) / 16, arduino.analogRead(i) / 16);
  }
  
  //detecta leitura do potenciometro, checa se houve mudança
  // caso positivo dispara mensagem
  // 
  println();
  if( arduino.analogRead(5) != potencia ){
    potencia = arduino.analogRead(5);
    //dispara msg
    sendMsg();
  }
  
}

void sendMsg(){
    String message  = str( key );  // the message to send
    String ip       = "localhost";  // the remote IP address
    int port        = 5000;    // the destination port
    
    // formats the message for Pd
    message = potencia+";\n";
    // send the message
    udp.send( message, ip, port );
    println("MSG sent");
}

/** 
 * on key pressed event:
 * send the current key value over the network
 */
void keyPressed() {
    
    String message  = str( key );  // the message to send
    String ip       = "localhost";  // the remote IP address
    int port        = 5000;    // the destination port
    
    // formats the message for Pd
    message = message+";\n";
    // send the message
    udp.send( message, ip, port );
    
    if(key == 'e') udp.send("desconnect", ip, port);
    
}

/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
// void receive( byte[] data ) {       // <-- default handler
void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  
  
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  //data = subset(data, 0, data.length-2);
  data = subset(data, 0);
  String message = new String( data );
  
  // print the result
  println( "receive: \""+message+"\" from "+ip+" on port "+port );
}
