// Need G4P library
import g4p_controls.*;
import java.awt.font.TextAttribute;
import processing.serial.*;

Serial arduinoPort;  // Create object from Serial class
String inString;
boolean firstContact = false;  // Whether we've heard from the microcontroller

boolean serialInput = false;
boolean connecting = false;
boolean saving = false;
boolean sendingSave = false;

boolean configDone = false;
boolean configRequested = true;
byte[] configBytes = null; //Incoming config string

byte[] sensorBytes = new byte[0];

int pingInterval = 2000;
long prevMillisPing = 0;

short connectStage = 0;

public void setup(){
  frameRate(20);
  size(1050, 550, JAVA2D);
  pixelDensity(displayDensity());
  createGUI();
  // Place your setup code here
  showConnectPrompt();
  
}

public void draw(){
  background(245);
  long currentMillis = millis();
  
  if (firstContact) {
    if (sendingSave) {
      sendSaveCmd();
      sendingSave = false;
    }
    if (serialInput) {
      if (configBytes != null && configBytes.length == 56) {
        println("Got config data with correct length");
        //String[] splitStr = configStr.split(",",0);
        
        handleConfigCommand();

        serialInput = false;
        configDone = true;
        configBytes = new byte[0];
        if (saving) {
          saving = false;
          hidePrompt();
        }
        if (connecting) {
          connecting = false; 
          connectionProgress(100);
          hidePrompt();
        }
      } else if (sensorBytes != null) {
        handleSensorCommand();
  
        serialInput = false;
        sensorBytes = null;
      }
    } 
    
    if (currentMillis - prevMillisPing >= pingInterval*5) {
      //ping();
      println("SERIAL TIMEOUT");
      G4P.showMessage(this, "Anslutning avbruten. Försök ansluta igen.", "Avbrott i anslutning", G4P.ERROR_MESSAGE);
      resetConnectionState();
    }
  }
  if (connecting && (currentMillis - prevMillisPing >= pingInterval+300)) {
      
    if (arduinoPort == null) {
      println("Connecting with arduinoport == null");
      resetConnectionState();  
    }
    try {
      if (connectStage == 0) {
        arduinoPort.clear(); 
        arduinoPort.write("   ");
        //arduinoPort.clear(); 
        connectStage = 1;
        prevMillisPing = millis();
        connectionProgress(50);
        println("connectstage 1 done");
      } else if (connectStage == 1) {
        arduinoPort.bufferUntil('\n');
        connectStage = 2;
        prevMillisPing = millis();
        connectionProgress(90);
        println("connectstage 2 done");
      } else if (currentMillis - prevMillisPing >= pingInterval*7) {
        println("SERIAL TIMEOUT WHEN CONNECTING!");
        G4P.showMessage(this, "Anslutningen tog för lång tid. Försök ansluta igen.", "Anslutning avbruten", G4P.ERROR_MESSAGE);
        resetConnectionState();
      }
    } catch (Exception e) {
      println("Failed to open serial port");
      e.printStackTrace();
      G4P.showMessage(this, "Anslutning misslyckades. Valde du rätt port? Försök igen.", "Anslutning misslyckades", G4P.ERROR_MESSAGE);
    }
  }
}

public void connectSerial(String port) {
  try {
    arduinoPort = new Serial(this, port, 9600);
  } catch (Exception e) {
    println("Failed to open serial port");
    e.printStackTrace();
    G4P.showMessage(this, "Anslutning misslyckades. Valde du rätt port? Försök igen.", "Anslutning misslyckades", G4P.ERROR_MESSAGE);
    resetConnectionState();
    return;
  }
  connectionProgress(10);
  prevMillisPing = millis();
  firstContact = false;
  connecting = true;
  
}

void ping() {
  if (firstContact) {
    arduinoPort.write('X');
  } else {
    arduinoPort.write('Z');
  }
}

void serialEvent(Serial arduinoPort) {
  // if in connecting phase, do not handle any messages
  if (connectStage != 2) {
    return;
  }
  // read a byte from the serial port:
  int inByte = arduinoPort.read();
  

  if ((char)inByte == 'Z') {
    arduinoPort.clear();   // clear the serial port buffer
    //firstContact = true;  // you've had first contact from the microcontroller
    arduinoPort.readStringUntil('\n');
    arduinoPort.write("X,\n");
  } else if ((char)inByte == 'X') {
    arduinoPort.readStringUntil('\n');
    prevMillisPing = millis(); //reset timeout timer
    if (!firstContact) {
      firstContact = true;  // you've had first contact from the microcontroller
      configRequested = false;
    }
  } else if (firstContact) {
    
    if (!configRequested && configBytes == null) {
      println("Requesting complete config");
      arduinoPort.write("C,\n"); //Request complete config
      configRequested = true;
    }
    //Handle command
    if ((char)inByte == 'C') {
      println("Got config cmd");
      //configStr = arduinoPort.readStringUntil('\n');
      configBytes = arduinoPort.readBytes(57);
      serialInput = true;
    } else if ((char)inByte == 'S') {
      sensorBytes = arduinoPort.readBytes(12);
      serialInput = true;
    } else  {
      print((char)inByte);
      println(arduinoPort.readStringUntil('\n'));
    } 
  }
}

