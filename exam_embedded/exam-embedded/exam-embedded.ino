
/*
HC-SR04 for Arduino
*/

#include <Adafruit_Sensor.h>

#include <DHT.h>

#include <DHT_U.h>

#define DHTPIN 2

#define DHTTYPE    DHT11

DHT_Unified dht(DHTPIN, DHTTYPE);

const int numReadings = 10;

int readings[numReadings];     
int readIndex = 0;             
int total = 0;                  
int average = 0;               

int inputPin = A0;

const int TriggerPin = 6;     
const int EchoPin = 5;         
long Duration = 0;

int currentTemp;

int setOfAlarm(String cmd);

void setup(){
  for (int thisReading = 0; thisReading < numReadings; thisReading++) {
    readings[thisReading] = 0;
  }    
  pinMode(TriggerPin,OUTPUT);  
  pinMode(EchoPin,INPUT);     
  Serial.begin(9600);          
  dht.begin();
  Particle.function("setOfAlarm", setOfAlarm);
}

void loop(){ 
    
  //The code related to the flame sensor will be inspired by the Smoothing example from 03.Analog in the Arduino IDE.
  total = total - readings[readIndex];
  
  readings[readIndex] = analogRead(inputPin);
  
  total = total + readings[readIndex];
  
  readIndex = readIndex + 1;
  
  if (readIndex >= numReadings) {
      
    readIndex = 0;
  }

  average = total / numReadings;
  Serial.print(average);
  //Wil publish an event if the value is 2 or higher(might be a fire). This is presented as a notification through the IFTTT app. 
  if(average >= 2) {
      Particle.publish("fire", "Might be a fire, check it out", PRIVATE);
      setOfAlarm("on");
      delay(1000);
      setOfAlarm("off");
  }
  
  long Distance_mm = Distance_mm_calc();
  //Publishes an event if the door is opened, this is received by the application.
  Serial.print("Distance = ");             
  Serial.print(Distance_mm);
  Serial.println(" mm");
  if(Distance_mm <= 600) {
      Particle.publish("doorOpen", "Front door just opened", PRIVATE);
      delay(30000);
  } 
  //All things related to the DHT11 sensor will be inspired by the DHT_unified_sensor example in the DHT Sensor Library.
  sensors_event_t event;
  dht.temperature().getEvent(&event);
  currentTemp = event.temperature;
  /*This check happens because the sensor sometimes read value 0 for temperature when it clearly isn't.
  It can be confusing for the user if the temperature jumps from 23 to 0 degrees in a couple of seconds.*/
  if(currentTemp != 0) {
    Particle.publish("currentTemp", String(currentTemp), PRIVATE);
    /*Publishes the "highTemp" event if the temperature reaches 35 degrees, publishes lowTemp event if it's 15 or below.
    This is then sent to the user as a notification, hence the long delay. 
    I don't want to terrorize the user with a notification each second if the temperature is rising or decreasing, that would be annoying.*/
    if(event.temperature >= 35) {
            Particle.publish("highTemp", "temperature is: " + String(currentTemp) + ", This is very high");
            delay(60000);
        } else if (event.temperature <= 15) {
            Particle.publish("lowTemp", "temperature is: " + String(currentTemp) + ", This is very low");
            delay(60000);
        }
  }
  
  delay(2000); 
}


// All things related to the HC-SR04 (ultrasonic sensor) will be inspired by: «flashgamer.com/a/nith/HC_SR04.ino.zip».
//moved the millimeter distance calculation to its own function, it makes the code easier to read.
long Distance_mm_calc() {
    
  digitalWrite(TriggerPin, LOW);                   
  delayMicroseconds(2);
  digitalWrite(TriggerPin, HIGH);          
  delayMicroseconds(10);                  
  digitalWrite(TriggerPin, LOW);           
  Duration = pulseIn(EchoPin,HIGH);       
  long Distance_mm = Distance(Duration); 
  return Distance_mm;
}

long Distance(long time){
    
    long DistanceCalc = ((time /2.9) / 2);
    return DistanceCalc;
}

//The Particle.function that allows the user to fire off the alarm from the application.
int setOfAlarm(String cmd) {
        if(cmd == "on") {
            tone(3, 1000);
            delay(500);
            tone(3, 500);
            delay(500);
            tone(3, 1000);
        } else if (cmd == "off") {
            noTone(3);
        }
    return 0;
}