void handleConfigCommand() {
  humidityInterval.setValue(configBytes[1]);
  //println(configBytes[1]);
  
  sensor1Enable.setSelected(configBytes[3] == 1);
  sensor2Enable.setSelected(configBytes[3+17] == 1);
  sensor3Enable.setSelected(configBytes[3+17*2] == 1);
  
  sensor1Limit.setValue(configBytes[5]);
  sensor2Limit.setValue(configBytes[5+17]);
  sensor3Limit.setValue(configBytes[5+17*2]);
  
  sensor1Pumptime.setValue(configBytes[7]);
  sensor2Pumptime.setValue(configBytes[7+17]);
  sensor3Pumptime.setValue(configBytes[7+17*2]);
  
  sensor1Maxpumpings.setValue(configBytes[9]);
  sensor2Maxpumpings.setValue(configBytes[9+17]);
  sensor3Maxpumpings.setValue(configBytes[9+17*2]);
  
  sensor1Pumptimeout.setValue(configBytes[11]);
  sensor2Pumptimeout.setValue(configBytes[11+17]);
  sensor3Pumptimeout.setValue(configBytes[11+17*2]);
  
  sensor1Pumpdelay.setValue(configBytes[13]);
  sensor2Pumpdelay.setValue(configBytes[13+17]);
  sensor3Pumpdelay.setValue(configBytes[13+17*2]);
  
  String calDry1 = Integer.toString(((char) (configBytes[16] & 0xFF) << 8) | (configBytes[15] & 0xFF));
  String calDry2 = Integer.toString(((char) (configBytes[16+17] & 0xFF) << 8) | (configBytes[15+17] & 0xFF));
  String calDry3 = Integer.toString(((char) (configBytes[16+17*2] & 0xFF) << 8) | (configBytes[15+17*2] & 0xFF));
  sensor1CalDry.setText(calDry1);
  sensor2CalDry.setText(calDry2);
  sensor3CalDry.setText(calDry3);
  
  String calWet1 = Integer.toString(((char) (configBytes[19] & 0xFF) << 8) | (configBytes[18] & 0xFF));
  String calWet2 = Integer.toString(((char) (configBytes[19+17] & 0xFF) << 8) | (configBytes[18+17] & 0xFF));
  String calWet3 = Integer.toString(((char) (configBytes[19+17*2] & 0xFF) << 8) | (configBytes[18+17*2] & 0xFF));
  sensor1CalWet.setText(calWet1);
  sensor2CalWet.setText(calWet2);
  sensor3CalWet.setText(calWet3); 
}
void handleSensorCommand() {
  String sensor1 = Integer.toString(((char) (sensorBytes[1] & 0xFF) << 8) | (sensorBytes[0] & 0xFF));
  String sensor2 = Integer.toString(((char) (sensorBytes[4] & 0xFF) << 8) | (sensorBytes[3] & 0xFF));
  String sensor3 = Integer.toString(((char) (sensorBytes[7] & 0xFF) << 8) | (sensorBytes[6] & 0xFF));
  
  sensor1RawValue.setText(sensor1);
  sensor2RawValue.setText(sensor2);
  sensor3RawValue.setText(sensor3);
  sensor1RawValue.getStyledText().addAttribute(TextAttribute.SIZE, 16);
  sensor2RawValue.getStyledText().addAttribute(TextAttribute.SIZE, 16);
  sensor3RawValue.getStyledText().addAttribute(TextAttribute.SIZE, 16);
}

void sendSaveCmd() {
  saving = true;
  
  String cmd = "M,1," + sensor1Maxpumpings.getValueI();
  arduinoPort.write(cmd + '\n');
  delay(100);
  cmd = "M,2," + sensor2Maxpumpings.getValueI();
  arduinoPort.write(cmd + '\n');
  delay(100);
  cmd = "M,3," + sensor3Maxpumpings.getValueI();
  arduinoPort.write(cmd + '\n');
  delay(100);
  
  cmd = "D,1," + sensor1Pumpdelay.getValueI();
  arduinoPort.write(cmd + '\n');
  delay(100);
  cmd = "D,2," + sensor2Pumpdelay.getValueI();
  arduinoPort.write(cmd + '\n');
  delay(100);
  cmd = "D,3," + sensor3Pumpdelay.getValueI();
  arduinoPort.write(cmd + '\n');
  delay(100);
  
  cmd = "H," + humidityInterval.getValueS();
  arduinoPort.write(cmd + "\n");
  delay(100);
  
  cmd = "K,1," + sensor1CalDry.getValueI();
  arduinoPort.write(cmd + '\n');
  delay(100);
  cmd = "K,2," + sensor2CalDry.getValueI();
  arduinoPort.write(cmd + '\n');
  delay(100);
  cmd = "K,3," + sensor3CalDry.getValueI();
  arduinoPort.write(cmd + '\n');
  delay(100);
  
  cmd = "W,1," + sensor1CalWet.getValueI();
  arduinoPort.write(cmd + '\n');
  delay(100);
  cmd = "W,2," + sensor2CalWet.getValueI();
  arduinoPort.write(cmd + '\n');
  delay(100);
  cmd = "W,3," + sensor3CalWet.getValueI();
  arduinoPort.write(cmd + '\n');
  delay(100);
  
  cmd = "S,";
  arduinoPort.write(cmd + '\n'); 
}

void resetConnectionState() {
  firstContact = false;
  arduinoPort.stop();
  inString = null;

  serialInput = false;
  connecting = false;
  saving = false;

  configDone = false;
  configRequested = true;
  configBytes = null; //Incoming config string

  sensorBytes = new byte[0];
  connectStage = 0;
  showConnectPrompt(); 
}
